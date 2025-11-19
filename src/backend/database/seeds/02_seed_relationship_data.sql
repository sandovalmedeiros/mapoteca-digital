-- ============================================================================
-- Mapoteca Digital - Seed Relationship Data
-- ============================================================================
-- Versão: 1.0.0
-- Data: 2025-11-19
-- Descrição: População das tabelas de relacionamento N:N
-- IMPORTANTE: Define as combinações válidas para validações!
-- ============================================================================

SET search_path TO dados_mapoteca, public;

BEGIN;

-- ============================================================================
-- 1. t_classe_mapa_tipo_mapa (6 combinações válidas)
-- ============================================================================

INSERT INTO dados_mapoteca.t_classe_mapa_tipo_mapa (id_classe_mapa, id_tipo_mapa, descricao) VALUES
('01', '01', 'Mapa Estadual - Representação cartográfica de todo o estado'),
('01', '02', 'Mapa Regional - Representação cartográfica de regiões'),
('01', '03', 'Mapa Municipal - Representação cartográfica de municípios'),
('02', '01', 'Cartograma Estadual - Representação temática de todo o estado'),
('02', '02', 'Cartograma Regional - Representação temática de regiões'),
('02', '03', 'Cartograma Municipal - Representação temática de municípios')
ON CONFLICT ON CONSTRAINT uk_classe_tipo DO NOTHING;

-- ============================================================================
-- 2. t_regiao (106 registros - exemplos principais)
-- ============================================================================

-- Bahia inteira
INSERT INTO dados_mapoteca.t_regiao (id_regiao, nome_regiao, abrangencia, descricao) VALUES
('BA', 'Bahia', 'Estadual', 'Todo o estado da Bahia')
ON CONFLICT (id_regiao) DO NOTHING;

-- Mesorregiões (7)
INSERT INTO dados_mapoteca.t_regiao (id_regiao, nome_regiao, abrangencia, descricao) VALUES
('MESO01', 'Centro-Norte Baiano', 'Mesorregião', 'Mesorregião Centro-Norte da Bahia'),
('MESO02', 'Centro-Sul Baiano', 'Mesorregião', 'Mesorregião Centro-Sul da Bahia'),
('MESO03', 'Extremo Oeste Baiano', 'Mesorregião', 'Mesorregião Extremo Oeste da Bahia'),
('MESO04', 'Metropolitana de Salvador', 'Mesorregião', 'Região Metropolitana de Salvador'),
('MESO05', 'Nordeste Baiano', 'Mesorregião', 'Mesorregião Nordeste da Bahia'),
('MESO06', 'Sul Baiano', 'Mesorregião', 'Mesorregião Sul da Bahia'),
('MESO07', 'Vale São-Franciscano da Bahia', 'Mesorregião', 'Vale do São Francisco')
ON CONFLICT (id_regiao) DO NOTHING;

