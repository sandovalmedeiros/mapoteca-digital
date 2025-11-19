/**
 * ✅ Validation Scripts - Mapoteca Digital
 *
 * Script de validações em cascata e regras de negócio para o formulário
 * da Mapoteca Digital implementado em ArcGIS Experience Builder.
 *
 * @version 1.0.0
 * @author SEIGEO - SEI-BA
 * @date 2025-11-19
 */

// ============================================================================
// CONFIGURAÇÃO E CONSTANTES
// ============================================================================

const VALIDATION_CONFIG = {
  debounceTime: 500,
  maxFileSize: 52428800, // 50 MB em bytes
  maxFileName: 255,
  pdfMimeType: 'application/pdf',
  pdfHeader: '%PDF'
};

const ERROR_MESSAGES = {
  // Campos obrigatórios
  required: 'Campo obrigatório',

  // Classe + Tipo
  invalidClasseTipo: 'Combinação inválida de Classe e Tipo. Consulte a tabela de combinações permitidas.',
  selectClasseFirst: 'Selecione primeiro a Classe do Mapa',

  // Regionalização + Região
  invalidRegiao: 'Região inválida para este tipo de regionalização',
  selectRegionalizacaoFirst: 'Selecione primeiro o Tipo de Regionalização',
  noRegioesFound: 'Nenhuma região encontrada para este tipo',
  errorLoadingRegioes: 'Erro ao carregar regiões. Tente novamente.',

  // Tipo Tema + Tema
  invalidTema: 'Tema inválido para este tipo de tema',
  selectTipoTemaFirst: 'Selecione primeiro o Tipo de Tema',
  noTemasFound: 'Nenhum tema encontrado para este tipo',
  errorLoadingTemas: 'Erro ao carregar temas. Tente novamente.',

  // PDF
  pdfOnly: 'Apenas arquivos PDF são permitidos',
  pdfTooLarge: 'Arquivo muito grande ({size} MB). Máximo permitido: 50 MB',
  pdfNameTooLong: 'Nome do arquivo muito longo (máximo 255 caracteres)',
  pdfInvalidExtension: 'Arquivo deve ter extensão .pdf',
  pdfInvalidHeader: 'Arquivo não é um PDF válido (header inválido)',
  pdfRequired: 'É necessário anexar pelo menos um PDF',

  // Geral
  formInvalid: 'Existem erros no formulário. Corrija antes de salvar.',
  saveError: 'Erro ao salvar publicação',
  loadError: 'Erro ao carregar dados'
};

// ============================================================================
// REGRA 1: VALIDAÇÃO CLASSE + TIPO
// ============================================================================

/**
 * Valida combinação de Classe + Tipo do Mapa
 * Apenas 6 combinações são válidas conforme tabela t_classe_mapa_tipo_mapa
 *
 * @param {string} idClasse - ID da classe selecionada (ex: '01', '02')
 * @param {string} idTipo - ID do tipo selecionado (ex: '01', '02', '03')
 * @returns {Promise<boolean>} - true se válido, false se inválido
 */
async function validateClasseTipo(idClasse, idTipo) {
  if (!idClasse || !idTipo) {
    return false;
  }

  try {
    const query = {
      where: `id_classe_mapa = '${idClasse}' AND id_tipo_mapa = '${idTipo}'`,
      outFields: ['id_classe_mapa'],
      returnGeometry: false,
      returnCountOnly: true
    };

    const featureSet = await queryFeatureService(
      'FS_Mapoteca_Relacionamentos',
      0, // t_classe_mapa_tipo_mapa
      query
    );

    return featureSet.count === 1;
  } catch (error) {
    console.error('Erro ao validar classe/tipo:', error);
    return false;
  }
}

/**
 * Handler para mudança no campo Classe do Mapa
 */
async function onClasseMapaChange(formWidget, value) {
  const tipo = formWidget.getValue('id_tipo_mapa');

  if (tipo) {
    const isValid = await validateClasseTipo(value, tipo);
    if (!isValid) {
      formWidget.setError('id_tipo_mapa', ERROR_MESSAGES.invalidClasseTipo);
      formWidget.clearValue('id_tipo_mapa');
    } else {
      formWidget.clearError('id_tipo_mapa');
    }
  }
}

/**
 * Handler para mudança no campo Tipo do Mapa
 */
async function onTipoMapaChange(formWidget, value) {
  const classe = formWidget.getValue('id_classe_mapa');

  if (!classe) {
    formWidget.setError('id_tipo_mapa', ERROR_MESSAGES.selectClasseFirst);
    formWidget.clearValue('id_tipo_mapa');
    return;
  }

  const isValid = await validateClasseTipo(classe, value);
  if (!isValid) {
    formWidget.setError('id_tipo_mapa', ERROR_MESSAGES.invalidClasseTipo);
    formWidget.clearValue('id_tipo_mapa');
  } else {
    formWidget.clearError('id_tipo_mapa');
  }
}

