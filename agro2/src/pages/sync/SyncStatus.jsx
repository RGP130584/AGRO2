import React, { useState, useEffect } from 'react';
import { RefreshCw, Wifi, WifiOff, CheckCircle2, Clock, ShieldCheck, Database, Download, Upload, HardDrive } from 'lucide-react';
import { db } from '../../db/database.js';
import { useSync } from '../../contexts/SyncContext.jsx';
import { formatarData } from '../../utils/formatters.js';
import { exportarBackupLocal, importarBackupLocal } from '../../utils/backupHelper.js';

export default function SyncStatus() {
  const { isOnline, pendingCount, isSyncing, lastSyncTime, syncError, syncNow } = useSync();
  const [eventosFila, setEventosFila] = useState([]);
  const [stats, setStats] = useState({ animais: 0, aplicacoes: 0, pesagens: 0, usuarios: 0 });
  const [loading, setLoading] = useState(true);
  const [backupMsg, setBackupMsg] = useState('');

  useEffect(() => {
    carregarFila();
  }, [isSyncing, pendingCount]);

  async function carregarFila() {
    try {
      const [fila, cAnimais, cAplicacoes, cPesagens, cUsuarios] = await Promise.all([
        db.sync_queue.reverse().limit(30).toArray(),
        db.animais.count(),
        db.aplicacoes_sanitarias.count(),
        db.pesagens.count(),
        db.usuarios.count()
      ]);
      setEventosFila(fila);
      setStats({ animais: cAnimais, aplicacoes: cAplicacoes, pesagens: cPesagens, usuarios: cUsuarios });
    } catch (e) {
      console.error('Erro ao carregar fila:', e);
    } finally {
      setLoading(false);
    }
  }

  const handleExportarBackup = async () => {
    try {
      setBackupMsg('Gerando cópia de segurança em arquivo JSON...');
      await exportarBackupLocal();
      setBackupMsg('✅ Backup exportado com sucesso! Arquivo salvo no seu dispositivo.');
      setTimeout(() => setBackupMsg(''), 4000);
    } catch (e) {
      console.error(e);
      alert('Erro ao exportar arquivo de backup.');
      setBackupMsg('');
    }
  };

  const handleImportarBackup = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    if (!window.confirm('⚠️ ATENÇÃO: Importar um backup irá restaurar todos os cadastros de animais, pesagens e usuários a partir do arquivo selecionado. Deseja continuar?')) {
      return;
    }

    try {
      setBackupMsg('Restaurando banco de dados a partir do backup...');
      const text = await file.text();
      await importarBackupLocal(text);
      await carregarFila();
      setBackupMsg('✅ Backup restaurado com sucesso!');
      alert('✅ Banco de dados restaurado com sucesso! Todos os cadastros e usuários foram atualizados.');
      setTimeout(() => setBackupMsg(''), 4000);
    } catch (err) {
      console.error(err);
      alert('Erro ao importar arquivo de backup. Verifique se o arquivo JSON é válido.');
      setBackupMsg('');
    }
  };

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Motor de Sincronização & Proteção de Dados</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Garantia de persistência total dos animais, usuários e fila outbox de transações
          </p>
        </div>

        <button
          onClick={syncNow}
          disabled={isSyncing}
          className="btn btn-primary"
        >
          <RefreshCw size={16} className={isSyncing ? 'animate-spin' : ''} />
          <span>{isSyncing ? 'Sincronizando...' : 'Sincronizar Agora'}</span>
        </button>
      </div>

      {syncError && (
        <div style={{
          backgroundColor: '#fff7ed',
          border: '1px solid #fdba74',
          borderRadius: '12px',
          padding: '12px 16px',
          marginBottom: '20px',
          color: '#c2410c',
          fontSize: '14px',
          fontWeight: 500,
          display: 'flex',
          alignItems: 'center',
          gap: '10px'
        }}>
          <Clock size={18} color="#ea580c" />
          <span>{syncError}</span>
        </div>
      )}

      {/* Cartões de Status */}
      <div className="kpi-grid">
        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">Conexão Atual</div>
            <div className="kpi-value" style={{ color: isOnline ? '#15803d' : '#dc2626' }}>
              {isOnline ? 'Online' : 'Offline'}
            </div>
          </div>
          <div className="kpi-icon" style={{ background: isOnline ? '#dcfce7' : '#fee2e2', color: isOnline ? '#15803d' : '#dc2626' }}>
            {isOnline ? <Wifi size={24} /> : <WifiOff size={24} />}
          </div>
        </div>

        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">Fila Outbox Pendente</div>
            <div className="kpi-value" style={{ color: pendingCount > 0 ? '#ea580c' : '#15803d' }}>
              {pendingCount} <span style={{ fontSize: '14px', fontWeight: 500, color: '#64748b' }}>eventos</span>
            </div>
          </div>
          <div className="kpi-icon" style={{ background: pendingCount > 0 ? '#ffedd5' : '#dcfce7', color: pendingCount > 0 ? '#ea580c' : '#15803d' }}>
            <Clock size={24} />
          </div>
        </div>

        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">Base Local Protegida</div>
            <div className="kpi-value">{stats.animais} <span style={{ fontSize: '14px', fontWeight: 500, color: '#64748b' }}>animais</span></div>
          </div>
          <div className="kpi-icon" style={{ background: '#e0f2fe', color: '#0284c7' }}>
            <Database size={24} />
          </div>
        </div>
      </div>

      {/* PAINEL DE BACKUP & SEGURANÇA TOTAL DE DADOS */}
      <div className="card" style={{ marginBottom: '24px', background: '#f8fafc', border: '1px solid #cbd5e1' }}>
        <div className="card-header" style={{ marginBottom: '10px' }}>
          <h4 className="card-title">
            <HardDrive size={18} color="#15803d" />
            <span>Cópia de Segurança Local (Backup 100% Garantido)</span>
          </h4>
        </div>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '16px' }}>
          Baixe um arquivo de backup em JSON a qualquer momento com todos os cadastros de animais, usuários, vacinas e pesagens. Nenhuma informação será perdida.
        </p>

        {backupMsg && (
          <div style={{ padding: '10px 14px', borderRadius: '8px', background: '#dcfce7', color: '#15803d', fontWeight: 600, fontSize: '13px', marginBottom: '14px' }}>
            {backupMsg}
          </div>
        )}

        <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
          <button
            onClick={handleExportarBackup}
            className="btn btn-primary btn-sm"
            style={{ flex: '1 1 auto', justifyContent: 'center' }}
          >
            <Download size={16} />
            <span>Exportar Backup (Baixar JSON)</span>
          </button>

          <label
            className="btn btn-secondary btn-sm"
            style={{ flex: '1 1 auto', justifyContent: 'center', cursor: 'pointer', margin: 0 }}
          >
            <Upload size={16} />
            <span>Restaurar Backup (Carregar JSON)</span>
            <input
              type="file"
              accept=".json"
              onChange={handleImportarBackup}
              style={{ display: 'none' }}
            />
          </label>
        </div>
      </div>

      {/* Tabela de Eventos da Fila Outbox */}
      <div className="card">
        <div className="card-header">
          <h4 className="card-title">
            <RefreshCw size={18} className="text-primary" />
            <span>Fila de Eventos & Transações Locais</span>
          </h4>
          <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
            Último sync: {lastSyncTime || 'Nunca'}
          </span>
        </div>

        {eventosFila.length === 0 ? (
          <div style={{ padding: '30px', textAlign: 'center', color: 'var(--text-muted)' }}>
            <CheckCircle2 size={36} color="#16a34a" style={{ margin: '0 auto 8px auto', display: 'block' }} />
            <div style={{ fontWeight: 600 }}>Tudo sincronizado!</div>
            <div style={{ fontSize: '12px' }}>Não há operações pendentes no momento.</div>
          </div>
        ) : (
          <div className="table-container">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Data/Hora</th>
                  <th>Entidade</th>
                  <th>Ação</th>
                  <th>ID do Registro</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {eventosFila.map((ev) => (
                  <tr key={ev.id}>
                    <td style={{ fontSize: '13px' }}>{new Date(ev.created_at).toLocaleString('pt-BR')}</td>
                    <td style={{ fontWeight: 600, textTransform: 'capitalize' }}>{ev.entidade}</td>
                    <td>
                      <span className="badge badge-info" style={{ textTransform: 'uppercase', fontSize: '11px' }}>
                        {ev.acao}
                      </span>
                    </td>
                    <td style={{ fontSize: '12px', color: 'var(--text-muted)', fontFamily: 'monospace' }}>
                      {ev.entidade_id}
                    </td>
                    <td>
                      {ev.status === 'synced' ? (
                        <span className="badge badge-liberado">Sincronizado</span>
                      ) : (
                        <span className="badge badge-warning">Pendente</span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}