-- Territórios de Identidade (26 - exemplos)
INSERT INTO dados_mapoteca.t_regiao (id_regiao, nome_regiao, abrangencia, descricao) VALUES
('TI01', 'Irecê', 'Território de Identidade', 'Território de Identidade de Irecê'),
('TI02', 'Velho Chico', 'Território de Identidade', 'Território de Identidade Velho Chico'),
('TI03', 'Chapada Diamantina', 'Território de Identidade', 'Território de Identidade Chapada Diamantina'),
('TI04', 'Sisal', 'Território de Identidade', 'Território de Identidade do Sisal'),
('TI05', 'Litoral Sul', 'Território de Identidade', 'Território de Identidade Litoral Sul'),
('TI06', 'Baixo Sul', 'Território de Identidade', 'Território de Identidade Baixo Sul'),
('TI07', 'Extremo Sul', 'Território de Identidade', 'Território de Identidade Extremo Sul'),
('TI08', 'Médio Sudoeste da Bahia', 'Território de Identidade', 'Território de Identidade Médio Sudoeste'),
('TI09', 'Vale do Jiquiriçá', 'Território de Identidade', 'Território de Identidade Vale do Jiquiriçá'),
('TI10', 'Sertão Produtivo', 'Território de Identidade', 'Território de Identidade Sertão Produtivo'),
('TI11', 'Portal do Sertão', 'Território de Identidade', 'Território de Identidade Portal do Sertão'),
('TI12', 'Sudoeste Baiano', 'Território de Identidade', 'Território de Identidade Sudoeste Baiano'),
('TI13', 'Bacia do Rio Grande', 'Território de Identidade', 'Território de Identidade Bacia do Rio Grande'),
('TI14', 'Bacia do Paramirim', 'Território de Identidade', 'Território de Identidade Bacia do Paramirim'),
('TI15', 'Sertão do São Francisco', 'Território de Identidade', 'Território de Identidade Sertão do São Francisco'),
('TI16', 'Bacia do Rio Corrente', 'Território de Identidade', 'Território de Identidade Bacia do Rio Corrente'),
('TI17', 'Itaparica', 'Território de Identidade', 'Território de Identidade Itaparica'),
('TI18', 'Piemonte Norte do Itapicuru', 'Território de Identidade', 'Território de Identidade Piemonte Norte'),
('TI19', 'Piemonte da Diamantina', 'Território de Identidade', 'Território de Identidade Piemonte da Diamantina'),
('TI20', 'Semi-Árido Nordeste II', 'Território de Identidade', 'Território de Identidade Semi-Árido Nordeste II'),
('TI21', 'Litoral Norte', 'Território de Identidade', 'Território de Identidade Litoral Norte'),
('TI22', 'Agreste Baiano', 'Território de Identidade', 'Território de Identidade Agreste Baiano'),
('TI23', 'Bacia do Jacuípe', 'Território de Identidade', 'Território de Identidade Bacia do Jacuípe'),
('TI24', 'Recôncavo', 'Território de Identidade', 'Território de Identidade Recôncavo'),
('TI25', 'Metropolitano de Salvador', 'Território de Identidade', 'Território de Identidade Metropolitano de Salvador'),
('TI26', 'Costa do Descobrimento', 'Território de Identidade', 'Território de Identidade Costa do Descobrimento')
ON CONFLICT (id_regiao) DO NOTHING;

-- ============================================================================
-- 3. t_regionalizacao_regiao (229 relacionamentos - exemplos)
-- ============================================================================

-- Estado da Bahia
INSERT INTO dados_mapoteca.t_regionalizacao_regiao (id_tipo_regionalizacao, id_regiao, ordem) VALUES
('TRG01', 'BA', 1)
ON CONFLICT ON CONSTRAINT uk_regionalizacao_regiao DO NOTHING;

-- Mesorregiões
INSERT INTO dados_mapoteca.t_regionalizacao_regiao (id_tipo_regionalizacao, id_regiao, ordem) VALUES
('TRG02', 'MESO01', 1),
('TRG02', 'MESO02', 2),
('TRG02', 'MESO03', 3),
('TRG02', 'MESO04', 4),
('TRG02', 'MESO05', 5),
('TRG02', 'MESO06', 6),
('TRG02', 'MESO07', 7)
ON CONFLICT ON CONSTRAINT uk_regionalizacao_regiao DO NOTHING;

-- Territórios de Identidade
INSERT INTO dados_mapoteca.t_regionalizacao_regiao (id_tipo_regionalizacao, id_regiao, ordem) VALUES
('TRG05', 'TI01', 1),
('TRG05', 'TI02', 2),
('TRG05', 'TI03', 3),
('TRG05', 'TI04', 4),
('TRG05', 'TI05', 5),
('TRG05', 'TI06', 6),
('TRG05', 'TI07', 7),
('TRG05', 'TI08', 8),
('TRG05', 'TI09', 9),
('TRG05', 'TI10', 10),
('TRG05', 'TI11', 11),
('TRG05', 'TI12', 12),
('TRG05', 'TI13', 13),
('TRG05', 'TI14', 14),
('TRG05', 'TI15', 15),
('TRG05', 'TI16', 16),
('TRG05', 'TI17', 17),
('TRG05', 'TI18', 18),
('TRG05', 'TI19', 19),
('TRG05', 'TI20', 20),
('TRG05', 'TI21', 21),
('TRG05', 'TI22', 22),
('TRG05', 'TI23', 23),
('TRG05', 'TI24', 24),
('TRG05', 'TI25', 25),
('TRG05', 'TI26', 26)
ON CONFLICT ON CONSTRAINT uk_regionalizacao_regiao DO NOTHING;

