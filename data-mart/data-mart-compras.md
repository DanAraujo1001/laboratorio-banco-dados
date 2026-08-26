# Projeto de Modelagem Dimensional — Data Mart de Compras (Rede Hospitalar S+)

---

## 1. Visão Geral do Projeto

Este projeto consiste no desenvolvimento do **Data Mart de Compras** para a **Rede Hospitalar S+**, com foco em subsidiar a tomada de decisão estratégica do CIO (Sr. Fernando Botelho) e dos gestores de suprimentos.

O modelo foi projetado seguindo as boas práticas da metodologia dimensional de **Ralph Kimball**, adotando uma topologia **Star Schema (Esquema Estrela)** com **1 salto direto** entre as dimensões desnormalizadas e a tabela fato central.

- **Processo de Negócio:** Gestão e Aquisição de Suprimentos Hospitalares.
- **Granularidade (Grão da Fato):** Um registro individual para **cada item/produto adquirido dentro de um pedido de compra**.
- **Topologia:** Esquema Estrela (_Star Schema_).

---

## 2. Diagrama Conceitual do Esquema Estrela

```text
                        ┌──────────────────┐
                        │  dim_tempo_data  │
                        └────────┬─────────┘
                                 │
     ┌──────────────────────┐    │    ┌───────────────────────────┐
     │    dim_fornecedor    │───┐│┌───│    dim_produto_servico    │
     └──────────────────────┘   │││   └───────────────────────────┘
                                ▼▼▼
                       ┌────────────────────┐
                       │  fato_item_compra  │
                       └────────────────────┘
                                ▲▲▲
     ┌──────────────────────┐   │││   ┌───────────────────────────┐
     │     dim_unidade      │───┘│└───│   dim_forma_pagamento     │
     └──────────────────────┘    │    └───────────────────────────┘
                                 │
                     ┌───────────┴────────────┐
                     │ dim_setor_requisitante │
                     └────────────────────────┘
```

# Dicionário de Dados

**Topologia:** Star Schema (Esquema Estrela)  
**Processo de Negócio:** Gestão e Aquisição de Suprimentos / Compras Hospitalares  
**Grão da Fato:** Um registro por item/produto adquirido dentro de cada pedido de compra.

---

## 1. Tabela Fato: `fato_item_compra`

Armazena os eventos pontuais de compra de itens e suas respectivas métricas quantitativas e financeiras.

| Atributo                   | Tipo de Dado    | Restrição    | Descrição / Regra de Negócio                                                                         |
| :------------------------- | :-------------- | :----------- | :--------------------------------------------------------------------------------------------------- |
| **`sk_fato_compra`**       | `BIGINT`        | PK, NOT NULL | Chave primária artificial (Surrogate Key) identificadora da linha da fato.                           |
| **`sk_fornecedor`**        | `BIGINT`        | FK, NOT NULL | Chave de ligação com a dimensão `dim_fornecedor`.                                                    |
| **`sk_tempo`**             | `BIGINT`        | FK, NOT NULL | Chave de ligação com a dimensão `dim_tempo_data`.                                                    |
| **`sk_produto`**           | `BIGINT`        | FK, NOT NULL | Chave de ligação com a dimensão `dim_produto_servico`.                                               |
| **`sk_forma_pagamento`**   | `BIGINT`        | FK, NOT NULL | Chave de ligação com a dimensão `dim_forma_pagamento`.                                               |
| **`sk_unidade`**           | `BIGINT`        | FK, NOT NULL | Chave de ligação com a dimensão `dim_unidade`.                                                       |
| **`sk_setor`**             | `BIGINT`        | FK, NOT NULL | Chave de ligação com a dimensão `dim_setor_requisitante`.                                            |
| **`numero_pedido_compra`** | `VARCHAR(50)`   | NOT NULL     | **Dimensão Degenerada**: Código/Número original do pedido no ERP para agrupamento e rastreabilidade. |
| **`preco_cotacao`**        | `NUMERIC(10,2)` | NOT NULL     | Valor unitário negociado durante a cotação do item (R$).                                             |
| **`quantidade`**           | `INT`           | NOT NULL     | Quantidade de unidades/itens adquiridos.                                                             |
| **`valor_desconto`**       | `NUMERIC(10,2)` | DEFAULT 0.00 | Valor monetário total de desconto obtido no item (R$).                                               |
| **`percentual_desconto`**  | `NUMERIC(5,2)`  | DEFAULT 0.00 | Taxa percentual (%) de desconto aplicada sobre o valor cotado.                                       |
| **`valor_total_pago`**     | `NUMERIC(12,2)` | NOT NULL     | Valor final líquido pago pela aquisição do item (R$).                                                |
| **`dias_entrega`**         | `INT`           | NOT NULL     | Prazo decorrido ou estipulado em dias entre o pedido e a entrega.                                    |
| **`percentual_imposto`**   | `NUMERIC(5,2)`  | NOT NULL     | Alíquota de impostos (%) incidente sobre o item.                                                     |
| **`valor_imposto`**        | `NUMERIC(10,2)` | NOT NULL     | Montante total em impostos (R$) pago pelo item.                                                      |

