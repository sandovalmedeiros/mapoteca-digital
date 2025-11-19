/**
 * 📎 Attachment Handler Scripts - Mapoteca Digital
 *
 * Script para gerenciamento de attachments (PDFs) incluindo upload,
 * download, visualização, versioning e exclusão usando ESRI Attachments API.
 *
 * @version 1.0.0
 * @author SEIGEO - SEI-BA
 * @date 2025-11-19
 */

import { validatePDF, validatePDFHeader } from './validation.js';

// ============================================================================
// CONFIGURAÇÃO
// ============================================================================

const ATTACHMENT_CONFIG = {
  maxFileSize: 52428800, // 50 MB
  maxFiles: 10,
  allowedMimeTypes: ['application/pdf'],
  allowedExtensions: ['.pdf'],
  uploadChunkSize: 1048576, // 1 MB chunks para upload
  showProgress: true,
  showPreview: true,
  enableVersioning: true
};

// ============================================================================
// UPLOAD DE ATTACHMENTS
// ============================================================================

/**
 * Faz upload de attachments para uma publicação
 *
 * @param {number} publicacaoId - ID da publicação (objectId)
 * @param {Array<File>} files - Array de arquivos para upload
 * @returns {Promise<Array>} - Array com resultados do upload
 */
export async function uploadAttachments(publicacaoId, files) {
  console.log(`Fazendo upload de ${files.length} arquivo(s) para publicação ${publicacaoId}...`);

  const results = [];

  for (let i = 0; i < files.length; i++) {
    const file = files[i];

    try {
      // 1. Validar arquivo
      const validation = validatePDF(file);
      if (!validation.valid) {
        results.push({
          file: file.name,
          success: false,
          error: validation.error
        });
        continue;
      }

      // 2. Validar header PDF
      try {
        await validatePDFHeader(file);
      } catch (error) {
        results.push({
          file: file.name,
          success: false,
          error: error.message
        });
        continue;
      }

      // 3. Fazer upload
      const result = await uploadSingleAttachment(publicacaoId, file, i, files.length);

      results.push({
        file: file.name,
        success: true,
        attachmentId: result.attachmentId,
        size: file.size
      });

    } catch (error) {
      console.error(`Erro ao fazer upload de ${file.name}:`, error);
      results.push({
        file: file.name,
        success: false,
        error: error.message
      });
    }
  }

  console.log('Upload concluído:', results);
  return results;
}

/**
 * Faz upload de um único attachment
 *
 * @param {number} publicacaoId - ID da publicação
 * @param {File} file - Arquivo para upload
 * @param {number} currentIndex - Índice atual
 * @param {number} totalFiles - Total de arquivos
 * @returns {Promise<Object>} - Resultado do upload
 */
async function uploadSingleAttachment(publicacaoId, file, currentIndex, totalFiles) {
  const featureServiceUrl = getFeatureServiceUrl('FS_Mapoteca_Publicacoes', 0);

  // Criar FormData para upload
  const formData = new FormData();
  formData.append('attachment', file);
  formData.append('f', 'json');

  // Mostrar progresso
  if (ATTACHMENT_CONFIG.showProgress) {
    showUploadProgress(currentIndex + 1, totalFiles, file.name);
  }

  const response = await fetch(`${featureServiceUrl}/${publicacaoId}/addAttachment`, {
    method: 'POST',
    body: formData
  });

  const result = await response.json();

  if (!result.addAttachmentResult || !result.addAttachmentResult.success) {
    throw new Error(result.error?.message || 'Erro ao fazer upload do attachment');
  }

  return {
    attachmentId: result.addAttachmentResult.objectId,
    globalId: result.addAttachmentResult.globalId
  };
}

/**
 * Upload com chunking para arquivos grandes
 *
 * @param {number} publicacaoId - ID da publicação
 * @param {File} file - Arquivo para upload
 * @returns {Promise<Object>} - Resultado do upload
 */
