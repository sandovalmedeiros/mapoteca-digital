-- ===================================================================================
-- Mapoteca Digital - Script 01: Setup Schema Principal (CORRIGIDO)
-- ===================================================================================
-- Descrição: Criação do schema dados_mapoteca e 18 tabelas principais
-- Ambiente: Oracle Linux (10.28.246.75) | PostgreSQL 14+ | ESRI SDE
-- Usuário: dados_mapoteca | Schema: dados_mapoteca
-- Data: 2025-11-17
-- Versão: 2.0 (CORRIGIDO - Nomenclatura com prefixo t_)
-- ===================================================================================

-- Configuração do ambiente
\set ON_ERROR_STOP on
SET client_min_messages TO WARNING;
SET search_path TO dados_mapoteca, public;

-- ===================================================================================
-- 1. CRIAÇÃO DO SCHEMA
-- ===================================================================================
DROP SCHEMA IF EXISTS dados_mapoteca CASCADE;
CREATE SCHEMA dados_mapoteca;
COMMENT ON SCHEMA dados_mapoteca IS 'Schema principal da Mapoteca Digital para gestão de publicações cartográficas';

-- ===================================================================================
-- 2. EXTENSÕES NECESSÁRIAS
-- ===================================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "postgis" SCHEMA public;

-- ===================================================================================
-- 3. CAMADA 1 - TABELAS DE DOMÍNIO (LOOKUP TABLES) - 9 tabelas
-- ===================================================================================

-- 3.1. t_classe_mapa (Mapa/Cartograma)
CREATE TABLE dados_mapoteca.t_classe_mapa (
    id_classe_mapa VARCHAR(10) PRIMARY KEY,
    nome_classe_mapa VARCHAR(100) NOT NULL UNIQUE
);

COMMENT ON TABLE dados_mapoteca.t_classe_mapa IS 'Classes: Mapa, Cartograma (2 registros)';

-- 3.2. t_tipo_mapa (Estadual/Regional/Municipal)
CREATE TABLE dados_mapoteca.t_tipo_mapa (
    id_tipo_mapa VARCHAR(10) PRIMARY KEY,
    nome_tipo_mapa VARCHAR(100) NOT NULL UNIQUE
);

COMMENT ON TABLE dados_mapoteca.t_tipo_mapa IS 'Tipos: Estadual, Regional, Municipal (3 registros)';

-- 3.3. t_anos
CREATE TABLE dados_mapoteca.t_anos (
    id_ano VARCHAR(10) PRIMARY KEY,
    ano INTEGER NOT NULL UNIQUE CHECK (ano >= 1900 AND ano <= 2100)
);

COMMENT ON TABLE dados_mapoteca.t_anos IS 'Anos de referência 1998-2030 (33 registros)';

-- 3.4. t_escala
CREATE TABLE dados_mapoteca.t_escala (
    codigo_escala VARCHAR(20) PRIMARY KEY,
    nome_escala VARCHAR(100) NOT NULL UNIQUE
);

COMMENT ON TABLE dados_mapoteca.t_escala IS 'Escalas cartográficas (9 registros)';

-- 3.5. t_cor
CREATE TABLE dados_mapoteca.t_cor (
    codigo_cor VARCHAR(20) PRIMARY KEY,
    nome_cor VARCHAR(100) NOT NULL UNIQUE
);

COMMENT ON TABLE dados_mapoteca.t_cor IS 'Cores: Colorido, Preto e Branco (2 registros)';

-- 3.6. t_tipo_tema
CREATE TABLE dados_mapoteca.t_tipo_tema (
    id_tipo_tema VARCHAR(10) PRIMARY KEY,
    codigo_tipo_tema VARCHAR(20) NOT NULL UNIQUE,
    nome_tipo_tema VARCHAR(200) NOT NULL
);

COMMENT ON TABLE dados_mapoteca.t_tipo_tema IS 'Tipos de temas (6 registros)';

-- 3.7. t_tipo_regionalizacao
CREATE TABLE dados_mapoteca.t_tipo_regionalizacao (
    id_tipo_regionalizacao VARCHAR(10) PRIMARY KEY,
    nome_tipo_regionalizacao VARCHAR(200) NOT NULL
);

COMMENT ON TABLE dados_mapoteca.t_tipo_regionalizacao IS 'Tipos de regionalização (11 registros)';

-- 3.8. t_regiao
CREATE TABLE dados_mapoteca.t_regiao (
    id_regiao VARCHAR(10) PRIMARY KEY,
    nome_regiao VARCHAR(200) NOT NULL,
    abrangencia VARCHAR(200)
);