---

## 2. Tabelas de Dimensão

### 2.1. `dim_produto_servico`

Descreve os suprimentos, medicamentos, materiais ou serviços adquiridos.

| Atributo                     | Tipo de Dado   | Restrição    | Descrição                                                      |
| :--------------------------- | :------------- | :----------- | :------------------------------------------------------------- |
| **`sk_produto`**             | `BIGINT`       | PK, NOT NULL | Chave primária artificial da dimensão.                         |
| **`cod_produto_erp`**        | `VARCHAR(50)`  | NOT NULL     | Código interno do produto no sistema hospitalar.               |
| **`cod_produto_fornecedor`** | `VARCHAR(50)`  | NULL         | Código de referência utilizado pelo fornecedor.                |
| **`nome_produto`**           | `VARCHAR(200)` | NOT NULL     | Nome e descrição detalhada do material ou serviço.             |
| **`codigo_barras`**          | `VARCHAR(50)`  | NULL         | Código de barras padrão EAN/GTIN.                              |
| **`tipo_embalagem`**         | `VARCHAR(50)`  | NULL         | Apresentação física (Caixa, Frasco, Ampola, Unidade, Pacote).  |
| **`tipo_item`**              | `VARCHAR(50)`  | NOT NULL     | Classificação entre 'Produto' ou 'Serviço'.                    |
| **`categoria`**              | `VARCHAR(100)` | NOT NULL     | Segmento (Ex: Medicamentos, EPI, Material Cirúrgico, Higiene). |

---

### 2.2. `dim_fornecedor`

Guarda o perfil, razão social e localização das empresas vendedoras.

| Atributo                 | Tipo de Dado   | Restrição    | Descrição                                                                                   |
| :----------------------- | :------------- | :----------- | :------------------------------------------------------------------------------------------ |
| **`sk_fornecedor`**      | `BIGINT`       | PK, NOT NULL | Chave primária artificial da dimensão.                                                      |
| **`cod_fornecedor_erp`** | `VARCHAR(50)`  | NOT NULL     | Identificador do cadastro do fornecedor no ERP.                                             |
| **`razao_social`**       | `VARCHAR(200)` | NOT NULL     | Razão social registrada na Receita Federal.                                                 |
| **`nome_fantasia`**      | `VARCHAR(200)` | NULL         | Nome fantasia/comercial.                                                                    |
| **`cnpj`**               | `VARCHAR(20)`  | NOT NULL     | CNPJ formatado ou numérico da empresa.                                                      |
| **`perfil_fornecedor`**  | `VARCHAR(100)` | NULL         | Perfil de atuação (Fabricante direto, Distribuidora, Representante, Prestador de Serviços). |
| **`porte_empresa`**      | `VARCHAR(50)`  | NULL         | Porte empresarial (Pequeno, Médio, Grande).                                                 |
| **`cidade`**             | `VARCHAR(100)` | NOT NULL     | Cidade onde a sede/filial do fornecedor se localiza.                                        |
| **`estado`**             | `VARCHAR(2)`   | NOT NULL     | Sigla da Unidade Federativa (UF).                                                           |

---

### 2.3. `dim_unidade`

Mapeia as mais de 1.000 unidades hospitalares da Rede S+.

