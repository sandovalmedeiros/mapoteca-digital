# 📦 Como Salvar os Arquivos no Windows

## 🎯 MÉTODO 1: Usando Git (Recomendado)

### Pré-requisito: Instalar Git para Windows
Baixe em: https://git-scm.com/download/win

### Passo a Passo:

```powershell
# 1. Abra PowerShell ou Git Bash
# 2. Navegue até a pasta desejada
cd C:\Users\SeuUsuario\Documents

# 3. Clone o repositório (substitua pela URL real)
git clone <URL_DO_SEU_REPOSITORIO> mapoteca-digital

# 4. Entre na pasta
cd mapoteca-digital

# 5. Mude para o branch de desenvolvimento
git checkout claude/execute-clinerules-011fjDBK7qnNfkxYuqf2c3MW

# 6. Verifique os arquivos
dir docs
dir scripts
```

---

## 🎯 MÉTODO 2: Baixar ZIP do GitHub/GitLab

Se o repositório está no GitHub ou GitLab:

### GitHub:
```
https://github.com/USUARIO/mapoteca-digital/archive/refs/heads/claude/execute-clinerules-011fjDBK7qnNfkxYuqf2c3MW.zip
```

### GitLab:
```
https://gitlab.com/USUARIO/mapoteca-digital/-/archive/claude/execute-clinerules-011fjDBK7qnNfkxYuqf2c3MW/mapoteca-digital-claude-execute-clinerules-011fjDBK7qnNfkxYuqf2c3MW.zip
```

Depois de baixar:
1. Extraia o ZIP
2. Renomeie a pasta para `mapoteca-digital`
3. Pronto!

---

## 🎯 MÉTODO 3: Criar Arquivos Manualmente com PowerShell

Salve o script abaixo como `criar-mapoteca.ps1` e execute:

```powershell
# Executar PowerShell como Administrador
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\criar-mapoteca.ps1
```

### Script PowerShell Completo:

