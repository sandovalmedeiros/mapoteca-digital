/**
 * 📝 Form Handler Scripts - Mapoteca Digital
 *
 * Script para gerenciamento do formulário de cadastro incluindo
 * salvamento, edição, limpeza e ações do usuário.
 *
 * @version 1.0.0
 * @author SEIGEO - SEI-BA
 * @date 2025-11-19
 */

// Importar validações
import {
  validateForm,
  onClasseMapaChange,
  onTipoMapaChange,
  onTipoRegionalizacaoChange,
  onTipoTemaChange,
  debounce
} from './validation.js';

// ============================================================================
// CONFIGURAÇÃO
// ============================================================================

const FORM_CONFIG = {
  autoSave: false,
  showSuccessMessage: true,
  showErrorMessage: true,
  clearAfterSave: true,
  refreshListAfterSave: true,
  confirmBeforeDelete: true
};

const NOTIFICATION_DURATION = 5000; // 5 segundos

// ============================================================================
// INICIALIZAÇÃO DO FORMULÁRIO
// ============================================================================

/**
 * Inicializa o formulário e configura todos os event listeners
 *
 * @param {Object} formWidget - Widget do formulário Experience Builder
 * @param {Object} attachmentWidget - Widget de attachments
 * @param {Object} listWidget - Widget de lista de publicações
 */
export function initializeForm(formWidget, attachmentWidget, listWidget) {
  console.log('Inicializando formulário da Mapoteca Digital...');

  // Configurar event listeners dos campos
  setupFieldListeners(formWidget);

  // Configurar event listeners dos botões
  setupButtonListeners(formWidget, attachmentWidget, listWidget);

  // Configurar validação em tempo real
  setupRealtimeValidation(formWidget);

  // Desabilitar botão salvar inicialmente
  disableSaveButton();

  console.log('Formulário inicializado com sucesso!');
}

/**
 * Configura listeners para os campos do formulário
 */
function setupFieldListeners(formWidget) {
  // Classe do Mapa
  formWidget.on('field:id_classe_mapa:change', debounce((event) => {
    onClasseMapaChange(formWidget, event.value);
    updateSaveButtonState(formWidget);
  }, 300));

  // Tipo do Mapa
  formWidget.on('field:id_tipo_mapa:change', debounce((event) => {
    onTipoMapaChange(formWidget, event.value);
    updateSaveButtonState(formWidget);
  }, 300));

  // Tipo de Regionalização
  formWidget.on('field:id_tipo_regionalizacao:change', debounce((event) => {
    onTipoRegionalizacaoChange(formWidget, event.value);
    updateSaveButtonState(formWidget);
  }, 300));

  // Tipo de Tema
  formWidget.on('field:id_tipo_tema:change', debounce((event) => {
    onTipoTemaChange(formWidget, event.value);
    updateSaveButtonState(formWidget);
  }, 300));

  // Outros campos - apenas atualizar estado do botão
  const otherFields = [
    'id_ano',
    'id_regiao',
    'id_tema',
    'codigo_escala',
    'codigo_cor'
  ];

  otherFields.forEach(fieldName => {
    formWidget.on(`field:${fieldName}:change`, () => {
      updateSaveButtonState(formWidget);
    });
  });
}

/**
 * Configura listeners para os botões do formulário
 */
function setupButtonListeners(formWidget, attachmentWidget, listWidget) {
  // Botão Salvar
  const btnSave = document.getElementById('btnSave');
  if (btnSave) {
    btnSave.addEventListener('click', async () => {
      await handleSaveForm(formWidget, attachmentWidget, listWidget);
    });
  }

  // Botão Limpar
  const btnClear = document.getElementById('btnClear');
  if (btnClear) {
    btnClear.addEventListener('click', () => {
      handleClearForm(formWidget, attachmentWidget);
    });
  }

  // Botão Cancelar
  const btnCancel = document.getElementById('btnCancel');
  if (btnCancel) {
    btnCancel.addEventListener('click', () => {
      handleCancelForm(formWidget, attachmentWidget);
    });
  }
}