| Atributo              | Tipo de Dado   | Restrição    | Descrição                                                        |
| :-------------------- | :------------- | :----------- | :--------------------------------------------------------------- |
| **`sk_unidade`**      | `BIGINT`       | PK, NOT NULL | Chave primária artificial da dimensão.                           |
| **`cod_unidade_erp`** | `VARCHAR(50)`  | NOT NULL     | Código único identificador do hospital na rede.                  |
| **`nome_unidade`**    | `VARCHAR(150)` | NOT NULL     | Nome da unidade hospitalar (Ex: Matriz Farolândia).              |
| **`tipo_unidade`**    | `VARCHAR(50)`  | NOT NULL     | Classificação da unidade (Matriz ou Filial).                     |
| **`bairro`**          | `VARCHAR(100)` | NULL         | Bairro onde o hospital está localizado.                          |
| **`cidade`**          | `VARCHAR(100)` | NOT NULL     | Cidade de localização.                                           |
| **`estado`**          | `VARCHAR(2)`   | NOT NULL     | Sigla do Estado (UF).                                            |
| **`regiao`**          | `VARCHAR(50)`  | NOT NULL     | Região geográfica (Nordeste, Sudeste, Sul, Norte, Centro-Oeste). |
| **`qtd_leitos`**      | `INT`          | NULL         | Capacidade diária de leitos para atendimento.                    |

---

### 2.4. `dim_tempo_data`

Permite a navegação temporal e análise de sazonalidade e horários de compra.

| Atributo            | Tipo de Dado  | Restrição    | Descrição                                                                  |
| :------------------ | :------------ | :----------- | :------------------------------------------------------------------------- |
| **`sk_tempo`**      | `BIGINT`      | PK, NOT NULL | Chave inteira de data (Ex: `YYYYMMDD`).                                    |
| **`data_completa`** | `DATE`        | NOT NULL     | Data em que a compra foi efetuada (`AAAA-MM-DD`).                          |
| **`hora_compra`**   | `TIME`        | NOT NULL     | Horário da transação de compra.                                            |
| **`turno`**         | `VARCHAR(20)` | NULL         | Turno do dia (Manhã, Tarde, Noite, Madrugada).                             |
| **`dia_semana`**    | `VARCHAR(20)` | NOT NULL     | Nome do dia da semana (Segunda-feira, Terça-feira, etc.).                  |
| **`mes`**           | `INT`         | NOT NULL     | Mês numérico (1 a 12).                                                     |
| **`nome_mes`**      | `VARCHAR(20)` | NOT NULL     | Nome do mês por extenso (Janeiro a Dezembro).                              |
| **`trimestre`**     | `INT`         | NOT NULL     | Trimestre do ano (1 a 4).                                                  |
| **`ano`**           | `INT`         | NOT NULL     | Ano da compra (Ex: 2026).                                                  |
| **`eh_dia_util`**   | `BOOLEAN`     | NOT NULL     | Flag booleana (`TRUE` para dia útil, `FALSE` para sábado/domingo/feriado). |

---

### 2.5. `dim_forma_pagamento`

Identifica a modalidade e condições comerciais do pagamento.

| Atributo                 | Tipo de Dado  | Restrição    | Descrição                                                    |
| :----------------------- | :------------ | :----------- | :----------------------------------------------------------- |
| **`sk_forma_pagamento`** | `BIGINT`      | PK, NOT NULL | Chave primária artificial da dimensão.                       |
| **`tipo_pagamento`**     | `VARCHAR(50)` | NOT NULL     | Modalidade (Boleto, Faturamento, Transferência/PIX, Cartão). |
| **`condicao_pagamento`** | `VARCHAR(50)` | NULL         | Prazos acordados (À vista, 30 dias, 30/60/90 dias).          |

---

### 2.6. `dim_setor_requisitante`

Identifica a área/departamento do hospital que solicitou os materiais.

| Atributo         | Tipo de Dado   | Restrição    | Descrição                                                                        |
| :--------------- | :------------- | :----------- | :------------------------------------------------------------------------------- |
| **`sk_setor`**   | `BIGINT`       | PK, NOT NULL | Chave primária artificial da dimensão.                                           |
| **`nome_setor`** | `VARCHAR(100)` | NOT NULL     | Nome da área solicitante (Ex: UTI, Centro Cirúrgico, Maternidade, Almoxarifado). |