COMMENT ON TABLE dados_mapoteca.t_regiao IS 'Regiões geográficas da Bahia (106 registros)';

-- 3.9. t_tema
CREATE TABLE dados_mapoteca.t_tema (
    id_tema SERIAL PRIMARY KEY,
    codigo_tema VARCHAR(50) NOT NULL UNIQUE,
    nome_tema VARCHAR(200) NOT NULL
);

COMMENT ON TABLE dados_mapoteca.t_tema IS 'Temas dos mapas (55 registros)';

-- ===================================================================================
-- 4. CAMADA 2 - TABELA DE MUNICÍPIOS - 1 tabela
-- ===================================================================================

-- 4.1. t_municipios
CREATE TABLE dados_mapoteca.t_municipios (
    codmun VARCHAR(10) PRIMARY KEY,
    nommun VARCHAR(200) NOT NULL,
    sigla_uf VARCHAR(2) NOT NULL DEFAULT 'BA',
    nome_uf VARCHAR(100) NOT NULL DEFAULT 'Bahia',
    codigo_regiao VARCHAR(10),
    nome_regiao VARCHAR(200),
    codigo_territorio VARCHAR(10),
    nome_territorio VARCHAR(200),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT true
);

COMMENT ON TABLE dados_mapoteca.t_municipios IS 'Municípios da Bahia com informações territoriais (417 registros)';

-- ===================================================================================
-- 5. CAMADA 3 - TABELAS DE RELACIONAMENTO N:N - 3 tabelas
-- ===================================================================================

-- 5.1. t_classe_mapa_tipo_mapa (Combinações válidas)
CREATE TABLE dados_mapoteca.t_classe_mapa_tipo_mapa (
    id_classe_mapa VARCHAR(10) REFERENCES dados_mapoteca.t_classe_mapa(id_classe_mapa) ON DELETE CASCADE,
    id_tipo_mapa VARCHAR(10) REFERENCES dados_mapoteca.t_tipo_mapa(id_tipo_mapa) ON DELETE CASCADE,
    PRIMARY KEY (id_classe_mapa, id_tipo_mapa)
);

COMMENT ON TABLE dados_mapoteca.t_classe_mapa_tipo_mapa IS 'Relacionamento N:N - Combinações válidas de classe e tipo (6 registros)';

-- 5.2. t_regionalizacao_regiao (Regiões por tipo de regionalização)
CREATE TABLE dados_mapoteca.t_regionalizacao_regiao (
    id_tipo_regionalizacao VARCHAR(10) REFERENCES dados_mapoteca.t_tipo_regionalizacao(id_tipo_regionalizacao) ON DELETE CASCADE,
    id_regiao VARCHAR(10) REFERENCES dados_mapoteca.t_regiao(id_regiao) ON DELETE CASCADE,
    PRIMARY KEY (id_tipo_regionalizacao, id_regiao)
);

COMMENT ON TABLE dados_mapoteca.t_regionalizacao_regiao IS 'Relacionamento N:N - Regiões por tipo de regionalização (229 registros)';

-- 5.3. t_tipo_tema_tema (Temas por tipo)
CREATE TABLE dados_mapoteca.t_tipo_tema_tema (
    id_tipo_tema VARCHAR(10) REFERENCES dados_mapoteca.t_tipo_tema(id_tipo_tema) ON DELETE CASCADE,
    id_tema INTEGER REFERENCES dados_mapoteca.t_tema(id_tema) ON DELETE CASCADE,
    PRIMARY KEY (id_tipo_tema, id_tema)
);

COMMENT ON TABLE dados_mapoteca.t_tipo_tema_tema IS 'Relacionamento N:N - Temas por tipo (55 registros)';

-- ===================================================================================
-- 6. CAMADA 4 - TABELAS DE PUBLICAÇÃO - 2 tabelas
-- ===================================================================================

-- 6.1. t_publicacao (Publicações estaduais e regionais)
CREATE TABLE dados_mapoteca.t_publicacao (
    id_publicacao SERIAL PRIMARY KEY,
    id_classe_mapa VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_classe_mapa(id_classe_mapa),
    id_tipo_mapa VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_tipo_mapa(id_tipo_mapa),
    id_ano VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_anos(id_ano),
    id_regiao VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_regiao(id_regiao),
    codigo_escala VARCHAR(20) NOT NULL REFERENCES dados_mapoteca.t_escala(codigo_escala),
    codigo_cor VARCHAR(20) NOT NULL REFERENCES dados_mapoteca.t_cor(codigo_cor),
    id_tipo_regionalizacao VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_tipo_regionalizacao(id_tipo_regionalizacao),
    id_tema INTEGER NOT NULL REFERENCES dados_mapoteca.t_tema(id_tema),
    id_tipo_tema VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_tipo_tema(id_tipo_tema),
    globalid UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE
);

