import React, { useState, useEffect } from 'react';
import { WifiOff, ShieldAlert, Utensils, Touchpad, CheckCircle2, ArrowRight, X } from 'lucide-react';

const SLIDES = [
  {
    icon: WifiOff,
    color: '#10b981',
    bgColor: 'rgba(16, 185, 129, 0.15)',
    title: 'Operação 100% Offline',
    description: 'Trabalhe no campo sem preocupação com sinal de internet. Todos os seus dados ficam salvos com segurança no aparelho.',
    badge: 'Sincronização automática assim que reconectar',
  },
  {
    icon: ShieldAlert,
    color: '#ef4444',
    bgColor: 'rgba(239, 68, 68, 0.15)',
    title: 'Selo de Carência Sanitária',
    description: 'Ao aplicar medicamentos ou vacinas, o aplicativo calcula automaticamente a retenção e avisa se o animal está liberado para abate/leite.',
    badge: 'Alerta vermelho automático no cadastro do animal',
  },
  {
    icon: Utensils,
    color: '#f59e0b',
    bgColor: 'rgba(245, 158, 11, 0.15)',
    title: 'Nutrição & Baixa Automática',
    description: 'Informe o trato diário do lote e o saldo dos insumos no estoque é baixado na hora sem digitação dupla.',
    badge: 'Controle de estoque simples e sem complicação',
  },
  {
    icon: Touchpad,
    color: '#3b82f6',
    bgColor: 'rgba(59, 130, 246, 0.15)',
    title: 'Feito para o Trabalho de Campo',
    description: 'Botões amplos, seletores intuitivos e telas limpas projetadas para facilitar a vida da equipe na fazenda.',
    badge: 'Poucos toques para registrar qualquer operação',
  },
];

export default function OnboardingModal() {
  const [isOpen, setIsOpen] = useState(false);
  const [currentSlide, setCurrentSlide] = useState(0);

  useEffect(() => {
    const seen = localStorage.getItem('agro_onboarding_completed');
    if (!seen) {
      setIsOpen(true);
    }
  }, []);

  if (!isOpen) return null;

  const handleClose = () => {
    localStorage.setItem('agro_onboarding_completed', 'true');
    setIsOpen(false);
  };

  const handleNext = () => {
    if (currentSlide < SLIDES.length - 1) {
      setCurrentSlide((prev) => prev + 1);
    } else {
      handleClose();
    }
  };

  const slide = SLIDES[currentSlide];
  const IconComponent = slide.icon;
  const isLast = currentSlide === SLIDES.length - 1;

  return (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      backgroundColor: 'rgba(15, 23, 42, 0.85)',
      backdropFilter: 'blur(4px)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 9999,
      padding: '16px',
    }}>
      <div style={{
        backgroundColor: '#1e293b',
        borderRadius: '24px',
        border: '1px solid rgba(255, 255, 255, 0.1)',
        maxWidth: '480px',
        width: '100%',
        padding: '32px 24px 24px 24px',
        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)',
        position: 'relative',
        color: '#f8fafc',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        textAlign: 'center',
      }}>
        {/* Botão Fechar no topo */}
        <button
          onClick={handleClose}
          style={{
            position: 'absolute',
            top: '16px',
            right: '16px',
            background: 'none',
            border: 'none',
            color: '#94a3b8',
            cursor: 'pointer',
            padding: '8px',
            borderRadius: '50%',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
          title="Pular guia"
        >
          <X size={20} />
        </button>

        {/* Ícone Gigante */}
        <div style={{
          width: '100px',
          height: '100px',
          borderRadius: '50%',
          backgroundColor: slide.bgColor,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          marginBottom: '24px',
        }}>
          <IconComponent size={48} color={slide.color} />
        </div>

        {/* Título */}
        <h2 style={{
          fontSize: '22px',
          fontWeight: 700,
          marginBottom: '12px',
          color: '#ffffff',
        }}>
          {slide.title}
        </h2>

        {/* Descrição */}
        <p style={{
          fontSize: '15px',
          color: '#cbd5e1',
          lineHeight: '1.5',
          marginBottom: '20px',
        }}>
          {slide.description}
        </p>

        {/* Destaque / Badge */}
        <div style={{
          backgroundColor: 'rgba(16, 185, 129, 0.1)',
          border: '1px solid rgba(16, 185, 129, 0.3)',
          borderRadius: '12px',
          padding: '10px 14px',
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          fontSize: '13px',
          color: '#34d399',
          fontWeight: 600,
          marginBottom: '28px',
        }}>
          <CheckCircle2 size={16} color="#34d399" />
          <span>{slide.badge}</span>
        </div>

        {/* Indicadores de Slide (Dots) */}
        <div style={{ display: 'flex', gap: '8px', marginBottom: '24px' }}>
          {SLIDES.map((_, idx) => (
            <div
              key={idx}
              onClick={() => setCurrentSlide(idx)}
              style={{
                height: '8px',
                width: idx === currentSlide ? '24px' : '8px',
                borderRadius: '4px',
                backgroundColor: idx === currentSlide ? '#10b981' : '#475569',
                cursor: 'pointer',
                transition: 'all 0.3s ease',
              }}
            />
          ))}
        </div>

        {/* Botão Ação Grande */}
        <button
          onClick={handleNext}
          style={{
            width: '100%',
            height: '52px',
            backgroundColor: '#10b981',
            color: '#ffffff',
            border: 'none',
            borderRadius: '14px',
            fontSize: '16px',
            fontWeight: 700,
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
            boxShadow: '0 4px 14px rgba(16, 185, 129, 0.4)',
            transition: 'background-color 0.2s',
          }}
        >
          <span>{isLast ? 'Começar a Usar' : 'Próximo'}</span>
          <ArrowRight size={20} />
        </button>
      </div>
    </div>
  );
}