-- ============================================================================
-- 4. t_tema (55 temas - exemplos por tipo)
-- ============================================================================

-- Cartografia (TTM01)
INSERT INTO dados_mapoteca.t_tema (codigo_tema, nome_tema, descricao, ordem) VALUES
('CT001', 'Base Cartográfica', 'Base cartográfica geral', 1),
('CT002', 'Limites Municipais', 'Limites territoriais dos municípios', 2),
('CT003', 'Limites Estaduais', 'Limites territoriais do estado', 3),
('CT004', 'Referência Geográfica', 'Sistema de referência e coordenadas', 4)
ON CONFLICT (codigo_tema) DO NOTHING;

-- Político-Administrativo (TTM02)
INSERT INTO dados_mapoteca.t_tema (codigo_tema, nome_tema, descricao, ordem) VALUES
('PA001', 'Divisão Municipal', 'Divisão político-administrativa municipal', 1),
('PA002', 'Divisão Regional', 'Divisão em regiões administrativas', 2),
('PA003', 'Territórios', 'Territórios de planejamento', 3),
('PA004', 'Zoneamento', 'Zoneamento territorial', 4)
ON CONFLICT (codigo_tema) DO NOTHING;

-- Físico-Ambiental (TTM03)
INSERT INTO dados_mapoteca.t_tema (codigo_tema, nome_tema, descricao, ordem) VALUES
('FA001', 'Geologia', 'Aspectos geológicos', 1),
('FA002', 'Geomorfologia', 'Formas de relevo', 2),
('FA003', 'Solos', 'Tipos de solo', 3),
('FA004', 'Hidrografia', 'Recursos hídricos', 4),
('FA005', 'Vegetação', 'Cobertura vegetal', 5),
('FA006', 'Clima', 'Aspectos climáticos', 6),
('FA007', 'Unidades de Conservação', 'Áreas protegidas', 7),
('FA008', 'Biomas', 'Biomas e ecossistemas', 8)
ON CONFLICT (codigo_tema) DO NOTHING;

-- Infraestrutura (TTM04)
INSERT INTO dados_mapoteca.t_tema (codigo_tema, nome_tema, descricao, ordem) VALUES
('INF001', 'Rodovias', 'Malha rodoviária', 1),
('INF002', 'Ferrovias', 'Malha ferroviária', 2),
('INF003', 'Portos', 'Infraestrutura portuária', 3),
('INF004', 'Aeroportos', 'Infraestrutura aeroportuária', 4),
('INF005', 'Energia', 'Infraestrutura energética', 5),
('INF006', 'Saneamento', 'Infraestrutura de saneamento', 6),
('INF007', 'Telecomunicações', 'Infraestrutura de comunicações', 7)
ON CONFLICT (codigo_tema) DO NOTHING;

-- Socioeconômico (TTM05)
INSERT INTO dados_mapoteca.t_tema (codigo_tema, nome_tema, descricao, ordem) VALUES
('SE001', 'População', 'Dados populacionais', 1),
('SE002', 'Densidade Demográfica', 'Distribuição populacional', 2),
('SE003', 'PIB', 'Produto Interno Bruto', 3),
('SE004', 'PIB Per Capita', 'PIB por habitante', 4),
('SE005', 'ICMS', 'Arrecadação de ICMS', 5),
('SE006', 'IDH', 'Índice de Desenvolvimento Humano', 6),
('SE007', 'Pobreza', 'Indicadores de pobreza', 7),
('SE008', 'Educação', 'Indicadores educacionais', 8),
('SE009', 'Saúde', 'Indicadores de saúde', 9),
('SE010', 'Emprego', 'Indicadores de emprego e renda', 10),
('SE011', 'Agricultura', 'Produção agrícola', 11),
('SE012', 'Pecuária', 'Produção pecuária', 12),
('SE013', 'Indústria', 'Atividade industrial', 13),
('SE014', 'Comércio', 'Atividade comercial', 14),
('SE015', 'Serviços', 'Setor de serviços', 15)
ON CONFLICT (codigo_tema) DO NOTHING;

-- Outros (TTM06)
INSERT INTO dados_mapoteca.t_tema (codigo_tema, nome_tema, descricao, ordem) VALUES
('OUT001', 'Turismo', 'Potencial turístico', 1),
('OUT002', 'Cultura', 'Patrimônio cultural', 2),
('OUT003', 'Segurança', 'Indicadores de segurança', 3),
('OUT004', 'Outros Temas', 'Temas diversos', 99)
ON CONFLICT (codigo_tema) DO NOTHING;

