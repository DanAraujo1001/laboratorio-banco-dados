-- Inserindo dados nas dimensões

-- 1. Dimensão Forma de Pagamento
INSERT INTO "public"."dim_forma_pagamento" ("sk_forma_pagamento", "tipo_pagamento", "condicao_pagamento") VALUES
(1, 'Boleto Bancário', '30 dias'),
(2, 'Boleto Bancário', '30/60/90 dias'),
(3, 'Transferência / PIX', 'À vista'),
(4, 'Faturamento Direto', '45 dias');

-- 2. Dimensão Tempo / Data
INSERT INTO "public"."dim_tempo_data" ("sk_tempo", "data_completa", "hora_compra", "turno", "dia_semana", "mes", "nome_mes", "trimestre", "ano", "eh_dia_util") VALUES
(2026082409, '2026-08-24', '09:15:00', 'Manhã', 'Segunda-feira', 8, 'Agosto', 3, 2026, TRUE),
(2026082414, '2026-08-24', '14:30:00', 'Tarde', 'Segunda-feira', 8, 'Agosto', 3, 2026, TRUE),
(2026082510, '2026-08-25', '10:00:00', 'Manhã', 'Terça-feira', 8, 'Agosto', 3, 2026, TRUE),
(2026082522, '2026-08-25', '22:45:00', 'Noite', 'Terça-feira', 8, 'Agosto', 3, 2026, TRUE);

-- 3. Dimensão Unidade Hospitalar
INSERT INTO "public"."dim_unidade" ("sk_unidade", "cod_unidade_erp", "nome_unidade", "tipo_unidade", "bairro", "cidade", "estado", "regiao", "qtd_leitos") VALUES
(1, 'HOSP-AJU-001', 'Hospital S+ Aracaju (Matriz)', 'Matriz', 'Farolândia', 'Aracaju', 'SE', 'Nordeste', 150),
(2, 'HOSP-REC-002', 'Hospital S+ Boa Viagem', 'Filial', 'Boa Viagem', 'Recife', 'PE', 'Nordeste', 120),
(3, 'HOSP-SAO-003', 'Hospital S+ Paulista', 'Filial', 'Bela Vista', 'São Paulo', 'SP', 'Sudeste', 300);

-- 4. Dimensão Produto / Serviço
INSERT INTO "public"."dim_produto_servico" ("sk_produto", "cod_produto_erp", "cod_produto_fornecedor", "nome_produto", "codigo_barras", "tipo_embalagem", "tipo_item", "categoria") VALUES
(101, 'MED-LUV-001', 'FORN-LX-50', 'Luva de Procedimento Nitrílica M', '7891000200011', 'Caixa com 100 un', 'Produto', 'EPI / Descartáveis'),
(102, 'MED-SER-002', 'BD-SRG-10ML', 'Seringa Descartável 10ml com Agulha', '7891000200028', 'Caixa com 50 un', 'Produto', 'Material Cirúrgico'),
(103, 'FAR-DIP-003', 'EMS-DIP-500', 'Dipirona Sódica Injetável 500mg/ml', '7891000200035', 'Ampola 2ml', 'Produto', 'Medicamentos'),
(104, 'SRV-CAL-004', 'CALIB-ANUAL', 'Serviço de Calibração de Respiradores', NULL, 'Não Aplicável', 'Serviço', 'Manutenção Hospitalar');

-- 5. Dimensão Fornecedor
INSERT INTO "public"."dim_fornecedor" ("sk_fornecedor", "cod_fornecedor_erp", "razao_social", "nome_fantasia", "cnpj", "perfil_fornecedor", "porte_empresa", "cidade", "estado") VALUES
(10, 'FORN-001', 'Cirúrgica Nordeste Distribuidora Ltda', 'Cirúrgica Nordeste', '12.345.678/0001-90', 'Distribuidora', 'Médio', 'Aracaju', 'SE'),
(20, 'FORN-002', 'MedTech Indústria e Comércio S/A', 'MedTech Brasil', '98.765.432/0001-10', 'Fabricante Direto', 'Grande', 'São Paulo', 'SP'),
(30, 'FORN-003', 'BioSaúde Engenharia Clínica Eireli', 'BioSaúde Calibrações', '45.678.901/0001-23', 'Prestador de Serviços', 'Pequeno', 'Recife', 'PE');

-- 6. Dimensão Setor Requisitante
INSERT INTO "public"."dim_setor_requisitante" ("sk_setor", "nome_setor") VALUES
(1, 'UTI Geral'),
(2, 'Centro Cirúrgico'),
(3, 'Pronto-Socorro'),
(4, 'Almoxarifado Central');