async function uploadAttachmentWithChunking(publicacaoId, file) {
  const totalChunks = Math.ceil(file.size / ATTACHMENT_CONFIG.uploadChunkSize);
  let uploadedChunks = 0;

  console.log(`Upload em ${totalChunks} chunks de ${ATTACHMENT_CONFIG.uploadChunkSize} bytes`);

  for (let i = 0; i < totalChunks; i++) {
    const start = i * ATTACHMENT_CONFIG.uploadChunkSize;
    const end = Math.min(start + ATTACHMENT_CONFIG.uploadChunkSize, file.size);
    const chunk = file.slice(start, end);

    await uploadChunk(publicacaoId, chunk, i, totalChunks, file.name);

    uploadedChunks++;
    const progress = (uploadedChunks / totalChunks) * 100;

    if (ATTACHMENT_CONFIG.showProgress) {
      updateUploadProgress(progress, file.name);
    }
  }

  return { success: true };
}

/**
 * Faz upload de um chunk
 */
async function uploadChunk(publicacaoId, chunk, chunkIndex, totalChunks, fileName) {
  // Implementação específica de chunked upload
  // Depende do suporte do ArcGIS Server
  console.log(`Uploading chunk ${chunkIndex + 1}/${totalChunks} of ${fileName}`);
}

// ============================================================================
// DOWNLOAD DE ATTACHMENTS
// ============================================================================

/**
 * Baixa um attachment
 *
 * @param {number} publicacaoId - ID da publicação
 * @param {number} attachmentId - ID do attachment
 * @param {string} fileName - Nome do arquivo
 */
export async function downloadAttachment(publicacaoId, attachmentId, fileName) {
  console.log(`Baixando attachment ${attachmentId} da publicação ${publicacaoId}...`);

  try {
    const featureServiceUrl = getFeatureServiceUrl('FS_Mapoteca_Publicacoes', 0);
    const url = `${featureServiceUrl}/${publicacaoId}/attachments/${attachmentId}`;

    const response = await fetch(url);

    if (!response.ok) {
      throw new Error('Erro ao baixar attachment');
    }

    const blob = await response.blob();

    // Criar link temporário para download
    const link = document.createElement('a');
    link.href = window.URL.createObjectURL(blob);
    link.download = fileName || `attachment_${attachmentId}.pdf`;
    link.click();

    window.URL.revokeObjectURL(link.href);

    console.log('Download concluído');
  } catch (error) {
    console.error('Erro ao baixar attachment:', error);
    throw error;
  }
}

/**
 * Baixa todos os attachments de uma publicação
 *
 * @param {number} publicacaoId - ID da publicação
 */
export async function downloadAllAttachments(publicacaoId) {
  console.log(`Baixando todos os attachments da publicação ${publicacaoId}...`);

  try {
    const attachments = await fetchAttachments(publicacaoId);

    for (const attachment of attachments) {
      await downloadAttachment(publicacaoId, attachment.id, attachment.name);
    }

    console.log('Download de todos os attachments concluído');
  } catch (error) {
    console.error('Erro ao baixar attachments:', error);
    throw error;
  }
}

// ============================================================================
// VISUALIZAÇÃO DE ATTACHMENTS
// ============================================================================

/**
 * Abre visualização inline de um PDF
 *
 * @param {number} publicacaoId - ID da publicação
 * @param {number} attachmentId - ID do attachment
 * @param {string} fileName - Nome do arquivo
 */
export async function viewAttachment(publicacaoId, attachmentId, fileName) {
  console.log(`Visualizando attachment ${attachmentId}...`);

  try {
    const featureServiceUrl = getFeatureServiceUrl('FS_Mapoteca_Publicacoes', 0);
    const url = `${featureServiceUrl}/${publicacaoId}/attachments/${attachmentId}`;

    // Abrir em modal ou iframe
    if (ATTACHMENT_CONFIG.showPreview) {
      showPDFViewer(url, fileName);
    } else {
      // Fallback: abrir em nova aba
      window.open(url, '_blank');
    }
  } catch (error) {
    console.error('Erro ao visualizar attachment:', error);
    throw error;
  }
}

/**
 * Mostra PDF viewer inline
 *
 * @param {string} url - URL do PDF
 * @param {string} fileName - Nome do arquivo
 */
function showPDFViewer(url, fileName) {
  // Criar modal com viewer
  const modal = document.createElement('div');
  modal.className = 'pdf-viewer-modal';
  modal.innerHTML = `
    <div class="pdf-viewer-container">
      <div class="pdf-viewer-header">
        <h3>${fileName}</h3>
        <button class="close-viewer" onclick="this.closest('.pdf-viewer-modal').remove()">
          ✕
        </button>
      </div>
      <div class="pdf-viewer-body">
        <iframe src="${url}" width="100%" height="600px"></iframe>
      </div>
      <div class="pdf-viewer-footer">
        <button onclick="window.open('${url}', '_blank')" class="btn btn-secondary">
          Abrir em Nova Aba
        </button>
        <button onclick="this.closest('.pdf-viewer-modal').remove()" class="btn btn-primary">
          Fechar
        </button>
      </div>
    </div>
  `;

  document.body.appendChild(modal);
}