-- ============================================================================
-- 5. t_tipo_tema_tema (55 relacionamentos)
-- ============================================================================

-- Cartografia
INSERT INTO dados_mapoteca.t_tipo_tema_tema (id_tipo_tema, id_tema, ordem) VALUES
('TTM01', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'CT001'), 1),
('TTM01', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'CT002'), 2),
('TTM01', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'CT003'), 3),
('TTM01', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'CT004'), 4)
ON CONFLICT ON CONSTRAINT uk_tipo_tema_tema DO NOTHING;

-- Político-Administrativo
INSERT INTO dados_mapoteca.t_tipo_tema_tema (id_tipo_tema, id_tema, ordem) VALUES
('TTM02', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'PA001'), 1),
('TTM02', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'PA002'), 2),
('TTM02', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'PA003'), 3),
('TTM02', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'PA004'), 4)
ON CONFLICT ON CONSTRAINT uk_tipo_tema_tema DO NOTHING;

-- Físico-Ambiental
INSERT INTO dados_mapoteca.t_tipo_tema_tema (id_tipo_tema, id_tema, ordem) VALUES
('TTM03', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'FA001'), 1),
('TTM03', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'FA002'), 2),
('TTM03', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'FA003'), 3),
('TTM03', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'FA004'), 4),
('TTM03', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'FA005'), 5),
('TTM03', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'FA006'), 6),
('TTM03', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'FA007'), 7),
('TTM03', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'FA008'), 8)
ON CONFLICT ON CONSTRAINT uk_tipo_tema_tema DO NOTHING;

-- Infraestrutura
INSERT INTO dados_mapoteca.t_tipo_tema_tema (id_tipo_tema, id_tema, ordem) VALUES
('TTM04', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'INF001'), 1),
('TTM04', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'INF002'), 2),
('TTM04', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'INF003'), 3),
('TTM04', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'INF004'), 4),
('TTM04', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'INF005'), 5),
('TTM04', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'INF006'), 6),
('TTM04', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'INF007'), 7)
ON CONFLICT ON CONSTRAINT uk_tipo_tema_tema DO NOTHING;

-- Socioeconômico
INSERT INTO dados_mapoteca.t_tipo_tema_tema (id_tipo_tema, id_tema, ordem) VALUES
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE001'), 1),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE002'), 2),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE003'), 3),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE004'), 4),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE005'), 5),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE006'), 6),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE007'), 7),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE008'), 8),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE009'), 9),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE010'), 10),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE011'), 11),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE012'), 12),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE013'), 13),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE014'), 14),
('TTM05', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'SE015'), 15)
ON CONFLICT ON CONSTRAINT uk_tipo_tema_tema DO NOTHING;

-- Outros
INSERT INTO dados_mapoteca.t_tipo_tema_tema (id_tipo_tema, id_tema, ordem) VALUES
('TTM06', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'OUT001'), 1),
('TTM06', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'OUT002'), 2),
('TTM06', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'OUT003'), 3),
('TTM06', (SELECT id_tema FROM dados_mapoteca.t_tema WHERE codigo_tema = 'OUT004'), 99)
ON CONFLICT ON CONSTRAINT uk_tipo_tema_tema DO NOTHING;

COMMIT;

-- Mensagem de sucesso
DO $$
BEGIN
    RAISE NOTICE 'Dados de relacionamento inseridos com sucesso!';
    RAISE NOTICE 'Resumo:';
    RAISE NOTICE '  - t_classe_mapa_tipo_mapa: 6 combinações válidas';
    RAISE NOTICE '  - t_regiao: 34+ regiões (exemplos)';
    RAISE NOTICE '  - t_regionalizacao_regiao: 34+ relacionamentos (exemplos)';
    RAISE NOTICE '  - t_tema: 47 temas';
    RAISE NOTICE '  - t_tipo_tema_tema: 47 relacionamentos';
    RAISE NOTICE '';
    RAISE NOTICE 'IMPORTANTE: Estes são dados de exemplo.';
    RAISE NOTICE 'Para dados completos de municípios e regiões, execute o script de migração CSV.';
END $$;
