-- ============================================================================
-- Mapoteca Digital - Domain Tables (Lookup Tables)
-- ============================================================================
-- Versão: 1.0.0
-- Data: 2025-11-19
-- Descrição: Criação das tabelas de domínio (lookup tables)
-- Total: 9 tabelas
-- ============================================================================

SET search_path TO dados_mapoteca, public;

-- ============================================================================
-- 1. TABELA: t_classe_mapa
-- Descrição: Classificação principal dos tipos de representação cartográfica
-- Registros: 2 (Mapa, Cartograma)
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_classe_mapa (
    id_classe_mapa VARCHAR(2) PRIMARY KEY,
    nome_classe_mapa VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.t_classe_mapa IS 'Classificação principal dos tipos de representação cartográfica';
COMMENT ON COLUMN dados_mapoteca.t_classe_mapa.id_classe_mapa IS 'Identificador único (ex: 01, 02)';
COMMENT ON COLUMN dados_mapoteca.t_classe_mapa.nome_classe_mapa IS 'Nome da classe (ex: Mapa, Cartograma)';

-- ============================================================================
-- 2. TABELA: t_tipo_mapa
-- Descrição: Classificação por abrangência territorial
-- Registros: 3 (Estadual, Regional, Municipal)
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_tipo_mapa (
    id_tipo_mapa VARCHAR(2) PRIMARY KEY,
    nome_tipo_mapa VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.t_tipo_mapa IS 'Classificação por abrangência territorial dos mapas';
COMMENT ON COLUMN dados_mapoteca.t_tipo_mapa.id_tipo_mapa IS 'Identificador único (ex: 01, 02, 03)';
COMMENT ON COLUMN dados_mapoteca.t_tipo_mapa.nome_tipo_mapa IS 'Nome do tipo (ex: Estadual, Regional, Municipal)';

-- ============================================================================
-- 3. TABELA: t_anos
-- Descrição: Anos de referência dos mapas
-- Registros: 33 (1998-2030)
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_anos (
    id_ano SERIAL PRIMARY KEY,
    ano INTEGER NOT NULL UNIQUE CHECK (ano >= 1900 AND ano <= 2100),
    descricao VARCHAR(100),
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.t_anos IS 'Anos de referência disponíveis para os mapas';
COMMENT ON COLUMN dados_mapoteca.t_anos.ano IS 'Ano (ex: 2023)';

-- ============================================================================
-- 4. TABELA: t_escala
-- Descrição: Escalas cartográficas padrão
-- Registros: 9
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_escala (
    codigo_escala VARCHAR(20) PRIMARY KEY,
    nome_escala VARCHAR(50) NOT NULL UNIQUE,
    valor_numerico INTEGER,
    descricao TEXT,
    ordem INTEGER,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.t_escala IS 'Escalas cartográficas padrão utilizadas';
COMMENT ON COLUMN dados_mapoteca.t_escala.codigo_escala IS 'Código da escala (ex: 1:2.000.000)';
COMMENT ON COLUMN dados_mapoteca.t_escala.nome_escala IS 'Nome descritivo da escala';
COMMENT ON COLUMN dados_mapoteca.t_escala.valor_numerico IS 'Valor numérico para ordenação (ex: 2000000)';

-- ============================================================================
-- 5. TABELA: t_cor
-- Descrição: Esquemas de cores disponíveis
-- Registros: 2 (Colorido, Preto e Branco)
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_cor (
    codigo_cor VARCHAR(10) PRIMARY KEY,
    nome_cor VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.t_cor IS 'Esquemas de cores disponíveis para os mapas';
COMMENT ON COLUMN dados_mapoteca.t_cor.codigo_cor IS 'Código da cor (ex: COLOR, PB)';
COMMENT ON COLUMN dados_mapoteca.t_cor.nome_cor IS 'Nome do esquema (ex: Colorido, Preto e Branco)';

-- ============================================================================
-- 6. TABELA: t_tipo_regionalizacao
-- Descrição: Tipos de regionalização territorial
-- Registros: 11
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_tipo_regionalizacao (
    id_tipo_regionalizacao VARCHAR(10) PRIMARY KEY,
    nome_tipo_regionalizacao VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    numero_regioes INTEGER,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.t_tipo_regionalizacao IS 'Métodos e critérios de regionalização territorial';
COMMENT ON COLUMN dados_mapoteca.t_tipo_regionalizacao.id_tipo_regionalizacao IS 'Identificador único (ex: TRG01, TRG02)';
COMMENT ON COLUMN dados_mapoteca.t_tipo_regionalizacao.numero_regioes IS 'Número total de regiões deste tipo';

-- ============================================================================
-- 7. TABELA: t_regiao
-- Descrição: Unidades geográficas regionais
-- Registros: 106
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_regiao (
    id_regiao VARCHAR(10) PRIMARY KEY,
    nome_regiao VARCHAR(100) NOT NULL,
    abrangencia VARCHAR(50),
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.t_regiao IS 'Unidades geográficas com diferentes níveis de granularidade';
COMMENT ON COLUMN dados_mapoteca.t_regiao.id_regiao IS 'Identificador único da região';
COMMENT ON COLUMN dados_mapoteca.t_regiao.abrangencia IS 'Tipo de abrangência da região';

-- ============================================================================
-- 8. TABELA: t_tipo_tema
-- Descrição: Categorias principais de temas
-- Registros: 6
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_tipo_tema (
    id_tipo_tema VARCHAR(10) PRIMARY KEY,
    codigo_tipo_tema VARCHAR(10) NOT NULL,
    nome_tipo_tema VARCHAR(100) NOT NULL UNIQUE,
    descricao TEXT,
    ordem INTEGER,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.t_tipo_tema IS 'Categorias principais para agrupamento de temas';
COMMENT ON COLUMN dados_mapoteca.t_tipo_tema.codigo_tipo_tema IS 'Código abreviado (ex: CT, PA, FA)';
COMMENT ON COLUMN dados_mapoteca.t_tipo_tema.nome_tipo_tema IS 'Nome do tipo (ex: Cartografia, Político-Administrativo)';

-- ============================================================================
-- 9. TABELA: t_tema
-- Descrição: Temas específicos dos mapas
-- Registros: 55
-- ============================================================================

CREATE TABLE IF NOT EXISTS dados_mapoteca.t_tema (
    id_tema SERIAL PRIMARY KEY,
    codigo_tema VARCHAR(20) NOT NULL UNIQUE,
    nome_tema VARCHAR(100) NOT NULL,
    descricao TEXT,
    ordem INTEGER,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dados_mapoteca.t_tema IS 'Temáticas específicas abordadas nos mapas';
COMMENT ON COLUMN dados_mapoteca.t_tema.codigo_tema IS 'Código único do tema';
COMMENT ON COLUMN dados_mapoteca.t_tema.nome_tema IS 'Nome descritivo do tema';

-- ============================================================================
-- Criar triggers para atualização automática de timestamp
-- ============================================================================

CREATE TRIGGER update_t_classe_mapa_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_classe_mapa
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_tipo_mapa_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_tipo_mapa
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_anos_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_anos
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_escala_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_escala
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_cor_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_cor
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_tipo_regionalizacao_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_tipo_regionalizacao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_regiao_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_regiao
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_tipo_tema_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_tipo_tema
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

CREATE TRIGGER update_t_tema_timestamp
    BEFORE UPDATE ON dados_mapoteca.t_tema
    FOR EACH ROW
    EXECUTE FUNCTION dados_mapoteca.update_timestamp();

-- ============================================================================
-- Criar índices para performance
-- ============================================================================

CREATE INDEX idx_t_anos_ano ON dados_mapoteca.t_anos(ano);
CREATE INDEX idx_t_escala_valor ON dados_mapoteca.t_escala(valor_numerico);
CREATE INDEX idx_t_regiao_nome ON dados_mapoteca.t_regiao(nome_regiao);
CREATE INDEX idx_t_tema_nome ON dados_mapoteca.t_tema(nome_tema);
CREATE INDEX idx_t_tema_codigo ON dados_mapoteca.t_tema(codigo_tema);

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Tabelas de domínio criadas com sucesso!';
    RAISE NOTICE 'Total: 9 tabelas';
    RAISE NOTICE 'Triggers de timestamp criados.';
    RAISE NOTICE 'Índices de performance criados.';
END $$;
