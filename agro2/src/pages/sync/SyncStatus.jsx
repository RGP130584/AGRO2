import React, { useState, useEffect } from 'react';
import { RefreshCw, Wifi, WifiOff, CheckCircle2, Clock, ShieldCheck, Database } from 'lucide-react';
import { db } from '../../db/database.js';
import { useSync } from '../../contexts/SyncContext.jsx';
import { formatarData } from '../../utils/formatters.js';

export default function SyncStatus() {
  const { isOnline, pendingCount, isSyncing, lastSyncTime, syncError, syncNow } = useSync();
  const [eventosFila, setEventosFila] = useState([]);
  const [stats, setStats] = useState({ animais: 0, aplicacoes: 0, pesagens: 0 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    carregarFila();
  }, [isSyncing, pendingCount]);

  async function carregarFila() {
    try {
      const [fila, cAnimais, cAplicacoes, cPesagens] = await Promise.all([
        db.sync_queue.reverse().limit(30).toArray(),
        db.animais.count(),
        db.aplicacoes_sanitarias.count(),
        db.pesagens.count()
      ]);
      setEventosFila(fila);
      setStats({ animais: cAnimais, aplicacoes: cAplicacoes, pesagens: cPesagens });
    } catch (e) {
      console.error('Erro ao carregar fila:', e);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Motor de Sincronização & Persistência Offline</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Fila outbox de transações locais e espelhamento com servidor central
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
            <div className="kpi-label">Banco Local IndexedDB</div>
            <div className="kpi-value">{stats.animais + stats.aplicacoes + stats.pesagens} <span style={{ fontSize: '14px', fontWeight: 500, color: '#64748b' }}>regs</span></div>
          </div>
          <div className="kpi-icon" style={{ background: '#e0f2fe', color: '#0284c7' }}>
            <Database size={24} />
          </div>
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