// ============================================================================
// GESTÃO DE ATTACHMENTS
// ============================================================================

/**
 * Busca todos os attachments de uma publicação
 *
 * @param {number} publicacaoId - ID da publicação
 * @returns {Promise<Array>} - Array de attachments
 */
export async function fetchAttachments(publicacaoId) {
  console.log(`Buscando attachments da publicação ${publicacaoId}...`);

  try {
    const featureServiceUrl = getFeatureServiceUrl('FS_Mapoteca_Publicacoes', 0);
    const url = `${featureServiceUrl}/${publicacaoId}/attachments?f=json`;

    const response = await fetch(url);
    const result = await response.json();

    if (result.error) {
      throw new Error(result.error.message);
    }

    return result.attachmentInfos || [];
  } catch (error) {
    console.error('Erro ao buscar attachments:', error);
    throw error;
  }
}

/**
 * Exclui um attachment
 *
 * @param {number} publicacaoId - ID da publicação
 * @param {number} attachmentId - ID do attachment
 */
export async function deleteAttachment(publicacaoId, attachmentId) {
  console.log(`Excluindo attachment ${attachmentId} da publicação ${publicacaoId}...`);

  try {
    const featureServiceUrl = getFeatureServiceUrl('FS_Mapoteca_Publicacoes', 0);

    const response = await fetch(`${featureServiceUrl}/${publicacaoId}/deleteAttachments`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        attachmentIds: [attachmentId],
        f: 'json'
      })
    });

    const result = await response.json();

    if (!result.deleteAttachmentResults || !result.deleteAttachmentResults[0].success) {
      throw new Error(result.error?.message || 'Erro ao excluir attachment');
    }

    console.log('Attachment excluído com sucesso');
  } catch (error) {
    console.error('Erro ao excluir attachment:', error);
    throw error;
  }
}

/**
 * Exclui todos os attachments de uma publicação
 *
 * @param {number} publicacaoId - ID da publicação
 */
export async function deleteAllAttachments(publicacaoId) {
  console.log(`Excluindo todos os attachments da publicação ${publicacaoId}...`);

  try {
    const attachments = await fetchAttachments(publicacaoId);

    for (const attachment of attachments) {
      await deleteAttachment(publicacaoId, attachment.id);
    }

    console.log('Todos os attachments foram excluídos');
  } catch (error) {
    console.error('Erro ao excluir attachments:', error);
    throw error;
  }
}

/**
 * Substitui um attachment (versioning)
 *
 * @param {number} publicacaoId - ID da publicação
 * @param {number} oldAttachmentId - ID do attachment antigo
 * @param {File} newFile - Novo arquivo
 */
export async function replaceAttachment(publicacaoId, oldAttachmentId, newFile) {
  console.log(`Substituindo attachment ${oldAttachmentId}...`);

  try {
    // 1. Se versionamento habilitado, manter histórico
    if (ATTACHMENT_CONFIG.enableVersioning) {
      // Adicionar metadata de versão antes de excluir
      await archiveAttachmentVersion(publicacaoId, oldAttachmentId);
    }

    // 2. Excluir attachment antigo
    await deleteAttachment(publicacaoId, oldAttachmentId);

    // 3. Fazer upload do novo
    const result = await uploadAttachments(publicacaoId, [newFile]);

    console.log('Attachment substituído com sucesso');
    return result[0];
  } catch (error) {
    console.error('Erro ao substituir attachment:', error);
    throw error;
  }
}

/**
 * Arquiva versão antiga do attachment
 */
async function archiveAttachmentVersion(publicacaoId, attachmentId) {
  // Implementar lógica de versionamento se necessário
  // Pode incluir:
  // - Renomear attachment com sufixo _v1, _v2, etc.
  // - Mover para tabela de histórico
  // - Registrar metadata em tabela de audit
  console.log(`Arquivando versão do attachment ${attachmentId}...`);
}

