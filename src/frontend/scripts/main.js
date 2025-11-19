/**
 * 🚀 Main Entry Point - Mapoteca Digital Frontend
 *
 * Ponto de entrada principal que inicializa a aplicação e
 * integra todos os módulos (validação, form handler, attachment handler).
 *
 * @version 1.0.0
 * @author SEIGEO - SEI-BA
 * @date 2025-11-19
 */

import { initializeForm } from './form-handler.js';
import { initializeAttachmentWidget } from './attachment-handler.js';
import {
  onClasseMapaChange,
  onTipoMapaChange,
  onTipoRegionalizacaoChange,
  onTipoTemaChange
} from './validation.js';

// ============================================================================
// CONFIGURAÇÃO GLOBAL
// ============================================================================

const APP_CONFIG = {
  name: 'Mapoteca Digital - Sistema de Cadastro',
  version: '1.0.0',
  environment: 'production', // 'development' | 'staging' | 'production'
  debug: false
};

// ============================================================================
// INICIALIZAÇÃO DA APLICAÇÃO
// ============================================================================

/**
 * Inicializa a aplicação Mapoteca Digital
 * Chamado automaticamente quando o Experience Builder carrega
 */
export function initializeApp() {
  console.log(`🚀 Inicializando ${APP_CONFIG.name} v${APP_CONFIG.version}...`);

  try {
    // 1. Obter referências aos widgets
    const widgets = getWidgetReferences();

    if (!widgets.formWidget || !widgets.attachmentWidget || !widgets.listWidget) {
      throw new Error('Widgets obrigatórios não encontrados');
    }

    // 2. Inicializar formulário
    initializeForm(
      widgets.formWidget,
      widgets.attachmentWidget,
      widgets.listWidget
    );

    // 3. Inicializar widget de attachments
    initializeAttachmentWidget(widgets.attachmentWidget);

    // 4. Configurar event listeners globais
    setupGlobalEventListeners(widgets);

    // 5. Carregar dados iniciais
    loadInitialData(widgets);

    // 6. Configurar monitoramento de erros
    setupErrorMonitoring();

    console.log('✅ Aplicação inicializada com sucesso!');

  } catch (error) {
    console.error('❌ Erro ao inicializar aplicação:', error);
    showErrorNotification('Erro ao inicializar aplicação. Por favor, recarregue a página.');
  }
}

/**
 * Obtém referências aos widgets do Experience Builder
 */
function getWidgetReferences() {
  // No Experience Builder, os widgets são acessíveis via jimu
  const jimu = window.jimu;

  if (!jimu) {
    throw new Error('Experience Builder SDK não encontrado');
  }

  return {
    formWidget: jimu.getWidget('form_widget'),
    attachmentWidget: jimu.getWidget('attachment_widget'),
    listWidget: jimu.getWidget('list_widget'),
    headerWidget: jimu.getWidget('header_widget'),
    buttonGroupWidget: jimu.getWidget('button_group_widget')
  };
}

/**
 * Configura event listeners globais
 */
function setupGlobalEventListeners(widgets) {
  // Event listener para mudanças na lista
  if (widgets.listWidget) {
    widgets.listWidget.on('selectionChanged', (event) => {
      handleListSelectionChanged(event, widgets);
    });
  }

  // Event listener para navegação
  window.addEventListener('beforeunload', (event) => {
    if (widgets.formWidget.isDirty()) {
      event.preventDefault();
      event.returnValue = 'Há alterações não salvas. Deseja realmente sair?';
    }
  });

  // Event listener para erros não capturados
  window.addEventListener('error', (event) => {
    console.error('Erro não capturado:', event.error);
    if (APP_CONFIG.debug) {
      showErrorNotification(`Erro: ${event.error.message}`);
    }
  });

  // Event listener para rejeições de promises não tratadas
  window.addEventListener('unhandledrejection', (event) => {
    console.error('Promise rejeitada não tratada:', event.reason);
    if (APP_CONFIG.debug) {
      showErrorNotification(`Promise rejeitada: ${event.reason}`);
    }
  });
}

/**
 * Carrega dados iniciais necessários
 */