/**
 * Configura validação em tempo real
 */
function setupRealtimeValidation(formWidget) {
  formWidget.on('change', debounce(() => {
    updateSaveButtonState(formWidget);
  }, 500));
}

// ============================================================================
// MANIPULAÇÃO DO FORMULÁRIO
// ============================================================================

/**
 * Salva o formulário após validação completa
 *
 * @param {Object} formWidget - Widget do formulário
 * @param {Object} attachmentWidget - Widget de attachments
 * @param {Object} listWidget - Widget de lista
 */
export async function handleSaveForm(formWidget, attachmentWidget, listWidget) {
  console.log('Salvando publicação...');

  // Mostrar loading
  showLoading('Salvando publicação...');

  try {
    // 1. Validar formulário completo
    const validation = await validateForm(formWidget, attachmentWidget);

    if (!validation.valid) {
      hideLoading();
      showNotification('error', 'Existem erros no formulário. Corrija antes de salvar.');

      // Mostrar erros específicos
      validation.errors.forEach(error => {
        formWidget.setError(error.field, error.message);
      });

      return;
    }

    // 2. Coletar dados do formulário
    const formData = collectFormData(formWidget);

    // 3. Salvar publicação no Feature Service
    const publicacaoId = await savePublicacao(formData);

    if (!publicacaoId) {
      throw new Error('Erro ao salvar publicação - ID não retornado');
    }

    // 4. Upload de attachments (PDFs)
    const attachments = attachmentWidget.getFiles();
    if (attachments.length > 0) {
      await uploadAttachments(publicacaoId, attachments);
    }

    // 5. Sucesso!
    hideLoading();
    showNotification('success', 'Publicação salva com sucesso!');

    // 6. Limpar formulário se configurado
    if (FORM_CONFIG.clearAfterSave) {
      handleClearForm(formWidget, attachmentWidget);
    }

    // 7. Atualizar lista
    if (FORM_CONFIG.refreshListAfterSave && listWidget) {
      listWidget.refresh();
    }

  } catch (error) {
    hideLoading();
    console.error('Erro ao salvar publicação:', error);
    showNotification('error', `Erro ao salvar publicação: ${error.message}`);
  }
}

/**
 * Limpa o formulário
 *
 * @param {Object} formWidget - Widget do formulário
 * @param {Object} attachmentWidget - Widget de attachments
 */
export function handleClearForm(formWidget, attachmentWidget) {
  console.log('Limpando formulário...');

  // Limpar todos os campos
  formWidget.clearAllValues();

  // Limpar erros
  formWidget.clearAllErrors();

  // Limpar attachments
  if (attachmentWidget) {
    attachmentWidget.clearAllFiles();
  }

  // Desabilitar campos dependentes
  formWidget.disableField('id_regiao');
  formWidget.disableField('id_tema');

  // Desabilitar botão salvar
  disableSaveButton();

  showNotification('info', 'Formulário limpo');
}

/**
 * Cancela edição e retorna ao estado inicial
 *
 * @param {Object} formWidget - Widget do formulário
 * @param {Object} attachmentWidget - Widget de attachments
 */
export function handleCancelForm(formWidget, attachmentWidget) {
  console.log('Cancelando edição...');

  // Verificar se há alterações não salvas
  if (formWidget.isDirty()) {
    const confirm = window.confirm(
      'Há alterações não salvas. Deseja realmente cancelar?'
    );

    if (!confirm) {
      return;
    }
  }

  // Limpar formulário
  handleClearForm(formWidget, attachmentWidget);

  // Se estava em modo de edição, resetar para modo de criação
  formWidget.setMode('create');
}

// ============================================================================
// EDIÇÃO DE PUBLICAÇÕES EXISTENTES
// ============================================================================

/**
 * Carrega publicação existente para edição
 *
 * @param {Object} formWidget - Widget do formulário
 * @param {Object} attachmentWidget - Widget de attachments
 * @param {number} publicacaoId - ID da publicação
 */