```powershell
# Mapoteca Digital - Gerador de Arquivos para Windows
# Data: 2025-11-17
# Versão: 1.0

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Mapoteca Digital - Criador de Arquivos" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Solicitar pasta de destino
$destino = Read-Host "Digite o caminho completo onde deseja criar a pasta (ex: C:\Users\SeuUsuario\Documents)"

if (-not (Test-Path $destino)) {
    Write-Host "ERRO: O caminho '$destino' não existe!" -ForegroundColor Red
    Write-Host "Por favor, crie a pasta primeiro ou use um caminho válido." -ForegroundColor Yellow
    exit 1
}

# Criar estrutura
$raiz = Join-Path $destino "mapoteca-digital"
Write-Host "Criando estrutura em: $raiz" -ForegroundColor Green
Write-Host ""

# Criar pastas
@(
    $raiz,
    "$raiz\docs",
    "$raiz\scripts",
    "$raiz\src\backend\database\schema",
    "$raiz\src\frontend\widgets",
    "$raiz\tests\unit"
) | ForEach-Object {
    New-Item -ItemType Directory -Force -Path $_ | Out-Null
}

Write-Host "✓ Estrutura de pastas criada" -ForegroundColor Green

# Criar arquivo .gitkeep nas pastas vazias
@(
    "$raiz\src\backend\database\schema\.gitkeep",
    "$raiz\src\frontend\widgets\.gitkeep",
    "$raiz\tests\unit\.gitkeep"
) | ForEach-Object {
    New-Item -ItemType File -Force -Path $_ | Out-Null
}

Write-Host "✓ Arquivos .gitkeep criados" -ForegroundColor Green
Write-Host ""
Write-Host "================================================" -ForegroundColor Yellow
Write-Host " IMPORTANTE: Baixe os arquivos principais!" -ForegroundColor Yellow
Write-Host "================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Os arquivos SQL e de documentação precisam ser baixados:" -ForegroundColor White
Write-Host ""
Write-Host "OPÇÃO A: Clonar com Git" -ForegroundColor Cyan
Write-Host "  cd $raiz" -ForegroundColor Gray
Write-Host "  git init" -ForegroundColor Gray
Write-Host "  git remote add origin <URL_DO_REPOSITORIO>" -ForegroundColor Gray
Write-Host "  git pull origin claude/execute-clinerules-011fjDBK7qnNfkxYuqf2c3MW" -ForegroundColor Gray
Write-Host ""
Write-Host "OPÇÃO B: Baixar do GitHub/GitLab" -ForegroundColor Cyan
Write-Host "  1. Acesse o repositório no navegador" -ForegroundColor Gray
Write-Host "  2. Mude para o branch: claude/execute-clinerules-011fjDBK7qnNfkxYuqf2c3MW" -ForegroundColor Gray
Write-Host "  3. Clique em 'Download ZIP'" -ForegroundColor Gray
Write-Host "  4. Extraia para: $raiz" -ForegroundColor Gray
Write-Host ""
Write-Host "OPÇÃO C: Copiar manualmente" -ForegroundColor Cyan
Write-Host "  Copie os arquivos de outra máquina que tenha o repositório" -ForegroundColor Gray
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host " Arquivos que você precisa:" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📂 docs/" -ForegroundColor Yellow
Write-Host "  - FEATURE-SERVICES-CONFIG.md" -ForegroundColor White
Write-Host "  - EXPERIENCE-BUILDER-CONFIG.md" -ForegroundColor White
Write-Host "  - VALIDATIONS-LOGIC.md" -ForegroundColor White
Write-Host "  - DEPLOYMENT-GUIDE.md" -ForegroundColor White
Write-Host ""
Write-Host "📂 scripts/" -ForegroundColor Yellow
Write-Host "  - 00-validate-environment.sql" -ForegroundColor White
Write-Host "  - 01-setup-schema-CORRECTED.sql" -ForegroundColor White
Write-Host "  - 02-populate-data-CORRECTED.sql" -ForegroundColor White
Write-Host "  - 03-indexes-constraints-CORRECTED.sql" -ForegroundColor White
Write-Host "  - 04-esri-integration-CORRECTED.sql" -ForegroundColor White
Write-Host ""
Write-Host "📄 Raiz/" -ForegroundColor Yellow
Write-Host "  - README.md" -ForegroundColor White
Write-Host "  - MIGRATION-GUIDE.md" -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Estrutura criada com sucesso!" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pasta: $raiz" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Baixe os arquivos usando uma das opções acima" -ForegroundColor White
Write-Host "2. Leia: docs\DEPLOYMENT-GUIDE.md" -ForegroundColor White
Write-Host "3. Execute os scripts SQL na ordem (00, 01, 02, 03, 04)" -ForegroundColor White
Write-Host ""

# Criar arquivo README simples
$readmeContent = @"
# Mapoteca Digital

## Estrutura do Projeto

``````
mapoteca-digital/
├── docs/                              # Documentação
│   ├── FEATURE-SERVICES-CONFIG.md     # Backend (Feature Services)
│   ├── EXPERIENCE-BUILDER-CONFIG.md   # Frontend (Experience Builder)
│   ├── VALIDATIONS-LOGIC.md           # Lógica de validações
│   └── DEPLOYMENT-GUIDE.md            # Guia de implantação
│
├── scripts/                           # Scripts SQL
│   ├── 00-validate-environment.sql    # Validação de ambiente
│   ├── 01-setup-schema-CORRECTED.sql  # Criação de tabelas
│   ├── 02-populate-data-CORRECTED.sql # População de dados
│   ├── 03-indexes-constraints-CORRECTED.sql # Índices e constraints
│   └── 04-esri-integration-CORRECTED.sql    # Integração ESRI
│
└── README.md                          # Este arquivo
``````

## Objetivo

Automatizar publicação de mapas da Mapoteca Digital:
- Reduzir tempo de 30 minutos para 5 minutos (83% de redução)
- Usar ArcGIS Experience Builder (100% low-code)
- Upload de PDFs via SDE Attachments (máx 50MB)

## Como Começar

1. **Leia a documentação**: `docs\DEPLOYMENT-GUIDE.md`
2. **Execute os scripts SQL** na ordem: 00 → 01 → 02 → 03 → 04
3. **Configure Feature Services** conforme `docs\FEATURE-SERVICES-CONFIG.md`
4. **Configure Experience Builder** conforme `docs\EXPERIENCE-BUILDER-CONFIG.md`

## Stack Tecnológica

- PostgreSQL 14+ com PostGIS e SDE
- ArcGIS Enterprise 10.9+
- ArcGIS Experience Builder
- 18 tabelas com nomenclatura padronizada (prefixo t_)

## Arquitetura

- **Backend**: Feature Services nativos do ArcGIS (sem API customizada)
- **Frontend**: Experience Builder com widgets nativos (sem código custom)
- **Base de Dados**: PostgreSQL com 18 tabelas + validações em cascata

## Contatos

- Projeto: Mapoteca Digital - SEI/BA
- Ambiente: Oracle Linux (10.28.246.75)
- Usuários: 2 técnicos (editores)

---

**Versão**: 1.0
**Data**: 2025-11-17
**Branch**: claude/execute-clinerules-011fjDBK7qnNfkxYuqf2c3MW
"@

Set-Content -Path "$raiz\README.md" -Value $readmeContent -Encoding UTF8
Write-Host "✓ README.md criado" -ForegroundColor Green
Write-Host ""
```