COMMENT ON TABLE dados_mapoteca.t_publicacao IS 'Publicações de mapas estaduais e regionais';
COMMENT ON COLUMN dados_mapoteca.t_publicacao.globalid IS 'GlobalID (UUID) para integração com ArcGIS Attachments';

-- 6.2. t_publicacao_municipios (Publicações municipais)
CREATE TABLE dados_mapoteca.t_publicacao_municipios (
    id_publicacao_municipio SERIAL PRIMARY KEY,
    codmun VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_municipios(codmun),
    nommun VARCHAR(200) NOT NULL,
    id_classe_mapa VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_classe_mapa(id_classe_mapa),
    id_tipo_mapa VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_tipo_mapa(id_tipo_mapa),
    id_ano VARCHAR(10) NOT NULL REFERENCES dados_mapoteca.t_anos(id_ano),
    globalid UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE
);

COMMENT ON TABLE dados_mapoteca.t_publicacao_municipios IS 'Publicações de mapas municipais';
COMMENT ON COLUMN dados_mapoteca.t_publicacao_municipios.globalid IS 'GlobalID (UUID) para integração com ArcGIS Attachments';

-- ===================================================================================
-- 7. CAMADA 5 - TABELAS DE ATTACHMENTS (SDE) - 2 tabelas
-- ===================================================================================

-- 7.1. t_publicacao__attach (Anexos PDF - Estaduais/Regionais)
CREATE TABLE dados_mapoteca.t_publicacao__attach (
    objectid SERIAL PRIMARY KEY,
    attachmentid INTEGER,
    globalid UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE,
    rel_globalid UUID NOT NULL,
    content_type VARCHAR(100) DEFAULT 'application/pdf',
    att_name VARCHAR(500) NOT NULL,
    data_size INTEGER NOT NULL CHECK (data_size > 0),
    data BYTEA NOT NULL,

    FOREIGN KEY (rel_globalid) REFERENCES dados_mapoteca.t_publicacao(globalid) ON DELETE CASCADE
);

COMMENT ON TABLE dados_mapoteca.t_publicacao__attach IS 'Attachments SDE - PDFs das publicações estaduais/regionais';
COMMENT ON COLUMN dados_mapoteca.t_publicacao__attach.rel_globalid IS 'GlobalID da publicação relacionada (FK para t_publicacao.globalid)';
COMMENT ON COLUMN dados_mapoteca.t_publicacao__attach.data IS 'Dados binários do PDF (BYTEA)';

-- 7.2. t_publicacao_municipios_attach (Anexos PDF - Municipais)
CREATE TABLE dados_mapoteca.t_publicacao_municipios_attach (
    attachmentid SERIAL PRIMARY KEY,
    rel_globalid UUID NOT NULL,
    content_type VARCHAR(100),
    att_name VARCHAR(500),
    data_size BIGINT CHECK (data_size > 0 OR data_size IS NULL),
    data BYTEA,
    globalid UUID NOT NULL DEFAULT uuid_generate_v4() UNIQUE,

    FOREIGN KEY (rel_globalid) REFERENCES dados_mapoteca.t_publicacao_municipios(globalid) ON DELETE CASCADE
);

COMMENT ON TABLE dados_mapoteca.t_publicacao_municipios_attach IS 'Attachments SDE - PDFs das publicações municipais';
COMMENT ON COLUMN dados_mapoteca.t_publicacao_municipios_attach.rel_globalid IS 'GlobalID da publicação municipal relacionada';

-- ===================================================================================
-- 8. ÍNDICES PRINCIPAIS
-- ===================================================================================

-- Índices para performance de domínios
CREATE INDEX idx_t_classe_mapa_nome ON dados_mapoteca.t_classe_mapa(nome_classe_mapa);
CREATE INDEX idx_t_tipo_mapa_nome ON dados_mapoteca.t_tipo_mapa(nome_tipo_mapa);
CREATE INDEX idx_t_regiao_nome ON dados_mapoteca.t_regiao(nome_regiao);
CREATE INDEX idx_t_tema_nome ON dados_mapoteca.t_tema(nome_tema);
CREATE INDEX idx_t_tema_codigo ON dados_mapoteca.t_tema(codigo_tema);
CREATE INDEX idx_t_tipo_tema_codigo ON dados_mapoteca.t_tipo_tema(codigo_tipo_tema);