async function loadInitialData(widgets) {
  console.log('Carregando dados iniciais...');

  try {
    // Carregar lista de publicações recentes
    if (widgets.listWidget) {
      await widgets.listWidget.refresh();
    }

    // Carregar dados de domínio (cache)
    await preloadDomainData();

    console.log('✅ Dados iniciais carregados');
  } catch (error) {
    console.error('Erro ao carregar dados iniciais:', error);
    // Não bloquear a aplicação se falhar
  }
}

/**
 * Pré-carrega dados de domínio para cache
 */
async function preloadDomainData() {
  const domainTables = [
    't_classe_mapa',
    't_tipo_mapa',
    't_anos',
    't_escala',
    't_cor',
    't_tipo_tema',
    't_tipo_regionalizacao'
  ];

  const promises = domainTables.map(table => {
    return queryDomainTable(table);
  });

  await Promise.all(promises);
}

/**
 * Query em tabela de domínio
 */
async function queryDomainTable(tableName) {
  // Implementar query usando ESRI API
  // Armazenar em cache local
  console.log(`Carregando ${tableName}...`);
}

/**
 * Handler para mudança de seleção na lista
 */
function handleListSelectionChanged(event, widgets) {
  const selectedFeature = event.selectedFeature;

  if (selectedFeature) {
    // Carregar publicação no formulário para edição
    loadPublicacaoForEdit(
      widgets.formWidget,
      widgets.attachmentWidget,
      selectedFeature.attributes.id_publicacao
    );
  }
}

/**
 * Configura monitoramento de erros
 */
function setupErrorMonitoring() {
  // Implementar integração com sistema de monitoramento
  // Ex: Sentry, Application Insights, etc.

  if (APP_CONFIG.environment === 'production') {
    console.log('Monitoramento de erros ativado');
  }
}

/**
 * Mostra notificação de erro
 */
function showErrorNotification(message) {
  if (window.jimu?.showNotification) {
    window.jimu.showNotification({
      type: 'error',
      message: message,
      duration: 5000
    });
  } else {
    alert(`ERRO: ${message}`);
  }
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Obtém configuração da aplicação
 */
export function getAppConfig() {
  return { ...APP_CONFIG };
}

/**
 * Obtém versão da aplicação
 */
export function getAppVersion() {
  return APP_CONFIG.version;
}

/**
 * Ativa modo debug
 */
export function enableDebugMode() {
  APP_CONFIG.debug = true;
  console.log('🐛 Modo debug ativado');
}

/**
 * Desativa modo debug
 */
export function disableDebugMode() {
  APP_CONFIG.debug = false;
  console.log('Modo debug desativado');
}

/**
 * Obtém estatísticas da aplicação
 */
export async function getAppStats() {
  try {
    const stats = {
      version: APP_CONFIG.version,
      environment: APP_CONFIG.environment,
      uptime: performance.now(),
      memory: performance.memory ? {
        usedJSHeapSize: performance.memory.usedJSHeapSize,
        totalJSHeapSize: performance.memory.totalJSHeapSize,
        jsHeapSizeLimit: performance.memory.jsHeapSizeLimit
      } : null,
      timestamp: new Date().toISOString()
    };

    return stats;
  } catch (error) {
    console.error('Erro ao obter estatísticas:', error);
    return null;
  }
}

// ============================================================================
// AUTO-INICIALIZAÇÃO
// ============================================================================

/**
 * Auto-inicialização quando o DOM estiver pronto
 * No Experience Builder, aguardar evento de inicialização
 */
if (typeof window !== 'undefined') {
  // Aguardar Experience Builder estar pronto
  if (window.jimuConfig?.isReady) {
    initializeApp();
  } else {
    window.addEventListener('jimuReady', initializeApp);
  }

  // Expor funcionalidades globalmente para debug (apenas em dev)
  if (APP_CONFIG.debug || APP_CONFIG.environment === 'development') {
    window.MapotecaDigital = {
      initializeApp,
      getAppConfig,
      getAppVersion,
      enableDebugMode,
      disableDebugMode,
      getAppStats
    };

    console.log('🐛 Funções de debug disponíveis em window.MapotecaDigital');
  }
}

// ============================================================================
// EXPORTAÇÕES
// ============================================================================

export default {
  initializeApp,
  getAppConfig,
  getAppVersion,
  enableDebugMode,
  disableDebugMode,
  getAppStats
};