export async function loadPublicacaoForEdit(formWidget, attachmentWidget, publicacaoId) {
  console.log(`Carregando publicação ${publicacaoId} para edição...`);

  showLoading('Carregando publicação...');

  try {
    // 1. Buscar dados da publicação
    const publicacao = await fetchPublicacao(publicacaoId);

    if (!publicacao) {
      throw new Error('Publicação não encontrada');
    }

    // 2. Preencher formulário
    formWidget.setMode('edit');
    formWidget.setValues(publicacao);

    // 3. Carregar opções cascata antes de setar valores
    if (publicacao.id_tipo_regionalizacao) {
      await onTipoRegionalizacaoChange(formWidget, publicacao.id_tipo_regionalizacao);
      formWidget.setValue('id_regiao', publicacao.id_regiao);
    }

    if (publicacao.id_tipo_tema) {
      await onTipoTemaChange(formWidget, publicacao.id_tipo_tema);
      formWidget.setValue('id_tema', publicacao.id_tema);
    }

    // 4. Carregar attachments
    const attachments = await fetchAttachments(publicacaoId);
    if (attachments.length > 0) {
      attachmentWidget.setAttachments(attachments);
    }

    hideLoading();
    showNotification('info', 'Publicação carregada para edição');

  } catch (error) {
    hideLoading();
    console.error('Erro ao carregar publicação:', error);
    showNotification('error', `Erro ao carregar publicação: ${error.message}`);
  }
}

/**
 * Exclui publicação
 *
 * @param {Object} listWidget - Widget de lista
 * @param {number} publicacaoId - ID da publicação
 */
export async function deletePublicacao(listWidget, publicacaoId) {
  console.log(`Excluindo publicação ${publicacaoId}...`);

  // Confirmar exclusão
  if (FORM_CONFIG.confirmBeforeDelete) {
    const confirm = window.confirm(
      'Tem certeza que deseja excluir esta publicação? Esta ação não pode ser desfeita.'
    );

    if (!confirm) {
      return;
    }
  }

  showLoading('Excluindo publicação...');

  try {
    // 1. Excluir attachments primeiro
    await deleteAllAttachments(publicacaoId);

    // 2. Excluir publicação
    await deletePublicacaoRecord(publicacaoId);

    // 3. Atualizar lista
    if (listWidget) {
      listWidget.refresh();
    }

    hideLoading();
    showNotification('success', 'Publicação excluída com sucesso!');

  } catch (error) {
    hideLoading();
    console.error('Erro ao excluir publicação:', error);
    showNotification('error', `Erro ao excluir publicação: ${error.message}`);
  }
}

// ============================================================================
// FUNÇÕES DE DADOS (API)
// ============================================================================

/**
 * Coleta dados do formulário
 */
function collectFormData(formWidget) {
  return {
    id_classe_mapa: formWidget.getValue('id_classe_mapa'),
    id_tipo_mapa: formWidget.getValue('id_tipo_mapa'),
    id_ano: formWidget.getValue('id_ano'),
    id_regiao: formWidget.getValue('id_regiao'),
    id_tipo_regionalizacao: formWidget.getValue('id_tipo_regionalizacao'),
    id_tema: formWidget.getValue('id_tema'),
    id_tipo_tema: formWidget.getValue('id_tipo_tema'),
    codigo_escala: formWidget.getValue('codigo_escala'),
    codigo_cor: formWidget.getValue('codigo_cor'),
    usuario_criacao: getCurrentUser(),
    data_criacao: new Date().toISOString()
  };
}

/**
 * Salva publicação no Feature Service
 */
async function savePublicacao(formData) {
  const featureServiceUrl = getFeatureServiceUrl('FS_Mapoteca_Publicacoes', 0);

  const feature = {
    attributes: formData
  };

  const response = await fetch(`${featureServiceUrl}/addFeatures`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      features: [feature],
      f: 'json'
    })
  });

  const result = await response.json();

  if (result.addResults && result.addResults[0].success) {
    return result.addResults[0].objectId;
  }

  throw new Error(result.error?.message || 'Erro ao salvar publicação');
}