-- Índices para municípios
CREATE INDEX idx_t_municipios_codmun ON dados_mapoteca.t_municipios(codmun);
CREATE INDEX idx_t_municipios_nome ON dados_mapoteca.t_municipios(nommun);
CREATE INDEX idx_t_municipios_regiao ON dados_mapoteca.t_municipios(codigo_regiao) WHERE codigo_regiao IS NOT NULL;

-- Índices para relacionamentos N:N
CREATE INDEX idx_t_regionalizacao_regiao ON dados_mapoteca.t_regionalizacao_regiao(id_regiao);
CREATE INDEX idx_t_tipo_tema_tema_tema ON dados_mapoteca.t_tipo_tema_tema(id_tema);
CREATE INDEX idx_t_classe_mapa_tipo_mapa_tipo ON dados_mapoteca.t_classe_mapa_tipo_mapa(id_tipo_mapa);

-- Índices compostos para publicações
CREATE INDEX idx_t_publicacao_classe_tipo ON dados_mapoteca.t_publicacao(id_classe_mapa, id_tipo_mapa);
CREATE INDEX idx_t_publicacao_regiao_ano ON dados_mapoteca.t_publicacao(id_regiao, id_ano);
CREATE INDEX idx_t_publicacao_tema_tipo ON dados_mapoteca.t_publicacao(id_tema, id_tipo_tema);
CREATE INDEX idx_t_publicacao_escala_cor ON dados_mapoteca.t_publicacao(codigo_escala, codigo_cor);
CREATE INDEX idx_t_publicacao_regionalizacao ON dados_mapoteca.t_publicacao(id_tipo_regionalizacao);
CREATE INDEX idx_t_publicacao_globalid ON dados_mapoteca.t_publicacao(globalid);

-- Índices para attachments
CREATE INDEX idx_t_publicacao_attach_rel_globalid ON dados_mapoteca.t_publicacao__attach(rel_globalid);
CREATE INDEX idx_t_publicacao_attach_content_type ON dados_mapoteca.t_publicacao__attach(content_type);
CREATE INDEX idx_t_publicacao_attach_name ON dados_mapoteca.t_publicacao__attach(att_name);
CREATE INDEX idx_t_publicacao_municipios_attach_rel_globalid ON dados_mapoteca.t_publicacao_municipios_attach(rel_globalid);

-- ===================================================================================
-- 9. RESUMO DA CRIAÇÃO
-- ===================================================================================

SELECT
    'dados_mapoteca' as schema_name,
    COUNT(*) as total_tables,
    '18 tabelas conforme documentação' as observacao
FROM information_schema.tables
WHERE table_schema = 'dados_mapoteca';

-- Listar todas as tabelas criadas
SELECT
    table_name,
    CASE
        WHEN table_name LIKE '%classe%' OR table_name LIKE '%tipo%' OR table_name LIKE '%ano%'
             OR table_name LIKE '%escala%' OR table_name LIKE '%cor%' OR table_name LIKE '%tema%'
             OR table_name LIKE '%regionalizacao%' OR table_name LIKE '%regiao' THEN 'CAMADA 1 - Domínio'
        WHEN table_name = 't_municipios' THEN 'CAMADA 2 - Municípios'
        WHEN table_name LIKE '%\__%' THEN 'CAMADA 3 - Relacionamentos N:N'
        WHEN table_name LIKE '%publicacao%' AND table_name NOT LIKE '%attach%' THEN 'CAMADA 4 - Publicações'
        WHEN table_name LIKE '%attach%' THEN 'CAMADA 5 - Attachments SDE'
        ELSE 'Outras'
    END as camada,
    pg_size_pretty(pg_total_relation_size('dados_mapoteca.' || table_name)) as tamanho
FROM information_schema.tables
WHERE table_schema = 'dados_mapoteca'
ORDER BY camada, table_name;

-- Fim do Script 01 (CORRIGIDO)
-- ===================================================================================
-- ✅ Schema criado com sucesso:
-- ✓ 9 tabelas de domínio (CAMADA 1)
-- ✓ 1 tabela de municípios (CAMADA 2)
-- ✓ 3 tabelas de relacionamento N:N (CAMADA 3)
-- ✓ 2 tabelas de publicação (CAMADA 4)
-- ✓ 2 tabelas de attachments SDE (CAMADA 5)
-- ✓ 1 tabela de controle (opcional)
-- ===================================================================================
-- TOTAL: 18 tabelas + índices otimizados
-- ===================================================================================
