-- ===================================================================================
-- Mapoteca Digital - Script 02: População de Dados Iniciais (CORRIGIDO)
-- ===================================================================================
-- Descrição: População das 18 tabelas com dados base da Mapoteca Digital
-- Ambiente: Oracle Linux (10.28.246.75) | PostgreSQL 14+ | ESRI SDE
-- Usuário: dados_mapoteca | Schema: dados_mapoteca
-- Data: 2025-11-17
-- Versão: 2.0 (CORRIGIDO - Nomenclatura com prefixo t_)
-- Dependências: Script 01-setup-schema-CORRECTED.sql deve ser executado primeiro
-- ===================================================================================

-- Configuração do ambiente
\set ON_ERROR_STOP on
SET client_min_messages TO WARNING;
SET search_path TO dados_mapoteca, public;

-- ===================================================================================
-- 1. CAMADA 1 - TABELAS DE DOMÍNIO
-- ===================================================================================

-- 1.1. t_classe_mapa (2 registros)
INSERT INTO dados_mapoteca.t_classe_mapa (id_classe_mapa, nome_classe_mapa) VALUES
('01', 'Mapa'),
('02', 'Cartograma');

SELECT 't_classe_mapa' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_classe_mapa;

-- 1.2. t_tipo_mapa (3 registros)
INSERT INTO dados_mapoteca.t_tipo_mapa (id_tipo_mapa, nome_tipo_mapa) VALUES
('01', 'Estadual'),
('02', 'Regional'),
('03', 'Municipal');

SELECT 't_tipo_mapa' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_tipo_mapa;

-- 1.3. t_anos (33 registros - 1998 a 2030)
INSERT INTO dados_mapoteca.t_anos (id_ano, ano)
SELECT
    LPAD(ano::TEXT, 4, '0'),
    ano
FROM generate_series(1998, 2030) AS ano;

SELECT 't_anos' as tabela, COUNT(*) as registros, MIN(ano) as ano_min, MAX(ano) as ano_max
FROM dados_mapoteca.t_anos;

-- 1.4. t_escala (9 registros)
INSERT INTO dados_mapoteca.t_escala (codigo_escala, nome_escala) VALUES
('1:25.000', 'Escala 1:25.000'),
('1:50.000', 'Escala 1:50.000'),
('1:100.000', 'Escala 1:100.000'),
('1:250.000', 'Escala 1:250.000'),
('1:500.000', 'Escala 1:500.000'),
('1:750.000', 'Escala 1:750.000'),
('1:1.000.000', 'Escala 1:1.000.000'),
('1:2.000.000', 'Escala 1:2.000.000'),
('1:2.500.000', 'Escala 1:2.500.000');

SELECT 't_escala' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_escala;

-- 1.5. t_cor (2 registros)
INSERT INTO dados_mapoteca.t_cor (codigo_cor, nome_cor) VALUES
('COLOR', 'Colorido'),
('PB', 'Preto e Branco');

SELECT 't_cor' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_cor;

-- 1.6. t_tipo_tema (6 registros)
INSERT INTO dados_mapoteca.t_tipo_tema (id_tipo_tema, codigo_tipo_tema, nome_tipo_tema) VALUES
('TTM01', 'CT', 'Cartografia'),
('TTM02', 'PA', 'Político-Administrativo'),
('TTM03', 'FA', 'Físico-Ambiental'),
('TTM04', 'RG', 'Regionalização'),
('TTM05', 'SE', 'Socioeconômico'),
('TTM06', 'IF', 'Infraestrutura');

SELECT 't_tipo_tema' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_tipo_tema;

-- 1.7. t_tipo_regionalizacao (11 registros)
INSERT INTO dados_mapoteca.t_tipo_regionalizacao (id_tipo_regionalizacao, nome_tipo_regionalizacao) VALUES
('TRG01', 'Estadual'),
('TRG02', 'Mesorregiões Geográficas'),
('TRG03', 'Microrregiões Geográficas'),
('TRG04', 'Regiões Econômicas'),
('TRG05', 'Territórios de Identidade'),
('TRG06', 'Região Metropolitana'),
('TRG07', 'Regiões de Planejamento'),
('TRG08', 'Regiões de Saúde'),
('TRG09', 'Eixos de Desenvolvimento'),
('TRG10', 'Regiões Administrativas'),
('TRG11', 'Bacias Hidrográficas');

SELECT 't_tipo_regionalizacao' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_tipo_regionalizacao;

