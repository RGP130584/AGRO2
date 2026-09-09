import React, { useState, useEffect } from 'react';
import { Wheat, Plus, ArrowRight, CheckCircle2, AlertCircle, Calendar } from 'lucide-react';
import { db } from '../../db/database.js';
import { formatarData, formatarNumero } from '../../utils/formatters.js';

export default function NutricaoList({ onNovaDieta, onNovoFornecimento }) {
  const [dietas, setDietas] = useState([]);
  const [fornecimentos, setFornecimentos] = useState([]);
  const [lotes, setLotes] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    carregarNutricao();
  }, []);

  async function carregarNutricao() {
    try {
      const [listDietas, listFornecimentos, listLotes] = await Promise.all([
        db.dietas.toArray(),
        db.fornecimentos_dieta.reverse().limit(15).toArray(),
        db.lotes.toArray()
      ]);

      setDietas(listDietas);
      setFornecimentos(listFornecimentos);
      setLotes(listLotes);
    } catch (err) {
      console.error('Erro ao carregar nutrição:', err);
    } finally {
      setLoading(false);
    }
  }

  const getNomeLote = (loteId) => {
    const l = lotes.find((item) => item.id === loteId);
    return l ? l.nome : 'Todos os Lotes';
  };

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '10px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Nutrição & Trato Diário</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Dietas formuladas por lote, fornecimento diário e baixa automática
          </p>
        </div>

        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', maxWidth: '100%' }}>
          <button onClick={onNovaDieta} className="btn btn-secondary btn-sm">
            <Plus size={15} />
            <span>Formular Dieta</span>
          </button>

          <button onClick={onNovoFornecimento} className="btn btn-primary btn-sm">
            <Wheat size={15} />
            <span>Lançar Trato</span>
          </button>
        </div>
      </div>

      {/* Grid de Dietas Ativas */}
      <div style={{ marginBottom: '20px', maxWidth: '100%', minWidth: 0 }}>
        <h3 style={{ fontSize: '15px', marginBottom: '10px', display: 'flex', alignItems: 'center', gap: '6px' }}>
          <span>🌾 Dietas Ativas na Propriedade</span>
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '12px', maxWidth: '100%', minWidth: 0 }}>
          {dietas.map((d) => (
            <div key={d.id} className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
              <div className="card-header" style={{ marginBottom: '6px' }}>
                <h4 style={{ fontSize: '15px', fontWeight: 700, wordBreak: 'break-word' }}>{d.nome}</h4>
                <span className="badge badge-liberado" style={{ fontSize: '10px' }}>Ativa</span>
              </div>
              <p style={{ fontSize: '12px', color: 'var(--text-muted)', marginBottom: '12px', wordBreak: 'break-word' }}>{d.descricao}</p>
              
              <div style={{ display: 'flex', justifyContent: 'space-between', background: '#f8fafc', padding: '10px 12px', borderRadius: '10px', fontSize: '12px', flexWrap: 'wrap', gap: '8px' }}>
                <div>
                  <span style={{ color: '#64748b', fontSize: '10px', textTransform: 'uppercase', fontWeight: 600 }}>Lote Alvo</span>
                  <div style={{ fontWeight: 600 }}>{getNomeLote(d.lote_id)}</div>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <span style={{ color: '#64748b', fontSize: '10px', textTransform: 'uppercase', fontWeight: 600 }}>Consumo Diário</span>
                  <div style={{ fontWeight: 700, color: '#15803d' }}>{d.consumo_cabeca_dia_kg} kg/cab/d</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Histórico de Fornecimentos em Cartões Compactos para Celular */}
      <div className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
        <div className="card-header">
          <h4 className="card-title">
            <Calendar size={18} className="text-primary" />
            <span>Últimos Fornecimentos de Ração / Trato</span>
          </h4>
        </div>

        {fornecimentos.length === 0 ? (
          <div style={{ padding: '20px', textAlign: 'center', color: 'var(--text-muted)' }}>
            Nenhum fornecimento registrado recentemente.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {fornecimentos.map((f) => {
              const dif = Math.abs(f.quantidade_fornecida_kg - f.quantidade_planejada_kg);
              const perc = f.quantidade_planejada_kg > 0 ? (dif / f.quantidade_planejada_kg) * 100 : 0;
              const isAlerta = perc > 15;

              return (
                <div
                  key={f.id}
                  style={{
                    padding: '12px 14px',
                    borderRadius: '12px',
                    background: '#f8fafc',
                    border: '1px solid var(--border)',
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '6px'
                  }}
                >
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontWeight: 800, fontSize: '14px', color: 'var(--text-main)' }}>
                      {getNomeLote(f.lote_id)}
                    </span>
                    <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: 600 }}>
                      {formatarData(f.data)}
                    </span>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '13px' }}>
                    <div style={{ color: 'var(--text-muted)' }}>
                      Planejado: <strong>{f.quantidade_planejada_kg} kg</strong>
                    </div>
                    <div style={{ fontWeight: 800, color: '#15803d' }}>
                      Fornecido: {f.quantidade_fornecida_kg} kg
                    </div>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '6px', borderTop: '1px dashed #e2e8f0' }}>
                    {isAlerta ? (
                      <span className="badge badge-warning" style={{ fontSize: '11px' }}>
                        <AlertCircle size={12} />
                        Desvio de {perc.toFixed(0)}%
                      </span>
                    ) : (
                      <span className="badge badge-liberado" style={{ fontSize: '11px' }}>
                        <CheckCircle2 size={12} />
                        Conforme (OK)
                      </span>
                    )}
                    <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                      Resp: {f.responsavel || '-'}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

