import React, { useState, useEffect } from 'react';
import { Download, Smartphone, X, Share2, PlusSquare } from 'lucide-react';

export default function InstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] = useState(null);
  const [showIosGuide, setShowIosGuide] = useState(false);
  const [isIos, setIsIos] = useState(false);
  const [isInstalled, setIsInstalled] = useState(false);

  useEffect(() => {
    // Check if already installed / standalone
    if (window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true) {
      setIsInstalled(true);
      return;
    }

    // Check iOS Safari
    const userAgent = window.navigator.userAgent.toLowerCase();
    const isIosDevice = /iphone|ipad|ipod/.test(userAgent);
    setIsIos(isIosDevice);

    const handleBeforeInstallPrompt = (e) => {
      e.preventDefault();
      setDeferredPrompt(e);
    };

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt);

    return () => {
      window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt);
    };
  }, []);

  const handleInstallClick = async () => {
    if (deferredPrompt) {
      deferredPrompt.prompt();
      const choiceResult = await deferredPrompt.userChoice;
      if (choiceResult.outcome === 'accepted') {
        setDeferredPrompt(null);
      }
    } else if (isIos) {
      setShowIosGuide(true);
    } else {
      alert('Para instalar, abra o menu do navegador e selecione "Instalar aplicativo" ou "Adicionar à tela inicial".');
    }
  };

  if (isInstalled) return null;

  return (
    <>
      <button
        onClick={handleInstallClick}
        className="btn btn-sm"
        style={{
          background: 'linear-gradient(135deg, #15803d, #166534)',
          color: 'white',
          boxShadow: '0 2px 8px rgba(21, 128, 61, 0.3)'
        }}
        title="Instalar Agro 2 no Celular ou Computador"
      >
        <Smartphone size={15} />
        <span>Instalar App</span>
      </button>

      {showIosGuide && (
        <div className="modal-overlay" onClick={() => setShowIosGuide(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '420px', textAlign: 'center' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h3 style={{ fontSize: '18px' }}>Como instalar no iPhone / iPad</h3>
              <button onClick={() => setShowIosGuide(false)} className="btn btn-secondary btn-sm" style={{ padding: '4px 8px' }}>
                <X size={16} />
              </button>
            </div>

            <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '20px' }}>
              Instale o <strong>Agro 2</strong> como aplicativo nativo para usar 100% offline no campo:
            </p>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '14px', textAlign: 'left', marginBottom: '24px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', background: '#f8fafc', padding: '12px', borderRadius: '10px' }}>
                <div style={{ background: '#e0f2fe', color: '#0284c7', padding: '8px', borderRadius: '8px' }}>
                  <Share2 size={20} />
                </div>
                <div>
                  <div style={{ fontWeight: 600, fontSize: '14px' }}>1. Toque em Compartilhar</div>
                  <div style={{ fontSize: '12px', color: '#64748b' }}>Ícone na barra inferior do Safari</div>
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', background: '#f8fafc', padding: '12px', borderRadius: '10px' }}>
                <div style={{ background: '#dcfce7', color: '#16a34a', padding: '8px', borderRadius: '8px' }}>
                  <PlusSquare size={20} />
                </div>
                <div>
                  <div style={{ fontWeight: 600, fontSize: '14px' }}>2. Adicionar à Tela de Início</div>
                  <div style={{ fontSize: '12px', color: '#64748b' }}>Role para baixo e selecione a opção</div>
                </div>
              </div>
            </div>

            <button onClick={() => setShowIosGuide(false)} className="btn btn-primary btn-block">
              Entendi
            </button>
          </div>
        </div>
      )}
    </>
  );
}