-- 1.8. t_regiao (106 registros - Amostra inicial, restante via CSV)
INSERT INTO dados_mapoteca.t_regiao (id_regiao, nome_regiao, abrangencia) VALUES
('REG001', 'Bahia', 'Estadual'),
('REG002', 'Região Metropolitana de Salvador', 'Metropolitana'),
('REG003', 'Norte Baiano', 'Macrorregião'),
('REG004', 'Sul Baiano', 'Macrorregião'),
('REG005', 'Oeste Baiano', 'Macrorregião'),
('REG006', 'Centro-Sul Baiano', 'Macrorregião'),
('REG007', 'Litoral Norte', 'Regional'),
('REG008', 'Litoral Sul', 'Regional'),
('REG009', 'Extremo Sul', 'Regional'),
('REG010', 'Recôncavo', 'Regional');

-- Nota: Os demais 96 registros de regiões devem ser importados via CSV ou script adicional

SELECT 't_regiao' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_regiao;

-- 1.9. t_tema (55 registros - Amostra, restante via CSV)
INSERT INTO dados_mapoteca.t_tema (codigo_tema, nome_tema) VALUES
('TEM001', 'Articulação de Folha Cartográfica'),
('TEM002', 'Divisão Político-Administrativa'),
('TEM003', 'Sedes dos Municípios'),
('TEM004', 'Geologia'),
('TEM005', 'Solos'),
('TEM006', 'Relevo'),
('TEM007', 'Biomas'),
('TEM008', 'Bacias Hidrográficas'),
('TEM009', 'Uso e Cobertura da Terra'),
('TEM010', 'Vegetação'),
('TEM011', 'Clima'),
('TEM012', 'Hidrografia'),
('TEM013', 'Recursos Minerais'),
('TEM014', 'Unidades de Conservação'),
('TEM015', 'População'),
('TEM016', 'PIB Municipal'),
('TEM017', 'PIB Per Capita'),
('TEM018', 'ICMS'),
('TEM019', 'FPM'),
('TEM020', 'Infraestrutura de Transportes');

-- Nota: Os demais 35 registros devem ser importados via CSV

SELECT 't_tema' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_tema;

-- ===================================================================================
-- 2. CAMADA 3 - RELACIONAMENTOS N:N
-- ===================================================================================

-- 2.1. t_classe_mapa_tipo_mapa (6 combinações)
-- Todas as 6 combinações são válidas conforme PRD
INSERT INTO dados_mapoteca.t_classe_mapa_tipo_mapa (id_classe_mapa, id_tipo_mapa) VALUES
('01', '01'),  -- Mapa Estadual
('01', '02'),  -- Mapa Regional
('01', '03'),  -- Mapa Municipal
('02', '01'),  -- Cartograma Estadual
('02', '02'),  -- Cartograma Regional
('02', '03');  -- Cartograma Municipal

SELECT 't_classe_mapa_tipo_mapa' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_classe_mapa_tipo_mapa;

-- Verificar combinações válidas
SELECT
    cm.nome_classe_mapa,
    tm.nome_tipo_mapa,
    cm.nome_classe_mapa || ' - ' || tm.nome_tipo_mapa as tipo_publicacao
FROM dados_mapoteca.t_classe_mapa_tipo_mapa cmtm
JOIN dados_mapoteca.t_classe_mapa cm ON cmtm.id_classe_mapa = cm.id_classe_mapa
JOIN dados_mapoteca.t_tipo_mapa tm ON cmtm.id_tipo_mapa = tm.id_tipo_mapa
ORDER BY cm.id_classe_mapa, tm.id_tipo_mapa;

-- 2.2. t_tipo_tema_tema (55 registros - associar temas aos tipos)
-- Exemplos de associações (simplificado)
INSERT INTO dados_mapoteca.t_tipo_tema_tema (id_tipo_tema, id_tema) VALUES
('TTM01', 1),  -- Cartografia: Articulação
('TTM02', 2),  -- Político-Administrativo: Divisão Político-Administrativa
('TTM02', 3),  -- Político-Administrativo: Sedes dos Municípios
('TTM03', 4),  -- Físico-Ambiental: Geologia
('TTM03', 5),  -- Físico-Ambiental: Solos
('TTM03', 6),  -- Físico-Ambiental: Relevo
('TTM03', 7),  -- Físico-Ambiental: Biomas
('TTM03', 8),  -- Físico-Ambiental: Bacias Hidrográficas
('TTM03', 9),  -- Físico-Ambiental: Uso e Cobertura
('TTM03', 10), -- Físico-Ambiental: Vegetação
('TTM03', 11), -- Físico-Ambiental: Clima
('TTM03', 12), -- Físico-Ambiental: Hidrografia
('TTM03', 13), -- Físico-Ambiental: Recursos Minerais
('TTM03', 14), -- Físico-Ambiental: Unidades de Conservação
('TTM05', 15), -- Socioeconômico: População
('TTM05', 16), -- Socioeconômico: PIB Municipal
('TTM05', 17), -- Socioeconômico: PIB Per Capita
('TTM05', 18), -- Socioeconômico: ICMS
('TTM05', 19), -- Socioeconômico: FPM
('TTM06', 20); -- Infraestrutura: Transportes