// ============================================================================
// REGRA 2: VALIDAÇÃO TIPO REGIONALIZAÇÃO + REGIÃO
// ============================================================================

/**
 * Carrega regiões válidas para o tipo de regionalização selecionado
 * Utiliza tabela t_regionalizacao_regiao (229 relacionamentos)
 *
 * @param {Object} formWidget - Widget do formulário
 * @param {string} idTipoRegionalizacao - ID do tipo de regionalização
 */
async function loadRegioesValidas(formWidget, idTipoRegionalizacao) {
  if (!idTipoRegionalizacao) {
    formWidget.setFieldOptions('id_regiao', []);
    formWidget.disableField('id_regiao');
    return;
  }

  try {
    const query = {
      where: `id_tipo_regionalizacao = '${idTipoRegionalizacao}'`,
      outFields: ['id_regiao', 'nome_regiao'],
      orderByFields: 'nome_regiao ASC',
      returnGeometry: false
    };

    const featureSet = await queryFeatureService(
      'FS_Mapoteca_Relacionamentos',
      1, // t_regionalizacao_regiao
      query
    );

    if (featureSet.features.length === 0) {
      formWidget.setError('id_tipo_regionalizacao', ERROR_MESSAGES.noRegioesFound);
      formWidget.setFieldOptions('id_regiao', []);
      formWidget.disableField('id_regiao');
      return;
    }

    const options = featureSet.features.map(f => ({
      value: f.attributes.id_regiao,
      label: f.attributes.nome_regiao
    }));

    formWidget.setFieldOptions('id_regiao', options);
    formWidget.enableField('id_regiao');
    formWidget.clearValue('id_regiao');
    formWidget.clearError('id_tipo_regionalizacao');
  } catch (error) {
    console.error('Erro ao carregar regiões:', error);
    formWidget.setError('id_tipo_regionalizacao', ERROR_MESSAGES.errorLoadingRegioes);
    formWidget.disableField('id_regiao');
  }
}

/**
 * Valida se região é válida para o tipo de regionalização
 */
async function validateRegionalizacaoRegiao(idTipoRegionalizacao, idRegiao) {
  if (!idTipoRegionalizacao || !idRegiao) {
    return false;
  }

  try {
    const query = {
      where: `id_tipo_regionalizacao = '${idTipoRegionalizacao}' AND id_regiao = '${idRegiao}'`,
      returnCountOnly: true
    };

    const featureSet = await queryFeatureService(
      'FS_Mapoteca_Relacionamentos',
      1,
      query
    );

    return featureSet.count === 1;
  } catch (error) {
    console.error('Erro ao validar regionalização/região:', error);
    return false;
  }
}

/**
 * Handler para mudança no campo Tipo de Regionalização
 */
async function onTipoRegionalizacaoChange(formWidget, value) {
  await loadRegioesValidas(formWidget, value);
}

// ============================================================================
// REGRA 3: VALIDAÇÃO TIPO TEMA + TEMA
// ============================================================================

/**
 * Carrega temas válidos para o tipo de tema selecionado
 * Utiliza tabela t_tipo_tema_tema (55 relacionamentos)
 *
 * @param {Object} formWidget - Widget do formulário
 * @param {string} idTipoTema - ID do tipo de tema
 */
async function loadTemasValidos(formWidget, idTipoTema) {
  if (!idTipoTema) {
    formWidget.setFieldOptions('id_tema', []);
    formWidget.disableField('id_tema');
    return;
  }

  try {
    // Query na tabela de relacionamento
    const queryRelacionamento = {
      where: `id_tipo_tema = '${idTipoTema}'`,
      outFields: ['id_tema'],
      returnGeometry: false
    };

    const relacionamentos = await queryFeatureService(
      'FS_Mapoteca_Relacionamentos',
      2, // t_tipo_tema_tema
      queryRelacionamento
    );

    if (relacionamentos.features.length === 0) {
      formWidget.setError('id_tipo_tema', ERROR_MESSAGES.noTemasFound);
      formWidget.setFieldOptions('id_tema', []);
      formWidget.disableField('id_tema');
      return;
    }

    const idsTemasValidos = relacionamentos.features
      .map(f => f.attributes.id_tema);

    // Query na tabela de temas para obter nomes
    const queryTemas = {
      where: `id_tema IN (${idsTemasValidos.join(',')})`,
      outFields: ['id_tema', 'codigo_tema', 'nome_tema'],
      orderByFields: 'nome_tema ASC',
      returnGeometry: false
    };

    const temas = await queryFeatureService(
      'FS_Mapoteca_Dominios',
      8, // t_tema
      queryTemas
    );

    const options = temas.features.map(f => ({
      value: f.attributes.id_tema,
      label: f.attributes.nome_tema
    }));

    formWidget.setFieldOptions('id_tema', options);
    formWidget.enableField('id_tema');
    formWidget.clearValue('id_tema');
    formWidget.clearError('id_tipo_tema');
  } catch (error) {
    console.error('Erro ao carregar temas:', error);
    formWidget.setError('id_tipo_tema', ERROR_MESSAGES.errorLoadingTemas);
    formWidget.disableField('id_tema');
  }
}