---

## 📝 Lista de Arquivos Importantes

### Documentação (4 arquivos):
1. `docs/FEATURE-SERVICES-CONFIG.md` - Configuração do Backend (12.7 KB)
2. `docs/EXPERIENCE-BUILDER-CONFIG.md` - Configuração do Frontend (18.1 KB)
3. `docs/VALIDATIONS-LOGIC.md` - Lógica de validações (17.7 KB)
4. `docs/DEPLOYMENT-GUIDE.md` - Guia de implantação (15.2 KB)

### Scripts SQL (5 arquivos):
1. `scripts/00-validate-environment.sql` - Validação de ambiente (6.9 KB)
2. `scripts/01-setup-schema-CORRECTED.sql` - Criação de tabelas (15.1 KB)
3. `scripts/02-populate-data-CORRECTED.sql` - População de dados (11.7 KB)
4. `scripts/03-indexes-constraints-CORRECTED.sql` - Índices e constraints (14.0 KB)
5. `scripts/04-esri-integration-CORRECTED.sql` - Integração ESRI (15.1 KB)

### Outros (2 arquivos):
1. `README.md` - Documentação do projeto (9.0 KB)
2. `MIGRATION-GUIDE.md` - Guia de migração (11.5 KB)

**Total**: 11 arquivos principais (≈ 127 KB)

---

## ❓ Dúvidas Frequentes

**P: Qual método devo usar?**
R: Se tem Git instalado, use o MÉTODO 1. Se não, use o MÉTODO 2 (baixar ZIP).

**P: Preciso de todos os arquivos?**
R: Os 11 arquivos listados acima são essenciais. Os demais são opcionais.

**P: Como executo os scripts SQL?**
R: Use pgAdmin ou psql:
```bash
psql -U dados_mapoteca -d mapoteca -f scripts/00-validate-environment.sql
psql -U dados_mapoteca -d mapoteca -f scripts/01-setup-schema-CORRECTED.sql
# ... e assim por diante
```

**P: Onde encontro a URL do repositório?**
R: Pergunte ao administrador do sistema ou verifique no GitHub/GitLab.

---

**Data**: 2025-11-17
**Versão**: 1.0
**Suporte**: Consulte o DEPLOYMENT-GUIDE.md
