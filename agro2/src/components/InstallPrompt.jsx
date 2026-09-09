import React, { useState, useEffect } from 'react';
import { Smartphone, X, Share2, PlusSquare } from 'lucide-react';

export default function InstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] = useState(null);
  const [showIosGuide, setShowIosGuide] = useState(false);
  const [isIos, setIsIos] = useState(false);
  const [isInstalledOrDismissed, setIsInstalledOrDismissed] = useState(true);

  useEffect(() => {
    // 1. Checar se já está rodando como PWA instalado (Standalone) ou se o usuário dispensou o aviso
    const isStandalone = window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true;
    const isDismissed = localStorage.getItem('agro2_pwa_dismissed') === 'true';

    if (isStandalone || isDismissed) {
      setIsInstalledOrDismissed(true);
      return;
    }

    setIsInstalledOrDismissed(false);

    // Checar iOS Safari
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
        localStorage.setItem('agro2_pwa_dismissed', 'true');
        setIsInstalledOrDismissed(true);
      }
    } else if (isIos) {
      setShowIosGuide(true);
    } else {
      alert('Para instalar, abra o menu do seu navegador e escolha "Instalar aplicativo" ou "Adicionar à tela inicial".');
    }
  };

  const handleDismiss = () => {
    localStorage.setItem('agro2_pwa_dismissed', 'true');
    setIsInstalledOrDismissed(true);
  };

  if (isInstalledOrDismissed) return null;

  return (
    <>
      <div
        style={{
          background: 'linear-gradient(135deg, #15803d, #166534)',
          color: 'white',
          borderRadius: 'var(--radius-lg)',
          padding: '12px 16px',
          marginBottom: '20px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          gap: '12px',
          boxShadow: '0 4px 12px rgba(21, 128, 61, 0.25)',
          flexWrap: 'wrap'
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ background: 'rgba(255,255,255,0.2)', padding: '8px', borderRadius: '10px' }}>
            <Smartphone size={20} />
          </div>
          <div>
            <div style={{ fontWeight: 700, fontSize: '14px' }}>Instalar o AGRO 2 no Celular</div>
            <div style={{ fontSize: '12px', opacity: 0.9 }}>Use 100% offline no campo com ícone na tela inicial</div>
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flex: '1 1 auto', justifyContent: 'flex-end' }}>
          <button
            onClick={handleInstallClick}
            className="btn btn-sm"
            style={{ background: '#ffffff', color: '#15803d', fontWeight: 700, border: 'none' }}
          >
            Instalar App
          </button>
          <button
            onClick={handleDismiss}
            style={{ background: 'transparent', border: 'none', color: 'white', padding: '4px', cursor: 'pointer' }}
            title="Não mostrar novamente"
          >
            <X size={18} />
          </button>
        </div>
      </div>

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
