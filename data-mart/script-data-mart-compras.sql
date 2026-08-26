CREATE SCHEMA IF NOT EXISTS "public";

CREATE TABLE "public"."dim_forma_pagamento" (
    "sk_forma_pagamento" bigint NOT NULL,
    "tipo_pagamento" varchar(50) NOT NULL,
    "condicao_pagamento" varchar(50),
    PRIMARY KEY ("sk_forma_pagamento")
);

CREATE TABLE "public"."dim_tempo_data" (
    "sk_tempo" bigint NOT NULL,
    "data_completa" date NOT NULL,
    "hora_compra" time NOT NULL,
    "turno" varchar(20),
    "dia_semana" varchar(20) NOT NULL,
    "mes" int NOT NULL,
    "nome_mes" varchar(20) NOT NULL,
    "trimestre" int NOT NULL,
    "ano" int NOT NULL,
    "eh_dia_util" boolean NOT NULL,
    PRIMARY KEY ("sk_tempo")
);

CREATE TABLE "public"."dim_unidade" (
    "sk_unidade" bigint NOT NULL,
    "cod_unidade_erp" varchar(50) NOT NULL,
    "nome_unidade" varchar(150) NOT NULL,
    "tipo_unidade" varchar(50) NOT NULL,
    "bairro" varchar(100),
    "cidade" varchar(100) NOT NULL,
    "estado" varchar(2) NOT NULL,
    "regiao" varchar(50) NOT NULL,
    "qtd_leitos" int,
    PRIMARY KEY ("sk_unidade")
);

CREATE TABLE "public"."dim_produto_servico" (
    "sk_produto" bigint NOT NULL,
    "cod_produto_erp" varchar(50) NOT NULL,
    "cod_produto_fornecedor" varchar(50),
    "nome_produto" varchar(200) NOT NULL,
    "codigo_barras" varchar(50),
    "tipo_embalagem" varchar(50),
    "tipo_item" varchar(50) NOT NULL,
    "categoria" varchar(100) NOT NULL,
    PRIMARY KEY ("sk_produto")
);

CREATE TABLE "public"."fato_item_compra" (
    "sk_fato_compra" bigint NOT NULL,
    "sk_fornecedor" bigint NOT NULL,
    "sk_tempo" bigint NOT NULL,
    "sk_produto" bigint NOT NULL,
    "sk_forma_pagamento" bigint NOT NULL,
    "sk_unidade" bigint NOT NULL,
    "sk_setor" bigint NOT NULL,
    "numero_pedido_compra" varchar(50) NOT NULL,
    "preco_cotacao" numeric(10, 2) NOT NULL,
    "quantidade" int NOT NULL,
    "valor_desconto" numeric(10, 2) DEFAULT 0.00,
    "percentual_desconto" numeric(5, 2) DEFAULT 0.00,
    "valor_total_pago" numeric(12, 2) NOT NULL,
    "dias_entrega" int NOT NULL,
    "percentual_imposto" numeric(5, 2) NOT NULL,
    "valor_imposto" numeric(10, 2) NOT NULL,
    PRIMARY KEY ("sk_fato_compra")
);

CREATE TABLE "public"."dim_fornecedor" (
    "sk_fornecedor" bigint NOT NULL,
    "cod_fornecedor_erp" varchar(50) NOT NULL,
    "razao_social" varchar(200) NOT NULL,
    "nome_fantasia" varchar(200),
    "cnpj" varchar(20) NOT NULL,
    "perfil_fornecedor" varchar(100),
    "porte_empresa" varchar(50),
    "cidade" varchar(100) NOT NULL,
    "estado" varchar(2) NOT NULL,
    PRIMARY KEY ("sk_fornecedor")
);

CREATE TABLE "public"."dim_setor_requisitante" (
    "sk_setor" bigint NOT NULL,
    "nome_setor" varchar(100) NOT NULL,
    PRIMARY KEY ("sk_setor")
);

-- Foreign key constraints
-- Schema: public
ALTER TABLE "public"."fato_item_compra" ADD CONSTRAINT "fk_fato_item_compra_sk_forma_pagamento_dim_forma_pagamento_s" FOREIGN KEY("sk_forma_pagamento") REFERENCES "public"."dim_forma_pagamento"("sk_forma_pagamento");
ALTER TABLE "public"."fato_item_compra" ADD CONSTRAINT "fk_fato_item_compra_sk_fornecedor_dim_fornecedor_sk_forneced" FOREIGN KEY("sk_fornecedor") REFERENCES "public"."dim_fornecedor"("sk_fornecedor");
ALTER TABLE "public"."fato_item_compra" ADD CONSTRAINT "fk_fato_item_compra_sk_produto_dim_produto_servico_sk_produt" FOREIGN KEY("sk_produto") REFERENCES "public"."dim_produto_servico"("sk_produto");
ALTER TABLE "public"."fato_item_compra" ADD CONSTRAINT "fk_fato_item_compra_sk_setor_dim_setor_requisitante_sk_setor" FOREIGN KEY("sk_setor") REFERENCES "public"."dim_setor_requisitante"("sk_setor");
ALTER TABLE "public"."fato_item_compra" ADD CONSTRAINT "fk_fato_item_compra_sk_tempo_dim_tempo_data_sk_tempo" FOREIGN KEY("sk_tempo") REFERENCES "public"."dim_tempo_data"("sk_tempo");
ALTER TABLE "public"."fato_item_compra" ADD CONSTRAINT "fk_fato_item_compra_sk_unidade_dim_unidade_sk_unidade" FOREIGN KEY("sk_unidade") REFERENCES "public"."dim_unidade"("sk_unidade");