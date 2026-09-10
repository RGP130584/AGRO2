import React, { useState, useEffect } from 'react';
import { Wifi, WifiOff, RefreshCw, LogOut, ShieldCheck, User, Menu, Home } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext.jsx';
import { useSync } from '../contexts/SyncContext.jsx';
import InstallPrompt from './InstallPrompt.jsx';
import { getActiveFazendaId, setActiveFazendaId, getFazendasList } from '../utils/fazendaHelper.js';

export default function Header({ pageTitle, onToggleSidebar }) {
  const { user, logout } = useAuth();
  const { isOnline, pendingCount, isSyncing, syncNow } = useSync();
  const [fazendas, setFazendas] = useState([]);
  const [activeFazendaIdState, setActiveFazendaIdState] = useState('');

  const carregarFazendas = async () => {
    const list = await getFazendasList();
    setFazendas(list);
    const activeId = await getActiveFazendaId();
    if (activeId) {
      setActiveFazendaIdState(activeId);
    }
  };

  useEffect(() => {
    carregarFazendas();

    const handleFazendaChange = (e) => {
      if (e.detail) {
        setActiveFazendaIdState(e.detail);
      }
      carregarFazendas();
    };

    window.addEventListener('agro2_fazenda_changed', handleFazendaChange);
    window.addEventListener('agro2_sync_updated', carregarFazendas);

    return () => {
      window.removeEventListener('agro2_fazenda_changed', handleFazendaChange);
      window.removeEventListener('agro2_sync_updated', carregarFazendas);
    };
  }, []);

  const handleSelectFazenda = async (e) => {
    const newId = e.target.value;
    if (newId) {
      await setActiveFazendaId(newId);
      setActiveFazendaIdState(newId);
    }
  };

  return (
    <header className="top-header">
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
        <button
          onClick={onToggleSidebar}
          className="btn btn-secondary btn-sm mobile-menu-btn"
          id="menu-toggle-btn"
        >
          <Menu size={22} />
        </button>

        <div className="header-title-section">
          <h2>{pageTitle || 'Painel Principal'}</h2>
        </div>
      </div>

      <div className="header-actions">
        {/* Seletor de Fazenda Ativa */}
        {fazendas.length > 0 && (
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '6px',
              background: 'var(--bg-input, #f1f5f9)',
              padding: '4px 8px',
              borderRadius: 'var(--radius-md, 8px)',
              border: '1px solid var(--border, #cbd5e1)'
            }}
          >
            <Home size={14} style={{ color: 'var(--primary, #15803d)' }} />
            <select
              value={activeFazendaIdState}
              onChange={handleSelectFazenda}
              style={{
                background: 'transparent',
                border: 'none',
                fontSize: '13px',
                fontWeight: 600,
                color: 'var(--text-main, #0f172a)',
                cursor: 'pointer',
                outline: 'none',
                maxWidth: '160px'
              }}
              title="Fazenda Ativa Atual"
            >
              {fazendas.map((f) => (
                <option key={f.id} value={f.id}>
                  {f.nome}
                </option>
              ))}
            </select>
          </div>
        )}

        {/* Status de Conexão */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
            padding: '5px 10px',
            borderRadius: 'var(--radius-full)',
            background: isOnline ? '#dcfce7' : '#fee2e2',
            color: isOnline ? '#15803d' : '#b91c1c',
            fontSize: '12px',
            fontWeight: 600
          }}
          title={isOnline ? 'Online — Conectado' : 'Offline — Modo Campo 100% Ativo'}
        >
          {isOnline ? <Wifi size={14} /> : <WifiOff size={14} />}
          <span>{isOnline ? 'Online' : 'Offline'}</span>
        </div>

        {/* Botão de Sync */}
        <button
          onClick={syncNow}
          disabled={isSyncing}
          className="btn btn-secondary btn-sm"
          title={pendingCount > 0 ? `${pendingCount} alterações pendentes de sincronização` : 'Sincronizar dados'}
          style={{ position: 'relative' }}
        >
          <RefreshCw size={14} className={isSyncing ? 'animate-spin' : ''} />
          <span style={{ display: 'none' }} className="desktop-sync-text">Sync</span>
          {pendingCount > 0 && (
            <span
              style={{
                position: 'absolute',
                top: '-4px',
                right: '-4px',
                background: '#ea580c',
                color: 'white',
                fontSize: '10px',
                width: '18px',
                height: '18px',
                borderRadius: '50%',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 700
              }}
            >
              {pendingCount}
            </span>
          )}
        </button>


        {/* Informações do Usuário & Logout */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', borderLeft: '1px solid var(--border)', paddingLeft: '12px' }}>
          <div style={{ textAlign: 'right', display: 'none' }} className="user-profile-info">
            <div style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-main)' }}>{user?.nome?.split(' ')[0]}</div>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'capitalize' }}>{user?.perfil}</div>
          </div>

          <button
            onClick={logout}
            className="btn btn-secondary btn-sm"
            style={{ padding: '8px', color: 'var(--text-muted)' }}
            title="Sair da Conta"
          >
            <LogOut size={16} />
          </button>
        </div>
      </div>
    </header>
  );
}
