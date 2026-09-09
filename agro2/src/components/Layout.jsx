import React, { useState, useEffect } from 'react';
import {
  LayoutDashboard,
  Layers,
  HeartPulse,
  Wheat,
  Scale,
  Package,
  DollarSign,
  FileText,
  Users,
  RefreshCw,
  X
} from 'lucide-react';
import Header from './Header.jsx';
import { useAuth } from '../contexts/AuthContext.jsx';
import { canAccessModule } from '../utils/permissionHelper.js';

export default function Layout({ activePage, setActivePage, children }) {
  const { user } = useAuth();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [, setPermsVersion] = useState(0);

  useEffect(() => {
    const handlePermUpdate = () => setPermsVersion((v) => v + 1);
    window.addEventListener('agro2_permissions_updated', handlePermUpdate);
    return () => window.removeEventListener('agro2_permissions_updated', handlePermUpdate);
  }, []);

  const navItems = [
    { id: 'dashboard', label: 'Painel Geral', icon: LayoutDashboard },
    { id: 'rebanho', label: 'Rebanho & Lotes', icon: Layers },
    { id: 'saude', label: 'Saúde Animal', icon: HeartPulse, highlight: true },
    { id: 'nutricao', label: 'Nutrição & Dietas', icon: Wheat },
    { id: 'pesagem', label: 'Pesagens & GMD', icon: Scale },
    { id: 'estoque', label: 'Estoque & Insumos', icon: Package },
    { id: 'financeiro', label: 'Financeiro', icon: DollarSign },
    { id: 'relatorios', label: 'Relatórios & GTA', icon: FileText },
    { id: 'equipe', label: 'Equipe & Veterinários', icon: Users },
    { id: 'sync', label: 'Sincronização', icon: RefreshCw }
  ];

  const userPerfil = user?.perfil || 'proprietario';
  const visibleNavItems = navItems.filter((item) => canAccessModule(userPerfil, item.id));

  const handleNavClick = (pageId) => {
    setActivePage(pageId);
    setSidebarOpen(false);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const currentPageTitle = navItems.find((n) => n.id === activePage)?.label || 'Agro 2';

  return (
    <div className="app-layout">
      {/* Sidebar Desktop & Mobile Drawer */}
      <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
        <div className="sidebar-brand">
          <div className="brand-icon">
            <Layers size={22} strokeWidth={2.5} />
          </div>
          <div style={{ flex: 1 }}>
            <div className="brand-title">AGRO 2</div>
            <div className="brand-subtitle">Gestão Pecuária</div>
          </div>
          {sidebarOpen && (
            <button
              onClick={() => setSidebarOpen(false)}
              className="btn btn-secondary btn-sm"
              style={{ background: 'transparent', color: '#94a3b8', border: 'none', padding: '4px' }}
            >
              <X size={20} />
            </button>
          )}
        </div>

        <nav className="sidebar-nav">
          {visibleNavItems.map((item) => {
            const Icon = item.icon;
            const isActive = activePage === item.id;
            return (
              <button
                key={item.id}
                onClick={() => handleNavClick(item.id)}
                className={`nav-item ${isActive ? 'active' : ''}`}
                id={`nav-${item.id}`}
              >
                <Icon size={18} strokeWidth={isActive ? 2.5 : 2} />
                <span>{item.label}</span>
              </button>
            );
          })}
        </nav>

        <div className="sidebar-footer">
          <div style={{ background: '#1e293b', padding: '10px 12px', borderRadius: '8px', fontSize: '11px', color: '#94a3b8' }}>
            <div style={{ color: '#22c55e', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '6px' }}>
              <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#22c55e' }}></span>
              100% Offline-First
            </div>
            <div style={{ marginTop: '4px' }}>Dados seguros no seu dispositivo</div>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <div className="main-wrapper">
        <Header pageTitle={currentPageTitle} onToggleSidebar={() => setSidebarOpen(!sidebarOpen)} />
        <main className="page-content">{children}</main>
      </div>

      {/* Mobile Bottom Navigation */}
      <nav className="mobile-bottom-nav">
        <button
          onClick={() => handleNavClick('dashboard')}
          className={`mobile-nav-btn ${activePage === 'dashboard' ? 'active' : ''}`}
        >
          <LayoutDashboard size={20} />
          <span>Início</span>
        </button>
        <button
          onClick={() => handleNavClick('rebanho')}
          className={`mobile-nav-btn ${activePage === 'rebanho' ? 'active' : ''}`}
        >
          <Layers size={20} />
          <span>Rebanho</span>
        </button>
        <button
          onClick={() => handleNavClick('saude')}
          className={`mobile-nav-btn ${activePage === 'saude' ? 'active' : ''}`}
        >
          <HeartPulse size={20} />
          <span>Saúde</span>
        </button>
        <button
          onClick={() => handleNavClick('pesagem')}
          className={`mobile-nav-btn ${activePage === 'pesagem' ? 'active' : ''}`}
        >
          <Scale size={20} />
          <span>Pesagem</span>
        </button>
        <button
          onClick={() => setSidebarOpen(true)}
          className="mobile-nav-btn"
        >
          <Users size={20} />
          <span>Menu</span>
        </button>
      </nav>
    </div>
  );
}
