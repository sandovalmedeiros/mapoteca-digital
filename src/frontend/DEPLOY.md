# 🚀 Guia de Deployment - Frontend Mapoteca Digital

## 📋 Visão Geral

Este documento descreve o processo completo de deployment do frontend da Mapoteca Digital desenvolvido em **ArcGIS Experience Builder**.

**Versão:** 1.0.0
**Data:** 2025-11-19
**Autor:** SEIGEO - SEI-BA

---

## 🎯 Pré-requisitos

### Software Necessário

- ✅ **ArcGIS Experience Builder** (versão 1.12 ou superior)
- ✅ **ArcGIS Enterprise** (versão 10.9 ou superior)
- ✅ **ArcGIS Portal** configurado e funcionando
- ✅ **Navegador Web** moderno (Chrome, Firefox, Edge, Safari)
- ✅ **Node.js** (versão 16+ para desenvolvimento local)

### Permissões Necessárias

- ✅ Acesso administrativo ao ArcGIS Portal
- ✅ Permissões de publicação de Feature Services
- ✅ Permissões de criação de Experience Builder Apps
- ✅ Acesso ao servidor PostgreSQL (para configuração de Feature Services)

### Feature Services Configurados

Antes de fazer o deployment do frontend, certifique-se que os seguintes Feature Services estão publicados:

1. **FS_Mapoteca_Publicacoes** - Tabela principal de publicações
2. **FS_Mapoteca_Dominios** - Tabelas de domínio (lookup tables)
3. **FS_Mapoteca_Relacionamentos** - Tabelas de relacionamento N:N

---

## 📦 Estrutura de Arquivos

```
src/frontend/
├── config.json                 # Configuração principal da aplicação
├── DEPLOY.md                   # Este documento
├── README.md                   # Documentação do frontend
│
├── scripts/                    # Scripts JavaScript
│   ├── validation.js          # Lógica de validações
│   ├── form-handler.js        # Handlers do formulário
│   └── attachment-handler.js  # Gestão de attachments
│
├── themes/                     # Temas visuais
│   └── seigeo-theme.json      # Tema customizado SEIGEO
│
└── widgets/                    # Widgets customizados (se necessário)
    └── .gitkeep
```

---

## 🔧 Processo de Deployment

### Etapa 1: Configurar Feature Services

#### 1.1. Publicar Feature Services no ArcGIS Server

```bash
# Via ArcGIS Pro ou ArcMap
# 1. Conectar ao PostgreSQL
# 2. Adicionar tabelas do schema dados_mapoteca
# 3. Publicar como Feature Service com as seguintes capacidades:
#    - Query
#    - Create
#    - Update
#    - Delete
#    - Editing
#    - Attachments (IMPORTANTE!)
```

#### 1.2. Configurar Attachments

```sql
-- No PostgreSQL, habilitar attachments nas tabelas principais
-- Executar via ArcGIS Pro ou ArcMap:

-- Para t_publicacao
ALTER TABLE dados_mapoteca.t_publicacao
  ENABLE ATTACHMENTS;

-- Isso criará automaticamente a tabela:
-- dados_mapoteca.t_publicacao__attach
```

#### 1.3. Configurar Permissões

```bash
# No ArcGIS Portal, configurar permissões dos Feature Services:
# - Leitura: Todos os usuários autenticados
# - Edição: Apenas grupo "Mapoteca_Editors"
# - Administração: Apenas grupo "Mapoteca_Admins"
```

#### 1.4. Validar Feature Services

```bash
# Testar URLs dos Feature Services:
# https://<seu-servidor>/arcgis/rest/services/Mapoteca/FS_Mapoteca_Publicacoes/FeatureServer
# https://<seu-servidor>/arcgis/rest/services/Mapoteca/FS_Mapoteca_Dominios/FeatureServer
# https://<seu-servidor>/arcgis/rest/services/Mapoteca/FS_Mapoteca_Relacionamentos/FeatureServer

# Verificar se retornam JSON válido
curl -X GET "https://<seu-servidor>/arcgis/rest/services/Mapoteca/FS_Mapoteca_Publicacoes/FeatureServer?f=json"
```

---

### Etapa 2: Criar Aplicação no Experience Builder

#### 2.1. Acessar Experience Builder

```
1. Abrir navegador
2. Acessar: https://<seu-portal>/portal/apps/experiencebuilder/
3. Fazer login com usuário administrativo
```

#### 2.2. Criar Nova Experiência

```
1. Clicar em "Create New"
2. Escolher "Blank Template"
3. Nome: "Mapoteca Digital - Sistema de Cadastro"
4. Descrição: "Sistema de automação para publicação de mapas do SEIGEO/SEI-BA"
5. Thumbnail: Upload logo-sei-ba.png
6. Clicar em "Create"
```

#### 2.3. Configurar Data Sources