-- Nota: Os demais relacionamentos devem ser importados via CSV

SELECT 't_tipo_tema_tema' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_tipo_tema_tema;

-- 2.3. t_regionalizacao_regiao (229 registros - associar regiões aos tipos)
-- Exemplos iniciais
INSERT INTO dados_mapoteca.t_regionalizacao_regiao (id_tipo_regionalizacao, id_regiao) VALUES
('TRG01', 'REG001'),  -- Estadual: Bahia
('TRG06', 'REG002'),  -- RM: Salvador
('TRG03', 'REG003'),  -- Microrregiões: Norte
('TRG03', 'REG004'),  -- Microrregiões: Sul
('TRG03', 'REG005'),  -- Microrregiões: Oeste
('TRG03', 'REG006'),  -- Microrregiões: Centro-Sul
('TRG04', 'REG007'),  -- Econômicas: Litoral Norte
('TRG04', 'REG008'),  -- Econômicas: Litoral Sul
('TRG04', 'REG009'),  -- Econômicas: Extremo Sul
('TRG04', 'REG010'); -- Econômicas: Recôncavo

-- Nota: Os demais 219 relacionamentos devem ser importados via CSV

SELECT 't_regionalizacao_regiao' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_regionalizacao_regiao;

-- ===================================================================================
-- 3. VALIDAÇÃO FINAL DOS DADOS POPULADOS
-- ===================================================================================

-- Resumo geral
SELECT
    'RESUMO DA POPULAÇÃO DE DADOS' as descricao,
    'Script 02 concluído com sucesso' as status;

-- Estatísticas por tabela
SELECT
    'ESTATÍSTICAS DAS TABELAS' as categoria,
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = 'dados_mapoteca' AND table_name = t.table_name) as total_colunas
FROM information_schema.tables t
WHERE t.table_schema = 'dados_mapoteca'
ORDER BY table_name;

-- Contagem de registros por tabela
SELECT 't_classe_mapa' as tabela, COUNT(*) as registros FROM dados_mapoteca.t_classe_mapa
UNION ALL
SELECT 't_tipo_mapa', COUNT(*) FROM dados_mapoteca.t_tipo_mapa
UNION ALL
SELECT 't_anos', COUNT(*) FROM dados_mapoteca.t_anos
UNION ALL
SELECT 't_escala', COUNT(*) FROM dados_mapoteca.t_escala
UNION ALL
SELECT 't_cor', COUNT(*) FROM dados_mapoteca.t_cor
UNION ALL
SELECT 't_tipo_tema', COUNT(*) FROM dados_mapoteca.t_tipo_tema
UNION ALL
SELECT 't_tipo_regionalizacao', COUNT(*) FROM dados_mapoteca.t_tipo_regionalizacao
UNION ALL
SELECT 't_regiao', COUNT(*) FROM dados_mapoteca.t_regiao
UNION ALL
SELECT 't_tema', COUNT(*) FROM dados_mapoteca.t_tema
UNION ALL
SELECT 't_classe_mapa_tipo_mapa', COUNT(*) FROM dados_mapoteca.t_classe_mapa_tipo_mapa
UNION ALL
SELECT 't_tipo_tema_tema', COUNT(*) FROM dados_mapoteca.t_tipo_tema_tema
UNION ALL
SELECT 't_regionalizacao_regiao', COUNT(*) FROM dados_mapoteca.t_regionalizacao_regiao
ORDER BY tabela;

-- Verificar integridade referencial
SELECT
    'VERIFICAÇÃO DE INTEGRIDADE' as categoria,
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'dados_mapoteca'
AND tc.constraint_type IN ('FOREIGN KEY', 'PRIMARY KEY', 'UNIQUE')
ORDER BY tc.table_name, tc.constraint_type;

-- Fim do Script 02 (CORRIGIDO)
-- ===================================================================================
-- ✅ Dados populados com sucesso:
-- ✓ t_classe_mapa: 2 registros
-- ✓ t_tipo_mapa: 3 registros
-- ✓ t_anos: 33 registros
-- ✓ t_escala: 9 registros
-- ✓ t_cor: 2 registros
-- ✓ t_tipo_tema: 6 registros
-- ✓ t_tipo_regionalizacao: 11 registros
-- ✓ t_regiao: 10+ registros (restante via CSV)
-- ✓ t_tema: 20+ registros (restante via CSV)
-- ✓ t_classe_mapa_tipo_mapa: 6 registros
-- ✓ t_tipo_tema_tema: 20+ registros (restante via CSV)
-- ✓ t_regionalizacao_regiao: 10+ registros (restante via CSV)
-- ===================================================================================
-- NOTA: Arquivos CSV adicionais devem ser importados para completar:
--   - t_municipios (417 registros)
--   - t_regiao (96 registros restantes)
--   - t_tema (35 registros restantes)
--   - Relacionamentos N:N completos
-- ===================================================================================