/**
 * Valida se tema é válido para o tipo de tema
 */
async function validateTipoTemaTema(idTipoTema, idTema) {
  if (!idTipoTema || !idTema) {
    return false;
  }

  try {
    const query = {
      where: `id_tipo_tema = '${idTipoTema}' AND id_tema = ${idTema}`,
      returnCountOnly: true
    };

    const featureSet = await queryFeatureService(
      'FS_Mapoteca_Relacionamentos',
      2,
      query
    );

    return featureSet.count === 1;
  } catch (error) {
    console.error('Erro ao validar tipo tema/tema:', error);
    return false;
  }
}

/**
 * Handler para mudança no campo Tipo de Tema
 */
async function onTipoTemaChange(formWidget, value) {
  await loadTemasValidos(formWidget, value);
}

// ============================================================================
// VALIDAÇÃO DE CAMPOS OBRIGATÓRIOS
// ============================================================================

const REQUIRED_FIELDS = [
  'id_classe_mapa',
  'id_tipo_mapa',
  'id_ano',
  'id_regiao',
  'codigo_escala',
  'codigo_cor',
  'id_tipo_regionalizacao',
  'id_tema',
  'id_tipo_tema'
];

/**
 * Valida se todos os campos obrigatórios foram preenchidos
 *
 * @param {Object} formWidget - Widget do formulário
 * @returns {boolean} - true se válido, false se inválido
 */
function validateRequiredFields(formWidget) {
  const errors = [];

  REQUIRED_FIELDS.forEach(campo => {
    const value = formWidget.getValue(campo);
    if (!value || value === '') {
      errors.push(campo);
      formWidget.setError(campo, ERROR_MESSAGES.required);
    }
  });

  return errors.length === 0;
}

// ============================================================================
// VALIDAÇÃO DE ATTACHMENTS (PDFs)
// ============================================================================

/**
 * Valida arquivo PDF antes de upload
 *
 * @param {File} file - Arquivo selecionado
 * @returns {Object} - { valid: boolean, error: string }
 */
function validatePDF(file) {
  // Validar tipo de arquivo
  if (file.type !== VALIDATION_CONFIG.pdfMimeType) {
    return {
      valid: false,
      error: ERROR_MESSAGES.pdfOnly
    };
  }

  // Validar tamanho (máximo 50MB)
  if (file.size > VALIDATION_CONFIG.maxFileSize) {
    const sizeMB = (file.size / 1048576).toFixed(2);
    return {
      valid: false,
      error: ERROR_MESSAGES.pdfTooLarge.replace('{size}', sizeMB)
    };
  }

  // Validar nome do arquivo
  if (file.name.length > VALIDATION_CONFIG.maxFileName) {
    return {
      valid: false,
      error: ERROR_MESSAGES.pdfNameTooLong
    };
  }

  // Validar extensão
  if (!file.name.toLowerCase().endsWith('.pdf')) {
    return {
      valid: false,
      error: ERROR_MESSAGES.pdfInvalidExtension
    };
  }

  return {
    valid: true,
    error: null
  };
}

/**
 * Validar header do PDF (verificação adicional)
 *
 * @param {File} file - Arquivo PDF
 * @returns {Promise<boolean>} - true se header válido
 */
async function validatePDFHeader(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();

    reader.onload = (e) => {
      const bytes = new Uint8Array(e.target.result);
      const header = String.fromCharCode(...bytes.slice(0, 4));

      if (header === VALIDATION_CONFIG.pdfHeader) {
        resolve(true);
      } else {
        reject(new Error(ERROR_MESSAGES.pdfInvalidHeader));
      }
    };

    reader.onerror = () => reject(new Error('Erro ao ler arquivo'));
    reader.readAsArrayBuffer(file.slice(0, 4));
  });
}