```
1. Clicar em "Data" no menu lateral
2. Adicionar Feature Services:

   a) FS_Mapoteca_Publicacoes
      - URL: https://<seu-servidor>/arcgis/rest/services/Mapoteca/FS_Mapoteca_Publicacoes/FeatureServer
      - Layers: Selecionar Layer 0 (t_publicacao)
      - Habilitar: Query, Create, Update, Delete, Attachments

   b) FS_Mapoteca_Dominios
      - URL: https://<seu-servidor>/arcgis/rest/services/Mapoteca/FS_Mapoteca_Dominios/FeatureServer
      - Layers: Selecionar todas (0-8)
      - Habilitar: Query apenas

   c) FS_Mapoteca_Relacionamentos
      - URL: https://<seu-servidor>/arcgis/rest/services/Mapoteca/FS_Mapoteca_Relacionamentos/FeatureServer
      - Layers: Selecionar todas (0-2)
      - Habilitar: Query apenas
```

#### 2.4. Importar Configuração JSON

```
1. Clicar em "Settings" (ícone de engrenagem)
2. Clicar em "Import"
3. Selecionar arquivo: src/frontend/config.json
4. Aguardar importação
5. Verificar se todos os widgets foram criados corretamente
```

#### 2.5. Aplicar Tema Customizado

```
1. Clicar em "Theme" no menu lateral
2. Clicar em "Import Theme"
3. Selecionar arquivo: src/frontend/themes/seigeo-theme.json
4. Aplicar tema "SEIGEO Theme"
5. Salvar alterações
```

---

### Etapa 3: Configurar Widgets

#### 3.1. Header Widget

```
1. Selecionar Header Widget
2. Configurar:
   - Título: "Mapoteca Digital - Sistema de Cadastro"
   - Logo: Upload logo-sei-ba.png
   - Mostrar usuário: Sim
   - Mostrar logout: Sim
3. Adicionar links de navegação:
   - Mapas Estaduais
   - Mapas Regionais
   - Mapas Municipais
   - Cartogramas
```

#### 3.2. Form Widget

```
1. Selecionar Form Widget
2. Conectar ao Data Source: FS_Mapoteca_Publicacoes/0
3. Configurar campos conforme config.json
4. Ativar validações em tempo real
5. Testar preenchimento de formulário
```

#### 3.3. List Widget

```
1. Selecionar List Widget
2. Conectar ao Data Source: FS_Mapoteca_Publicacoes/0
3. Configurar template de exibição
4. Adicionar ações: Editar, Ver PDFs, Excluir
5. Configurar filtros
6. Testar listagem
```

#### 3.4. Attachment Widget

```
1. Selecionar Attachment Widget
2. Conectar ao Data Source: FS_Mapoteca_Publicacoes/0
3. Configurar:
   - Tipos de arquivo permitidos: PDF
   - Tamanho máximo: 50 MB
   - Drag and Drop: Habilitado
   - Preview inline: Habilitado
4. Testar upload de PDF
```

---

### Etapa 4: Integrar Scripts Customizados

#### 4.1. Adicionar Scripts de Validação

```javascript
// No Experience Builder, acessar "Developer Tools"
// Adicionar Custom JavaScript Module

1. Criar módulo "ValidationModule"
2. Copiar conteúdo de: src/frontend/scripts/validation.js
3. Salvar
4. Conectar ao Form Widget
5. Testar validações em cascata
```

#### 4.2. Adicionar Form Handler

```javascript
// Adicionar módulo "FormHandlerModule"

1. Criar módulo "FormHandlerModule"
2. Copiar conteúdo de: src/frontend/scripts/form-handler.js
3. Salvar
4. Conectar aos botões do formulário
5. Testar salvamento e edição
```

#### 4.3. Adicionar Attachment Handler

```javascript
// Adicionar módulo "AttachmentHandlerModule"

1. Criar módulo "AttachmentHandlerModule"
2. Copiar conteúdo de: src/frontend/scripts/attachment-handler.js
3. Salvar
4. Conectar ao Attachment Widget
5. Testar upload, download e visualização de PDFs
```

---

### Etapa 5: Testes

#### 5.1. Testes Funcionais

```
✓ Cadastro de nova publicação
✓ Validação Classe + Tipo (6 combinações válidas)
✓ Cascata Tipo Regionalização → Região
✓ Cascata Tipo Tema → Tema
✓ Upload de PDF (até 50MB)
✓ Visualização inline de PDF
✓ Edição de publicação existente
✓ Exclusão de publicação
✓ Filtros da lista
```

#### 5.2. Testes de Performance

```
✓ Carregamento inicial < 3s
✓ Salvamento < 1s
✓ Upload 50MB < 30s
✓ Listagem 100 itens < 2s
```

#### 5.3. Testes de Acessibilidade

```
✓ Navegação por teclado
✓ Leitura por screen reader
✓ Contraste WCAG AA
✓ Responsividade (desktop/tablet/mobile)
```

---

### Etapa 6: Publicar Aplicação

#### 6.1. Configurar Compartilhamento