/**
 * Busca publicação por ID
 */
async function fetchPublicacao(publicacaoId) {
  const featureServiceUrl = getFeatureServiceUrl('FS_Mapoteca_Publicacoes', 0);

  const response = await fetch(`${featureServiceUrl}/query?where=id_publicacao=${publicacaoId}&outFields=*&f=json`);

  const result = await response.json();

  if (result.features && result.features.length > 0) {
    return result.features[0].attributes;
  }

  return null;
}

/**
 * Exclui registro de publicação
 */
async function deletePublicacaoRecord(publicacaoId) {
  const featureServiceUrl = getFeatureServiceUrl('FS_Mapoteca_Publicacoes', 0);

  const response = await fetch(`${featureServiceUrl}/deleteFeatures`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      objectIds: [publicacaoId],
      f: 'json'
    })
  });

  const result = await response.json();

  if (!result.deleteResults || !result.deleteResults[0].success) {
    throw new Error(result.error?.message || 'Erro ao excluir publicação');
  }
}

// ============================================================================
// FUNÇÕES AUXILIARES
// ============================================================================

/**
 * Atualiza estado do botão salvar baseado na validade do formulário
 */
function updateSaveButtonState(formWidget) {
  const isValid = formWidget.isValid();
  const btnSave = document.getElementById('btnSave');

  if (btnSave) {
    btnSave.disabled = !isValid;
    btnSave.classList.toggle('disabled', !isValid);
  }
}

/**
 * Desabilita botão salvar
 */
function disableSaveButton() {
  const btnSave = document.getElementById('btnSave');
  if (btnSave) {
    btnSave.disabled = true;
    btnSave.classList.add('disabled');
  }
}

/**
 * Obtém usuário atual do ArcGIS Portal
 */
function getCurrentUser() {
  return window.jimuConfig?.user?.username || 'system';
}

/**
 * Obtém URL do Feature Service
 */
function getFeatureServiceUrl(serviceName, layerId) {
  const baseUrl = window.jimuConfig?.arcgisServerUrl || '';
  const serviceMap = {
    'FS_Mapoteca_Publicacoes': `${baseUrl}/rest/services/Mapoteca/FS_Mapoteca_Publicacoes/FeatureServer`,
    'FS_Mapoteca_Dominios': `${baseUrl}/rest/services/Mapoteca/FS_Mapoteca_Dominios/FeatureServer`,
    'FS_Mapoteca_Relacionamentos': `${baseUrl}/rest/services/Mapoteca/FS_Mapoteca_Relacionamentos/FeatureServer`
  };

  return `${serviceMap[serviceName]}/${layerId}`;
}

/**
 * Mostra loading overlay
 */
function showLoading(message = 'Carregando...') {
  const loading = document.getElementById('loading-overlay');
  if (loading) {
    loading.querySelector('.loading-message').textContent = message;
    loading.style.display = 'flex';
  }
}

/**
 * Esconde loading overlay
 */
function hideLoading() {
  const loading = document.getElementById('loading-overlay');
  if (loading) {
    loading.style.display = 'none';
  }
}

/**
 * Mostra notificação toast
 *
 * @param {string} type - Tipo: success, error, warning, info
 * @param {string} message - Mensagem
 * @param {number} duration - Duração em ms
 */
function showNotification(type, message, duration = NOTIFICATION_DURATION) {
  console.log(`[${type.toUpperCase()}] ${message}`);

  // Implementar com sistema de notificação do Experience Builder
  const notification = {
    type: type,
    message: message,
    duration: duration
  };

  if (window.jimuConfig?.showNotification) {
    window.jimuConfig.showNotification(notification);
  } else {
    // Fallback para alert
    alert(`${type.toUpperCase()}: ${message}`);
  }
}

// ============================================================================
// EXPORTAÇÕES
// ============================================================================

export default {
  initializeForm,
  handleSaveForm,
  handleClearForm,
  handleCancelForm,
  loadPublicacaoForEdit,
  deletePublicacao
};
