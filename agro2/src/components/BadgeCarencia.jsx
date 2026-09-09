import React from 'react';
import { AlertTriangle, CheckCircle2, Syringe } from 'lucide-react';
import { statusCarencia } from '../utils/carenciaHelper.js';

export default function BadgeCarencia({ carenciaFim, produtoNome }) {
  const info = statusCarencia(carenciaFim);

  if (info.emCarencia) {
    return (
      <span
        className="badge badge-carencia"
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: '5px',
          fontWeight: 700,
          padding: '6px 12px',
          fontSize: '12px'
        }}
        title={`Aplicação: ${produtoNome || 'Medicamento/Vacina'} — Carência até ${info.dataFim}`}
      >
        <Syringe size={13} strokeWidth={2.5} />
        <span>
          {produtoNome ? `${produtoNome} • ${info.diasRestantes}d carência` : `Vacina Aplicada (${info.diasRestantes}d carência)`}
        </span>
      </span>
    );
  }

  return (
    <span className="badge badge-liberado" style={{ display: 'inline-flex', alignItems: 'center', gap: '5px', fontWeight: 600 }}>
      <CheckCircle2 size={13} strokeWidth={2.5} />
      <span>{produtoNome ? `${produtoNome} (Liberado)` : 'Liberado'}</span>
    </span>
  );
}