// ============================================================================
// VALIDAÇÃO COMPLETA DO FORMULÁRIO
// ============================================================================

/**
 * Validação completa do formulário antes de salvar
 *
 * @param {Object} formWidget - Widget do formulário
 * @param {Object} attachmentWidget - Widget de attachments
 * @returns {Promise<Object>} - { valid: boolean, errors: array }
 */
async function validateForm(formWidget, attachmentWidget) {
  const errors = [];

  // 1. Validar campos obrigatórios
  if (!validateRequiredFields(formWidget)) {
    errors.push({
      field: 'required',
      message: ERROR_MESSAGES.formInvalid
    });
  }

  // 2. Validar Classe + Tipo
  const classe = formWidget.getValue('id_classe_mapa');
  const tipo = formWidget.getValue('id_tipo_mapa');
  if (classe && tipo) {
    const isValid = await validateClasseTipo(classe, tipo);
    if (!isValid) {
      errors.push({
        field: 'id_tipo_mapa',
        message: ERROR_MESSAGES.invalidClasseTipo
      });
    }
  }

  // 3. Validar Tipo Regionalização + Região
  const tipoReg = formWidget.getValue('id_tipo_regionalizacao');
  const regiao = formWidget.getValue('id_regiao');
  if (tipoReg && regiao) {
    const isValid = await validateRegionalizacaoRegiao(tipoReg, regiao);
    if (!isValid) {
      errors.push({
        field: 'id_regiao',
        message: ERROR_MESSAGES.invalidRegiao
      });
    }
  }

  // 4. Validar Tipo Tema + Tema
  const tipoTema = formWidget.getValue('id_tipo_tema');
  const tema = formWidget.getValue('id_tema');
  if (tipoTema && tema) {
    const isValid = await validateTipoTemaTema(tipoTema, tema);
    if (!isValid) {
      errors.push({
        field: 'id_tema',
        message: ERROR_MESSAGES.invalidTema
      });
    }
  }

  // 5. Validar attachment (se houver)
  const attachments = attachmentWidget.getAttachments();
  if (attachments.length === 0) {
    errors.push({
      field: 'attachment',
      message: ERROR_MESSAGES.pdfRequired
    });
  }

  return {
    valid: errors.length === 0,
    errors: errors
  };
}

// ============================================================================
// FUNÇÕES AUXILIARES
// ============================================================================

/**
 * Query em Feature Service
 *
 * @param {string} serviceName - Nome do Feature Service
 * @param {number} layerId - ID da layer
 * @param {Object} queryParams - Parâmetros de query
 * @returns {Promise<Object>} - Resultado da query
 */
async function queryFeatureService(serviceName, layerId, queryParams) {
  // Esta função deve ser implementada usando a API do ArcGIS Experience Builder
  // Exemplo de uso com esri/rest/query

  const query = {
    url: `${getFeatureServiceUrl(serviceName)}/${layerId}`,
    ...queryParams
  };

  return await esriRequest(query);
}

/**
 * Obtém URL do Feature Service baseado no nome
 *
 * @param {string} serviceName - Nome do serviço
 * @returns {string} - URL completa
 */
function getFeatureServiceUrl(serviceName) {
  const baseUrl = window.jimuConfig?.arcgisServerUrl || '';
  const serviceMap = {
    'FS_Mapoteca_Publicacoes': `${baseUrl}/rest/services/Mapoteca/FS_Mapoteca_Publicacoes/FeatureServer`,
    'FS_Mapoteca_Dominios': `${baseUrl}/rest/services/Mapoteca/FS_Mapoteca_Dominios/FeatureServer`,
    'FS_Mapoteca_Relacionamentos': `${baseUrl}/rest/services/Mapoteca/FS_Mapoteca_Relacionamentos/FeatureServer`
  };

  return serviceMap[serviceName] || '';
}

/**
 * Debounce function para performance
 */
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// ============================================================================
// EXPORTAÇÕES
// ============================================================================

// Exportar funções públicas para uso no Experience Builder
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    // Validações principais
    validateClasseTipo,
    validateRegionalizacaoRegiao,
    validateTipoTemaTema,
    validatePDF,
    validatePDFHeader,
    validateForm,
    validateRequiredFields,

    // Handlers
    onClasseMapaChange,
    onTipoMapaChange,
    onTipoRegionalizacaoChange,
    onTipoTemaChange,

    // Carregamento de dados
    loadRegioesValidas,
    loadTemasValidos,

    // Utilitários
    queryFeatureService,
    debounce,

    // Constantes
    VALIDATION_CONFIG,
    ERROR_MESSAGES,
    REQUIRED_FIELDS
  };
}
