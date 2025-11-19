#!/usr/bin/env python3
"""
============================================================================
Mapoteca Digital - CSV Migration Script
============================================================================
Versão: 1.0.0
Data: 2025-11-19
Autor: SEIGEO - SEI-BA
Descrição: Script para migração de dados CSV para PostgreSQL
============================================================================
"""

import os
import sys
import csv
import psycopg2
from psycopg2 import sql
from psycopg2.extras import execute_values
import argparse
from datetime import datetime
import logging

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f'migration_{datetime.now().strftime("%Y%m%d_%H%M%S")}.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)

# ============================================================================
# CONFIGURAÇÃO
# ============================================================================

DB_CONFIG = {
    'dbname': os.getenv('DB_NAME', 'mapoteca'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', ''),
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432')
}

CSV_DIR = os.getenv('CSV_DIR', './data/csv')

# Mapeamento de arquivos CSV para tabelas
CSV_TABLE_MAPPING = {
    'municipios.csv': 't_municipios',
    'regiao.csv': 't_regiao',
    'regionalizacao_regiao.csv': 't_regionalizacao_regiao',
    'tema.csv': 't_tema',
    'tipo_tema_tema.csv': 't_tipo_tema_tema'
}

# ============================================================================
# FUNÇÕES AUXILIARES
# ============================================================================

def get_db_connection():
    """Cria conexão com o banco de dados"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        logger.info(f"Conectado ao banco: {DB_CONFIG['dbname']}")
        return conn
    except psycopg2.Error as e:
        logger.error(f"Erro ao conectar ao banco: {e}")
        sys.exit(1)

def read_csv(file_path, encoding='utf-8'):
    """Lê arquivo CSV e retorna lista de dicionários"""
    try:
        with open(file_path, 'r', encoding=encoding) as f:
            reader = csv.DictReader(f)
            data = list(reader)
            logger.info(f"Lidos {len(data)} registros de {file_path}")
            return data
    except FileNotFoundError:
        logger.error(f"Arquivo não encontrado: {file_path}")
        return []
    except Exception as e:
        logger.error(f"Erro ao ler {file_path}: {e}")
        return []

def insert_data(conn, table_name, data, batch_size=1000):
    """Insere dados em lote na tabela"""
    if not data:
        logger.warning(f"Nenhum dado para inserir em {table_name}")
        return 0

    cursor = conn.cursor()
    total_inserted = 0

    try:
        # Obter colunas do primeiro registro
        columns = list(data[0].keys())

        # Criar query de INSERT
        insert_query = sql.SQL(
            "INSERT INTO dados_mapoteca.{} ({}) VALUES %s ON CONFLICT DO NOTHING"
        ).format(
            sql.Identifier(table_name),
            sql.SQL(', ').join(map(sql.Identifier, columns))
        )

        # Inserir em lotes
        for i in range(0, len(data), batch_size):
            batch = data[i:i + batch_size]
            values = [tuple(row[col] for col in columns) for row in batch]

            execute_values(cursor, insert_query, values)
            conn.commit()

            inserted = len(batch)
            total_inserted += inserted
            logger.info(f"  Inseridos {inserted} registros em {table_name} (total: {total_inserted}/{len(data)})")

        logger.info(f"✓ Concluído: {total_inserted} registros inseridos em {table_name}")
        return total_inserted

    except psycopg2.Error as e:
        conn.rollback()
        logger.error(f"Erro ao inserir dados em {table_name}: {e}")
        return 0
    finally:
        cursor.close()

def migrate_municipios(conn, csv_file):
    """Migra dados de municípios com tratamento especial"""
    data = read_csv(csv_file)
    if not data:
        return 0

    cursor = conn.cursor()
    total_inserted = 0

    try:
        for row in data:
            # Validar e limpar dados
            codigo_ibge = row.get('codigo_ibge', '').strip()
            nome = row.get('nome_municipio', '').strip()

            if not codigo_ibge or not nome:
                logger.warning(f"Registro inválido ignorado: {row}")
                continue

            # Preparar dados
            insert_data = {
                'codigo_ibge': codigo_ibge,
                'nome_municipio': nome,
                'nome_municipio_sem_acento': None,  # Será gerado por trigger
                'microrregiao': row.get('microrregiao', '').strip() or None,
                'mesorregiao': row.get('mesorregiao', '').strip() or None,
                'regiao_intermediaria': row.get('regiao_intermediaria', '').strip() or None,
                'regiao_imediata': row.get('regiao_imediata', '').strip() or None,
                'territorio_identidade': row.get('territorio_identidade', '').strip() or None,
                'area_km2': float(row['area_km2']) if row.get('area_km2') else None,
                'populacao': int(row['populacao']) if row.get('populacao') else None,
                'pib_per_capita': float(row['pib_per_capita']) if row.get('pib_per_capita') else None,
                'idh': float(row['idh']) if row.get('idh') else None,
                'latitude': float(row['latitude']) if row.get('latitude') else None,
                'longitude': float(row['longitude']) if row.get('longitude') else None
            }

            # INSERT
            cursor.execute("""
                INSERT INTO dados_mapoteca.t_municipios (
                    codigo_ibge, nome_municipio, microrregiao, mesorregiao,
                    regiao_intermediaria, regiao_imediata, territorio_identidade,
                    area_km2, populacao, pib_per_capita, idh, latitude, longitude
                ) VALUES (
                    %(codigo_ibge)s, %(nome_municipio)s, %(microrregiao)s, %(mesorregiao)s,
                    %(regiao_intermediaria)s, %(regiao_imediata)s, %(territorio_identidade)s,
                    %(area_km2)s, %(populacao)s, %(pib_per_capita)s, %(idh)s, %(latitude)s, %(longitude)s
                )
                ON CONFLICT (codigo_ibge) DO UPDATE SET
                    nome_municipio = EXCLUDED.nome_municipio,
                    microrregiao = EXCLUDED.microrregiao,
                    mesorregiao = EXCLUDED.mesorregiao,
                    area_km2 = EXCLUDED.area_km2,
                    populacao = EXCLUDED.populacao,
                    data_atualizacao = CURRENT_TIMESTAMP
            """, insert_data)

            total_inserted += 1

            if total_inserted % 100 == 0:
                conn.commit()
                logger.info(f"  Processados {total_inserted} municípios...")

        conn.commit()
        logger.info(f"✓ Migração de municípios concluída: {total_inserted} registros")
        return total_inserted

    except Exception as e:
        conn.rollback()
        logger.error(f"Erro ao migrar municípios: {e}")
        return total_inserted
    finally:
        cursor.close()

def validate_data(conn):
    """Valida integridade dos dados após migração"""
    cursor = conn.cursor()
    issues = []

    try:
        # Validar municípios sem código IBGE
        cursor.execute("""
            SELECT COUNT(*) FROM dados_mapoteca.t_municipios
            WHERE codigo_ibge IS NULL OR LENGTH(codigo_ibge) != 7
        """)
        invalid_municipios = cursor.fetchone()[0]
        if invalid_municipios > 0:
            issues.append(f"{invalid_municipios} municípios com código IBGE inválido")

        # Validar combinações classe+tipo
        cursor.execute("""
            SELECT COUNT(*) FROM dados_mapoteca.t_classe_mapa_tipo_mapa
        """)
        total_combinacoes = cursor.fetchone()[0]
        if total_combinacoes != 6:
            issues.append(f"Esperado 6 combinações classe+tipo, encontrado {total_combinacoes}")

        # Validar temas sem tipo
        cursor.execute("""
            SELECT COUNT(*) FROM dados_mapoteca.t_tema t
            LEFT JOIN dados_mapoteca.t_tipo_tema_tema ttt ON t.id_tema = ttt.id_tema
            WHERE ttt.id_tipo_tema IS NULL
        """)
        temas_orfaos = cursor.fetchone()[0]
        if temas_orfaos > 0:
            issues.append(f"{temas_orfaos} temas sem tipo_tema associado")

        if issues:
            logger.warning("Problemas encontrados na validação:")
            for issue in issues:
                logger.warning(f"  - {issue}")
            return False
        else:
            logger.info("✓ Validação concluída: dados íntegros")
            return True

    except Exception as e:
        logger.error(f"Erro na validação: {e}")
        return False
    finally:
        cursor.close()

def generate_statistics(conn):
    """Gera estatísticas dos dados migrados"""
    cursor = conn.cursor()

    try:
        logger.info("\n=== Estatísticas da Migração ===")

        # Contadores por tabela
        tables = [
            't_classe_mapa', 't_tipo_mapa', 't_anos', 't_escala', 't_cor',
            't_tipo_regionalizacao', 't_regiao', 't_tipo_tema', 't_tema',
            't_classe_mapa_tipo_mapa', 't_regionalizacao_regiao', 't_tipo_tema_tema',
            't_municipios'
        ]

        for table in tables:
            cursor.execute(sql.SQL("SELECT COUNT(*) FROM dados_mapoteca.{}").format(
                sql.Identifier(table)
            ))
            count = cursor.fetchone()[0]
            logger.info(f"  {table}: {count} registros")

        logger.info("=" * 35)

    except Exception as e:
        logger.error(f"Erro ao gerar estatísticas: {e}")
    finally:
        cursor.close()

# ============================================================================
# MAIN
# ============================================================================

def main():
    parser = argparse.ArgumentParser(description='Migração de dados CSV para PostgreSQL')
    parser.add_argument('--csv-dir', default=CSV_DIR, help='Diretório com arquivos CSV')
    parser.add_argument('--validate', action='store_true', help='Apenas validar dados')
    parser.add_argument('--stats', action='store_true', help='Apenas gerar estatísticas')
    args = parser.parse_args()

    logger.info("=" * 70)
    logger.info("Mapoteca Digital - Migração de Dados CSV")
    logger.info("=" * 70)

    # Conectar ao banco
    conn = get_db_connection()

    try:
        # Se apenas validação
        if args.validate:
            validate_data(conn)
            return

        # Se apenas estatísticas
        if args.stats:
            generate_statistics(conn)
            return

        # Migração completa
        logger.info("\nIniciando migração de dados...")

        total_records = 0

        # Migrar municípios (tratamento especial)
        municipios_csv = os.path.join(args.csv_dir, 'municipios.csv')
        if os.path.exists(municipios_csv):
            logger.info("\n1. Migrando municípios...")
            total_records += migrate_municipios(conn, municipios_csv)

        # Migrar outras tabelas
        for csv_file, table_name in CSV_TABLE_MAPPING.items():
            csv_path = os.path.join(args.csv_dir, csv_file)
            if os.path.exists(csv_path) and csv_file != 'municipios.csv':
                logger.info(f"\n2. Migrando {table_name}...")
                data = read_csv(csv_path)
                total_records += insert_data(conn, table_name, data)

        logger.info("\n" + "=" * 70)
        logger.info(f"✓ Migração concluída: {total_records} registros totais")
        logger.info("=" * 70)

        # Validar dados
        logger.info("\nValidando integridade dos dados...")
        validate_data(conn)

        # Gerar estatísticas
        generate_statistics(conn)

    finally:
        conn.close()
        logger.info("\nConexão fechada.")

if __name__ == '__main__':
    main()
