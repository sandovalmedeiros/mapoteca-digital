-- ============================================================================
-- Mapoteca Digital - Publication Tables
-- ============================================================================
-- Versão: 1.0.0
-- Data: 2025-11-19
-- Descrição: Criação das tabelas de publicações e attachments
-- Total: 4 tabelas (2 publicações + 2 attachments)
-- ============================================================================

SET search_path TO dados_mapoteca, public;

-- ============================================================================
-- 1. TABELA: t_publicacao
-- Descrição: Tabela principal de publicações (Estaduais e Regionais)
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_publicacao (
    id_publicacao SERIAL PRIMARY KEY,
    objectid INTEGER UNIQUE, -- Para compatibilidade com ESRI
    globalid UUID DEFAULT uuid_generate_v4() UNIQUE, -- Global ID ESRI

    -- Relacionamentos (FKs)
    id_classe_mapa VARCHAR(2) NOT NULL,
    id_tipo_mapa VARCHAR(2) NOT NULL,
    id_ano INTEGER NOT NULL,
    id_regiao VARCHAR(10) NOT NULL,
    id_tipo_regionalizacao VARCHAR(10) NOT NULL,
    id_tema INTEGER NOT NULL,
    id_tipo_tema VARCHAR(10) NOT NULL,
    codigo_escala VARCHAR(20) NOT NULL,
    codigo_cor VARCHAR(10) NOT NULL,

    -- Metadados
    titulo VARCHAR(255),
    descricao TEXT,
    observacoes TEXT,
    palavras_chave TEXT[],
    fonte_dados VARCHAR(255),
    metodologia TEXT,

    -- Controle
    status VARCHAR(20) DEFAULT 'ATIVO' CHECK (status IN ('ATIVO', 'INATIVO', 'RASCUNHO', 'ARQUIVADO')),
    visualizacoes INTEGER DEFAULT 0,
    downloads INTEGER DEFAULT 0,
    usuario_criacao VARCHAR(100),
    usuario_atualizacao VARCHAR(100),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_publicacao TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_pub_classe_mapa
        FOREIGN KEY (id_classe_mapa)
        REFERENCES dados_mapoteca.t_classe_mapa(id_classe_mapa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_tipo_mapa
        FOREIGN KEY (id_tipo_mapa)
        REFERENCES dados_mapoteca.t_tipo_mapa(id_tipo_mapa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_ano
        FOREIGN KEY (id_ano)
        REFERENCES dados_mapoteca.t_anos(id_ano)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_regiao
        FOREIGN KEY (id_regiao)
        REFERENCES dados_mapoteca.t_regiao(id_regiao)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_tipo_regionalizacao
        FOREIGN KEY (id_tipo_regionalizacao)
        REFERENCES dados_mapoteca.t_tipo_regionalizacao(id_tipo_regionalizacao)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_tema
        FOREIGN KEY (id_tema)
        REFERENCES dados_mapoteca.t_tema(id_tema)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_tipo_tema
        FOREIGN KEY (id_tipo_tema)
        REFERENCES dados_mapoteca.t_tipo_tema(id_tipo_tema)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_escala
        FOREIGN KEY (codigo_escala)
        REFERENCES dados_mapoteca.t_escala(codigo_escala)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_cor
        FOREIGN KEY (codigo_cor)
        REFERENCES dados_mapoteca.t_cor(codigo_cor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

COMMENT ON TABLE dados_mapoteca.t_publicacao IS 'Tabela principal de publicações de mapas estaduais e regionais';
COMMENT ON COLUMN dados_mapoteca.t_publicacao.objectid IS 'Object ID para compatibilidade ESRI Feature Service';
COMMENT ON COLUMN dados_mapoteca.t_publicacao.globalid IS 'Global ID para replicação e sincronização ESRI';
COMMENT ON COLUMN dados_mapoteca.t_publicacao.status IS 'Status da publicação: ATIVO, INATIVO, RASCUNHO, ARQUIVADO';
COMMENT ON COLUMN dados_mapoteca.t_publicacao.visualizacoes IS 'Contador de visualizações';
COMMENT ON COLUMN dados_mapoteca.t_publicacao.downloads IS 'Contador de downloads do PDF';

-- ============================================================================
-- 2. TABELA: t_publicacao__attach (ESRI Attachments)
-- Descrição: Tabela de attachments (PDFs) para t_publicacao
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_publicacao__attach (
    attachmentid SERIAL PRIMARY KEY,
    globalid UUID DEFAULT uuid_generate_v4() UNIQUE,
    rel_objectid INTEGER NOT NULL,
    content_type VARCHAR(150) DEFAULT 'application/pdf',
    att_name VARCHAR(250) NOT NULL,
    data_size INTEGER NOT NULL,
    data BYTEA NOT NULL,
    keywords VARCHAR(2048),
    exifinfo VARCHAR(1024),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_attach_publicacao
        FOREIGN KEY (rel_objectid)
        REFERENCES dados_mapoteca.t_publicacao(objectid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_attach_content_type
        CHECK (content_type = 'application/pdf'),

    CONSTRAINT chk_attach_size
        CHECK (data_size > 0 AND data_size <= 52428800), -- Max 50MB

    CONSTRAINT chk_attach_name
        CHECK (att_name LIKE '%.pdf')
);

COMMENT ON TABLE dados_mapoteca.t_publicacao__attach IS 'Tabela de attachments ESRI para t_publicacao - Armazena PDFs';
COMMENT ON COLUMN dados_mapoteca.t_publicacao__attach.rel_objectid IS 'FK para t_publicacao.objectid';
COMMENT ON COLUMN dados_mapoteca.t_publicacao__attach.att_name IS 'Nome do arquivo PDF';
COMMENT ON COLUMN dados_mapoteca.t_publicacao__attach.data_size IS 'Tamanho do arquivo em bytes (max 50MB)';
COMMENT ON COLUMN dados_mapoteca.t_publicacao__attach.data IS 'Conteúdo binário do PDF';

-- ============================================================================
-- 3. TABELA: t_publicacao_municipios
-- Descrição: Publicações específicas de municípios
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_publicacao_municipios (
    id_publicacao_municipio SERIAL PRIMARY KEY,
    objectid INTEGER UNIQUE,
    globalid UUID DEFAULT uuid_generate_v4() UNIQUE,

    -- Relacionamentos
    id_municipio INTEGER NOT NULL,
    id_classe_mapa VARCHAR(2) NOT NULL,
    id_tipo_mapa VARCHAR(2) NOT NULL,
    id_ano INTEGER NOT NULL,
    id_tema INTEGER NOT NULL,
    id_tipo_tema VARCHAR(10) NOT NULL,
    codigo_escala VARCHAR(20) NOT NULL,
    codigo_cor VARCHAR(10) NOT NULL,

    -- Metadados
    titulo VARCHAR(255),
    descricao TEXT,
    observacoes TEXT,
    palavras_chave TEXT[],
    fonte_dados VARCHAR(255),
    metodologia TEXT,

    -- Controle
    status VARCHAR(20) DEFAULT 'ATIVO' CHECK (status IN ('ATIVO', 'INATIVO', 'RASCUNHO', 'ARQUIVADO')),
    visualizacoes INTEGER DEFAULT 0,
    downloads INTEGER DEFAULT 0,
    usuario_criacao VARCHAR(100),
    usuario_atualizacao VARCHAR(100),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_publicacao TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_pub_mun_municipio
        FOREIGN KEY (id_municipio)
        REFERENCES dados_mapoteca.t_municipios(id_municipio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_mun_classe_mapa
        FOREIGN KEY (id_classe_mapa)
        REFERENCES dados_mapoteca.t_classe_mapa(id_classe_mapa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_mun_tipo_mapa
        FOREIGN KEY (id_tipo_mapa)
        REFERENCES dados_mapoteca.t_tipo_mapa(id_tipo_mapa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_mun_ano
        FOREIGN KEY (id_ano)
        REFERENCES dados_mapoteca.t_anos(id_ano)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_mun_tema
        FOREIGN KEY (id_tema)
        REFERENCES dados_mapoteca.t_tema(id_tema)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_mun_tipo_tema
        FOREIGN KEY (id_tipo_tema)
        REFERENCES dados_mapoteca.t_tipo_tema(id_tipo_tema)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_mun_escala
        FOREIGN KEY (codigo_escala)
        REFERENCES dados_mapoteca.t_escala(codigo_escala)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_pub_mun_cor
        FOREIGN KEY (codigo_cor)
        REFERENCES dados_mapoteca.t_cor(codigo_cor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

COMMENT ON TABLE dados_mapoteca.t_publicacao_municipios IS 'Publicações específicas de municípios';
COMMENT ON COLUMN dados_mapoteca.t_publicacao_municipios.id_municipio IS 'FK para t_municipios';

-- ============================================================================
-- 4. TABELA: t_publicacao_municipios__attach
-- Descrição: Attachments para publicações municipais
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_publicacao_municipios__attach (
    attachmentid SERIAL PRIMARY KEY,
    globalid UUID DEFAULT uuid_generate_v4() UNIQUE,
    rel_objectid INTEGER NOT NULL,
    content_type VARCHAR(150) DEFAULT 'application/pdf',
    att_name VARCHAR(250) NOT NULL,
    data_size INTEGER NOT NULL,
    data BYTEA NOT NULL,
    keywords VARCHAR(2048),
    exifinfo VARCHAR(1024),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_attach_pub_municipios
        FOREIGN KEY (rel_objectid)
        REFERENCES dados_mapoteca.t_publicacao_municipios(objectid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT chk_attach_mun_content_type
        CHECK (content_type = 'application/pdf'),

    CONSTRAINT chk_attach_mun_size
        CHECK (data_size > 0 AND data_size <= 52428800),

    CONSTRAINT chk_attach_mun_name
        CHECK (att_name LIKE '%.pdf')
);

COMMENT ON TABLE dados_mapoteca.t_publicacao_municipios__attach IS 'Attachments para publicações municipais';

-- ============================================================================
-- Criar sequence para ObjectID (compatibilidade ESRI)
-- ============================================================================

CREATE SEQUENCE IF NOT EXISTS dados_mapoteca.seq_publicacao_objectid START 1;
CREATE SEQUENCE IF NOT EXISTS dados_mapoteca.seq_publicacao_mun_objectid START 1;

-- Trigger para gerar ObjectID automaticamente
CREATE OR REPLACE FUNCTION dados_mapoteca.generate_objectid_publicacao()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.objectid IS NULL THEN
        NEW.objectid = nextval('dados_mapoteca.seq_publicacao_objectid');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_objectid_publicacao
    BEFORE INSERT ON dados_mapoteca.t_publicacao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.generate_objectid_publicacao();

CREATE OR REPLACE FUNCTION dados_mapoteca.generate_objectid_pub_mun()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.objectid IS NULL THEN
        NEW.objectid = nextval('dados_mapoteca.seq_publicacao_mun_objectid');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_objectid_pub_mun
    BEFORE INSERT ON dados_mapoteca.t_publicacao_municipios
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.generate_objectid_pub_mun();

-- ============================================================================
-- Triggers de validação
-- ============================================================================

-- Validar classe + tipo em publicacao
CREATE TRIGGER validate_publicacao_classe_tipo
    BEFORE INSERT OR UPDATE
    ON dados_mapoteca.t_publicacao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.validate_classe_tipo();

-- Validar regionalização + região em publicacao
CREATE TRIGGER validate_publicacao_regionalizacao_regiao
    BEFORE INSERT OR UPDATE
    ON dados_mapoteca.t_publicacao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.validate_regionalizacao_regiao();

-- Validar tipo tema + tema em publicacao
CREATE TRIGGER validate_publicacao_tipo_tema_tema
    BEFORE INSERT OR UPDATE
    ON dados_mapoteca.t_publicacao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.validate_tipo_tema_tema();

-- Validar classe + tipo em publicacao_municipios
CREATE TRIGGER validate_pub_mun_classe_tipo
    BEFORE INSERT OR UPDATE
    ON dados_mapoteca.t_publicacao_municipios
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.validate_classe_tipo();

-- Validar tipo tema + tema em publicacao_municipios
CREATE TRIGGER validate_pub_mun_tipo_tema_tema
    BEFORE INSERT OR UPDATE
    ON dados_mapoteca.t_publicacao_municipios
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.validate_tipo_tema_tema();

-- ============================================================================
-- Triggers de timestamp
-- ============================================================================

CREATE TRIGGER update_t_publicacao_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_publicacao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_publicacao_municipios_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_publicacao_municipios
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

-- ============================================================================
-- Triggers de auditoria
-- ============================================================================

CREATE TRIGGER audit_publicacao
    AFTER INSERT OR UPDATE OR DELETE
    ON dados_mapoteca.t_publicacao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.log_audit();

CREATE TRIGGER audit_publicacao_municipios
    AFTER INSERT OR UPDATE OR DELETE
    ON dados_mapoteca.t_publicacao_municipios
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.log_audit();

-- ============================================================================
-- Índices
-- ============================================================================

-- Índices em t_publicacao
CREATE INDEX idx_pub_classe_mapa ON dados_mapoteca.t_publicacao(id_classe_mapa);
CREATE INDEX idx_pub_tipo_mapa ON dados_mapoteca.t_publicacao(id_tipo_mapa);
CREATE INDEX idx_pub_ano ON dados_mapoteca.t_publicacao(id_ano);
CREATE INDEX idx_pub_regiao ON dados_mapoteca.t_publicacao(id_regiao);
CREATE INDEX idx_pub_tema ON dados_mapoteca.t_publicacao(id_tema);
CREATE INDEX idx_pub_status ON dados_mapoteca.t_publicacao(status);
CREATE INDEX idx_pub_data_publicacao ON dados_mapoteca.t_publicacao(data_publicacao DESC);
CREATE INDEX idx_pub_usuario_criacao ON dados_mapoteca.t_publicacao(usuario_criacao);

-- Índices em t_publicacao__attach
CREATE INDEX idx_attach_rel_objectid ON dados_mapoteca.t_publicacao__attach(rel_objectid);
CREATE INDEX idx_attach_att_name ON dados_mapoteca.t_publicacao__attach(att_name);

-- Índices em t_publicacao_municipios
CREATE INDEX idx_pub_mun_municipio ON dados_mapoteca.t_publicacao_municipios(id_municipio);
CREATE INDEX idx_pub_mun_classe_mapa ON dados_mapoteca.t_publicacao_municipios(id_classe_mapa);
CREATE INDEX idx_pub_mun_tipo_mapa ON dados_mapoteca.t_publicacao_municipios(id_tipo_mapa);
CREATE INDEX idx_pub_mun_ano ON dados_mapoteca.t_publicacao_municipios(id_ano);
CREATE INDEX idx_pub_mun_tema ON dados_mapoteca.t_publicacao_municipios(id_tema);
CREATE INDEX idx_pub_mun_status ON dados_mapoteca.t_publicacao_municipios(status);

-- Índices em t_publicacao_municipios__attach
CREATE INDEX idx_attach_mun_rel_objectid ON dados_mapoteca.t_publicacao_municipios__attach(rel_objectid);

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Tabelas de publicações criadas com sucesso!';
    RAISE NOTICE 'Total: 4 tabelas (2 publicações + 2 attachments)';
    RAISE NOTICE 'Triggers de validação criados (classe+tipo, regionalização+região, tipo_tema+tema)';
    RAISE NOTICE 'Triggers de auditoria habilitados';
    RAISE NOTICE 'Índices de performance criados';
    RAISE NOTICE 'ESRI Attachments configurados (max 50MB por PDF)';
END $$;