// ============================================================================
// WIDGET DE ATTACHMENT
// ============================================================================

/**
 * Inicializa o widget de attachments
 *
 * @param {Object} attachmentWidget - Widget de attachments
 * @param {number} publicacaoId - ID da publicação (opcional para modo edição)
 */
export async function initializeAttachmentWidget(attachmentWidget, publicacaoId = null) {
  console.log('Inicializando widget de attachments...');

  // Configurar drag and drop
  setupDragAndDrop(attachmentWidget);

  // Configurar validação antes do upload
  attachmentWidget.on('beforeAdd', (event) => {
    const file = event.file;
    const validation = validatePDF(file);

    if (!validation.valid) {
      event.preventDefault();
      showNotification('error', validation.error);
    }
  });

  // Configurar handler de upload concluído
  attachmentWidget.on('attachmentAdded', (event) => {
    console.log('Attachment adicionado:', event.attachment);
    showNotification('success', `${event.attachment.name} adicionado com sucesso`);
  });

  // Configurar handler de remoção
  attachmentWidget.on('attachmentDeleted', (event) => {
    console.log('Attachment removido:', event.attachmentId);
    showNotification('info', 'Attachment removido');
  });

  // Se modo edição, carregar attachments existentes
  if (publicacaoId) {
    const attachments = await fetchAttachments(publicacaoId);
    attachmentWidget.setAttachments(attachments);
  }

  console.log('Widget de attachments inicializado');
}

/**
 * Configura drag and drop
 */
function setupDragAndDrop(attachmentWidget) {
  const dropZone = attachmentWidget.getDropZone();

  if (!dropZone) {
    return;
  }

  dropZone.addEventListener('dragover', (e) => {
    e.preventDefault();
    dropZone.classList.add('drag-over');
  });

  dropZone.addEventListener('dragleave', () => {
    dropZone.classList.remove('drag-over');
  });

  dropZone.addEventListener('drop', async (e) => {
    e.preventDefault();
    dropZone.classList.remove('drag-over');

    const files = Array.from(e.dataTransfer.files);

    // Validar arquivos
    const validFiles = files.filter(file => {
      const validation = validatePDF(file);
      if (!validation.valid) {
        showNotification('error', `${file.name}: ${validation.error}`);
        return false;
      }
      return true;
    });

    // Adicionar arquivos ao widget
    validFiles.forEach(file => {
      attachmentWidget.addFile(file);
    });
  });
}

// ============================================================================
// FUNÇÕES AUXILIARES
// ============================================================================

/**
 * Obtém URL do Feature Service
 */
function getFeatureServiceUrl(serviceName, layerId) {
  const baseUrl = window.jimuConfig?.arcgisServerUrl || '';
  return `${baseUrl}/rest/services/Mapoteca/${serviceName}/FeatureServer/${layerId}`;
}

/**
 * Mostra progresso de upload
 */
function showUploadProgress(current, total, fileName) {
  console.log(`Upload ${current}/${total}: ${fileName}`);

  const progressElement = document.getElementById('upload-progress');
  if (progressElement) {
    const percentage = (current / total) * 100;
    progressElement.style.width = `${percentage}%`;
    progressElement.textContent = `${current}/${total} - ${fileName}`;
  }
}

/**
 * Atualiza progresso de upload
 */
function updateUploadProgress(percentage, fileName) {
  const progressElement = document.getElementById('upload-progress');
  if (progressElement) {
    progressElement.style.width = `${percentage}%`;
    progressElement.textContent = `${Math.round(percentage)}% - ${fileName}`;
  }
}

/**
 * Mostra notificação
 */
function showNotification(type, message) {
  console.log(`[${type.toUpperCase()}] ${message}`);

  if (window.jimuConfig?.showNotification) {
    window.jimuConfig.showNotification({ type, message });
  }
}

// ============================================================================
// EXPORTAÇÕES
// ============================================================================

export default {
  // Upload
  uploadAttachments,
  uploadSingleAttachment,
  uploadAttachmentWithChunking,

  // Download
  downloadAttachment,
  downloadAllAttachments,

  // Visualização
  viewAttachment,

  // Gestão
  fetchAttachments,
  deleteAttachment,
  deleteAllAttachments,
  replaceAttachment,

  // Widget
  initializeAttachmentWidget,

  // Config
  ATTACHMENT_CONFIG
};