```
1. Clicar em "Share" no Experience Builder
2. Configurar:
   - Compartilhar com: Organização
   - Grupos: Mapoteca_Users, Mapoteca_Editors
   - Público: Não (requer autenticação)
```

#### 6.2. Publicar Versão

```
1. Clicar em "Publish"
2. Revisar configurações
3. Adicionar notas da versão
4. Confirmar publicação
5. Aguardar conclusão
```

#### 6.3. Obter URL de Produção

```
# URL será gerada automaticamente:
https://<seu-portal>/portal/apps/experiencebuilder/experience/?id=<app-id>

# Criar URL amigável (opcional):
https://<seu-portal>/portal/home/item.html?id=<app-id>
```

---

## 🔍 Verificação Pós-Deployment

### Checklist de Validação

- [ ] ✅ Feature Services acessíveis
- [ ] ✅ Aplicação carrega corretamente
- [ ] ✅ Todos os widgets visíveis
- [ ] ✅ Tema aplicado corretamente
- [ ] ✅ Scripts de validação funcionando
- [ ] ✅ Upload de PDF funciona
- [ ] ✅ Formulário salva dados
- [ ] ✅ Lista exibe publicações
- [ ] ✅ Edição funciona
- [ ] ✅ Exclusão funciona
- [ ] ✅ Performance dentro dos SLAs
- [ ] ✅ Acessibilidade WCAG AA

### Testes de Integração

```bash
# Testar integração com aplicações existentes
# 1. Mapas Estaduais
# 2. Mapas Regionais
# 3. Mapas Municipais
# 4. Cartogramas

# Verificar se novos mapas cadastrados aparecem nas 4 aplicações
```

---

## 🔧 Troubleshooting

### Problema: Feature Service não carrega

**Solução:**
```
1. Verificar se serviço está publicado e ativo
2. Checar permissões de acesso
3. Validar URL do serviço
4. Verificar logs do ArcGIS Server
```

### Problema: Upload de PDF falha

**Solução:**
```
1. Verificar se Attachments está habilitado no Feature Service
2. Checar tamanho máximo permitido no servidor
3. Validar formato do arquivo (deve ser PDF)
4. Verificar logs do navegador (F12)
```

### Problema: Validações em cascata não funcionam

**Solução:**
```
1. Verificar se scripts foram importados corretamente
2. Checar console do navegador para erros JavaScript
3. Validar queries nas tabelas de relacionamento
4. Testar queries diretamente no Feature Service
```

### Problema: Performance lenta

**Solução:**
```
1. Habilitar cache nos dropdowns
2. Implementar paginação na lista
3. Otimizar queries (adicionar índices no PostgreSQL)
4. Reduzir número de campos retornados nas queries
5. Configurar CDN para assets estáticos
```

---

## 📊 Monitoramento

### Métricas a Acompanhar

```
- Número de publicações cadastradas por dia
- Tempo médio de carregamento da aplicação
- Tempo médio de salvamento de publicação
- Taxa de sucesso de uploads de PDF
- Número de erros por dia
- Usuários ativos por dia
```

### Logs

```bash
# Logs do ArcGIS Server
/arcgis/server/usr/logs/

# Logs do Portal
/arcgis/portal/usr/logs/

# Logs do navegador
# Acessar via DevTools (F12) → Console
```

---

## 🔄 Atualizações e Versionamento

### Processo de Atualização

```
1. Fazer backup da versão atual
2. Testar alterações em ambiente de desenvolvimento
3. Criar nova versão no Experience Builder
4. Publicar nova versão
5. Monitorar por 24h
6. Rollback se necessário
```

### Versionamento

```
Formato: MAJOR.MINOR.PATCH

- MAJOR: Mudanças incompatíveis
- MINOR: Novas funcionalidades compatíveis
- PATCH: Correções de bugs

Exemplo: 1.0.0 → 1.1.0 → 1.1.1
```

---

## 👥 Contatos e Suporte

### Equipe Técnica

- **Desenvolvimento:** SEIGEO - seigeo@sei.ba.gov.br
- **Infraestrutura:** TI SEI-BA
- **Suporte:** suporte@sei.ba.gov.br

### Documentação Adicional

- [PRD](../../docs/prd.md)
- [Database Schema](../../docs/database.md)
- [Experience Builder Config](../../docs/EXPERIENCE-BUILDER-CONFIG.md)
- [Validations Logic](../../docs/VALIDATIONS-LOGIC.md)

---

## 📝 Changelog

### Versão 1.0.0 (2025-11-19)

- ✅ Primeira versão de produção
- ✅ Formulário de cadastro completo
- ✅ Upload de PDFs via Attachments
- ✅ Validações em cascata
- ✅ Integração com 4 aplicações existentes
- ✅ Tema SEIGEO aplicado
- ✅ Performance otimizada
- ✅ Acessibilidade WCAG AA

---

**Versão:** 1.0.0
**Status:** ✅ Pronto para Produção
**Última Atualização:** 2025-11-19
