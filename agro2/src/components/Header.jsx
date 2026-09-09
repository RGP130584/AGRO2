import React from 'react';
import { Wifi, WifiOff, RefreshCw, LogOut, ShieldCheck, User, Menu } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext.jsx';
import { useSync } from '../contexts/SyncContext.jsx';
import InstallPrompt from './InstallPrompt.jsx';

export default function Header({ pageTitle, onToggleSidebar }) {
  const { user, logout } = useAuth();
  const { isOnline, pendingCount, isSyncing, syncNow } = useSync();

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
