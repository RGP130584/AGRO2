import { db } from '../db/database.js';

/**
 * Exporta todo o banco IndexedDB local em formato JSON baixável
 */
export async function exportarBackupLocal() {
  try {
    const backupData = {
      version: 1,
      exported_at: new Date().toISOString(),
      app: 'AGRO 2',
      tables: {}
    };

    const tableNames = [
      'fazendas',
      'piquetes',
      'lotes',
      'animais',
      'produtos',
      'aplicacoes_sanitarias',
      'ocorrencias_sanitarias',
      'dietas',
      'fornecimentos_dieta',
      'pesagens',
      'estoque_movimentos',
      'financeiro_lancamentos',
      'usuarios',
      'sync_queue'
    ];

    for (const tableName of tableNames) {
      if (db[tableName]) {
        backupData.tables[tableName] = await db[tableName].toArray();
      }
    }

    const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(backupData, null, 2));
    const downloadAnchor = document.createElement('a');
    const dataHora = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
    downloadAnchor.setAttribute('href', dataStr);
    downloadAnchor.setAttribute('download', `backup_agro2_${dataHora}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();

    return true;
  } catch (err) {
    console.error('Erro ao exportar backup:', err);
    throw err;
  }
}

/**
 * Importa e restaura o banco de dados local a partir de um arquivo JSON
 */
export async function importarBackupLocal(jsonString) {
  try {
    const backupData = JSON.parse(jsonString);
    if (!backupData || !backupData.tables) {
      throw new Error('Arquivo de backup inválido.');
    }

    const tableNames = Object.keys(backupData.tables);

    for (const tableName of tableNames) {
      if (db[tableName]) {
        const rows = backupData.tables[tableName] || [];
        if (rows.length > 0) {
          await db[tableName].clear();
          await db[tableName].bulkAdd(rows);
        }
      }
    }

    return true;
  } catch (err) {
    console.error('Erro ao importar backup:', err);
    throw err;
  }
}