-- Inserindo registros na tabela fato

INSERT INTO "public"."fato_item_compra" (
    "sk_fato_compra",
    "sk_fornecedor",
    "sk_tempo",
    "sk_produto",
    "sk_forma_pagamento",
    "sk_unidade",
    "sk_setor",
    "numero_pedido_compra",
    "preco_cotacao",
    "quantidade",
    "valor_desconto",
    "percentual_desconto",
    "valor_total_pago",
    "dias_entrega",
    "percentual_imposto",
    "valor_imposto"
) VALUES
-- Item 1 do Pedido 001: 50 Caixas de Luvas para UTI em Aracaju
(
    1,                  -- sk_fato_compra
    10,                 -- sk_fornecedor (Cirúrgica Nordeste)
    2026082409,         -- sk_tempo (24/08/2026 - Manhã)
    101,                -- sk_produto (Luvas)
    1,                  -- sk_forma_pagamento (Boleto 30d)
    1,                  -- sk_unidade (Matriz Aracaju)
    1,                  -- sk_setor (UTI Geral)
    'PED-2026-001',     -- numero_pedido_compra
    35.00,              -- preco_cotacao unitário (R$)
    50,                 -- quantidade (50 caixas)
    87.50,              -- valor_desconto (5% de desconto)
    5.00,               -- percentual_desconto (%)
    1662.50,            -- valor_total_pago ((35 * 50) - 87.50)
    3,                  -- dias_entrega
    12.00,              -- percentual_imposto (12% ICMS/PIS/COFINS)
    199.50              -- valor_imposto (R$)
),

-- Item 2 do Pedido 001: 20 Caixas de Seringas para o Centro Cirúrgico em Aracaju
(
    2,                  -- sk_fato_compra
    20,                 -- sk_fornecedor (MedTech Brasil)
    2026082409,         -- sk_tempo (24/08/2026 - Manhã)
    102,                -- sk_produto (Seringas)
    1,                  -- sk_forma_pagamento (Boleto 30d)
    1,                  -- sk_unidade (Matriz Aracaju)
    2,                  -- sk_setor (Centro Cirúrgico)
    'PED-2026-001',     -- numero_pedido_compra
    50.00,              -- preco_cotacao unitário (R$)
    20,                 -- quantidade (20 caixas)
    100.00,             -- valor_desconto (10% de desconto)
    10.00,              -- percentual_desconto (%)
    900.00,             -- valor_total_pago ((50 * 20) - 100.00)
    5,                  -- dias_entrega
    12.00,              -- percentual_imposto (%)
    108.00              -- valor_imposto (R$)
),

-- Item 1 do Pedido 002: 500 Ampolas de Dipirona para o Pronto-Socorro em Recife
(
    3,                  -- sk_fato_compra
    10,                 -- sk_fornecedor (Cirúrgica Nordeste)
    2026082510,         -- sk_tempo (25/08/2026 - Manhã)
    103,                -- sk_produto (Dipirona)
    2,                  -- sk_forma_pagamento (Boleto 30/60/90)
    2,                  -- sk_unidade (Hospital S+ Recife)
    3,                  -- sk_setor (Pronto-Socorro)
    'PED-2026-002',     -- numero_pedido_compra
    4.50,               -- preco_cotacao unitário (R$)
    500,                -- quantidade (500 ampolas)
    0.00,               -- valor_desconto (sem desconto)
    0.00,               -- percentual_desconto (%)
    2250.00,            -- valor_total_pago (4.50 * 500)
    2,                  -- dias_entrega
    18.00,              -- percentual_imposto (%)
    405.00              -- valor_imposto (R$)
),

-- Item 2 do Pedido 002: Contratação de Calibração Técnica em Recife
(
    4,                  -- sk_fato_compra
    30,                 -- sk_fornecedor (BioSaúde Calibrações)
    2026082510,         -- sk_tempo (25/08/2026 - Manhã)
    104,                -- sk_produto (Serviço de Calibração)
    4,                  -- sk_forma_pagamento (Faturamento 45d)
    2,                  -- sk_unidade (Hospital S+ Recife)
    4,                  -- sk_setor (Almoxarifado Central)
    'PED-2026-002',     -- numero_pedido_compra
    3500.00,            -- preco_cotacao unitário (R$)
    1,                  -- quantidade (1 serviço contratado)
    350.00,             -- valor_desconto (10% de desconto)
    10.00,              -- percentual_desconto (%)
    3150.00,            -- valor_total_pago (3500 - 350)
    1,                  -- dias_entrega
    5.00,               -- percentual_imposto (5% ISS)
    157.50              -- valor_imposto (R$)
);