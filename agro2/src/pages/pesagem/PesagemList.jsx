import React, { useState, useEffect } from 'react';
import { Scale, Plus, TrendingUp, Calendar, ArrowRight, User, Tag } from 'lucide-react';
import { db } from '../../db/database.js';
import { formatarData, formatarNumero } from '../../utils/formatters.js';

export default function PesagemList({ onNovaPesagem, onVerAnimal }) {
  const [pesagens, setPesagens] = useState([]);
  const [animais, setAnimais] = useState([]);
  const [especieFiltro, setEspecieFiltro] = useState('Todos');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    carregarPesagens();
    const handleSyncUpdate = () => carregarPesagens();
    window.addEventListener('agro2_sync_updated', handleSyncUpdate);
    return () => window.removeEventListener('agro2_sync_updated', handleSyncUpdate);
  }, []);

  async function carregarPesagens() {
    try {
      const [listPesagens, listAnimais] = await Promise.all([
        db.pesagens.reverse().limit(50).toArray(),
        db.animais.toArray()
      ]);
      setPesagens(listPesagens);
      setAnimais(listAnimais);
    } catch (err) {
      console.error('Erro ao carregar pesagens:', err);
    } finally {
      setLoading(false);
    }
  }

  const ESPECIES_OPCOES = [
    { id: 'Todos', label: '🌐 Todos' },
    { id: 'Bovino', label: '🐄 Bovinos' },
    { id: 'Ovino', label: '🐑 Ovinos' },
    { id: 'Equino', label: '🐴 Equinos' },
    { id: 'Búfalo', label: '🦬 Búfalos' },
    { id: 'Caprino', label: '🐐 Caprinos' },
    { id: 'Outro', label: '📦 Outros' }
  ];

  const getAnimalInfo = (animalId) => {
    const a = animais.find((item) => item.id === animalId);
    if (!a) return { nome: 'Animal Excluído', especie: '' };
    return {
      brinco: a.brinco,
      especie: a.especie || 'Bovino',
      raca: a.raca,
      categoria: a.categoria
    };
  };

  // Manter apenas a última pesagem de cada animal (deduplicação por animal_id)
  const pesagensUnicas = [];
  const animaisVistos = new Set();

  for (const p of pesagens) {
    if (!p.animal_id || animaisVistos.has(p.animal_id)) continue;
    animaisVistos.add(p.animal_id);
    pesagensUnicas.push(p);
  }

  const pesagensFiltradas = pesagensUnicas.filter((p) => {
    if (especieFiltro === 'Todos') return true;
    const a = animais.find((item) => item.id === p.animal_id);
    return (a?.especie || 'Bovino') === especieFiltro;
  });

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '10px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Pesagens & Desempenho (GMD)</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Evolução de peso por espécie e Ganho Médio Diário (kg/dia e @)
          </p>
        </div>
      </div>

      {/* Abas de Seleção de Espécie (Com Quebra Automática no Celular) */}
      <div style={{ marginBottom: '16px', maxWidth: '100%', minWidth: 0 }}>
        <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap', maxWidth: '100%' }}>
          {ESPECIES_OPCOES.map((esp) => (
            <button
              key={esp.id}
              onClick={() => setEspecieFiltro(esp.id)}
              className={`btn ${especieFiltro === esp.id ? 'btn-primary' : 'btn-secondary'} btn-sm`}
              style={{
                borderRadius: '20px',
                padding: '6px 12px',
                fontSize: '12px',
                fontWeight: 700,
                flex: '1 1 auto'
              }}
            >
              {esp.label}
            </button>
          ))}
        </div>
      </div>

      <div className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
        <div className="card-header">
          <h4 className="card-title">
            <Scale size={18} className="text-primary" />
            <span>Última Pesagem por Animal ({especieFiltro})</span>
          </h4>
        </div>

        {loading ? (
          <div style={{ padding: '30px', textAlign: 'center' }}>Carregando pesagens...</div>
        ) : pesagensFiltradas.length === 0 ? (
          <div style={{ padding: '40px 20px', textAlign: 'center', color: 'var(--text-muted)' }}>
            <Tag size={36} style={{ margin: '0 auto 10px auto', color: '#cbd5e1' }} />
            <h4 style={{ fontSize: '15px', color: 'var(--text-main)', marginBottom: '4px' }}>
              Nenhuma pesagem registrada {especieFiltro !== 'Todos' ? `para ${especieFiltro}s` : ''}
            </h4>
            <p style={{ fontSize: '13px' }}>Clique em "Registrar Pesagem" para cadastrar um novo peso.</p>
          </div>
        ) : (
          <div>
            {/* Visão em Cards Compactos Responsivos */}
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {pesagensFiltradas.map((p) => {
                const info = getAnimalInfo(p.animal_id);
                return (
                  <div
                    key={p.id}
                    onClick={() => onVerAnimal && p.animal_id && onVerAnimal(p.animal_id)}
                    style={{
                      padding: '14px',
                      borderRadius: '12px',
                      background: '#f8fafc',
                      border: '1px solid var(--border)',
                      display: 'flex',
                      flexDirection: 'column',
                      gap: '10px',
                      cursor: 'pointer',
                      transition: 'all 0.2s ease',
                      boxShadow: '0 1px 3px rgba(0,0,0,0.05)'
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <span style={{ fontWeight: 800, fontSize: '16px', color: 'var(--primary)' }}>
                          Brinco {info.brinco || 'Animal'}
                        </span>
                        <span className="badge badge-info" style={{ fontSize: '11px', padding: '2px 8px' }}>{info.especie}</span>
                      </div>
                      <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: 600 }}>{formatarData(p.data)}</span>
                    </div>

                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '8px' }}>
                      <div>
                        <span style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
                          {info.raca} {info.categoria ? `• ${info.categoria}` : ''}
                        </span>
                      </div>

                      <div style={{ fontWeight: 800, fontSize: '17px', color: '#15803d' }}>
                        {p.peso} kg <span style={{ fontSize: '12px', fontWeight: 600, color: '#64748b' }}>({(p.peso / 30).toFixed(1)} @)</span>
                      </div>
                    </div>

                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '12px', paddingTop: '8px', borderTop: '1px dashed #e2e8f0', color: 'var(--text-muted)' }}>
                      <div>Peso Anterior: <strong>{p.peso_anterior ? `${p.peso_anterior} kg` : '-'}</strong></div>
                      <div>
                        GMD: {p.gmd > 0 ? (
                          <span style={{ color: '#16a34a', fontWeight: 800 }}>+{formatarNumero(p.gmd, 2)} kg/d</span>
                        ) : '-'}
                      </div>
                      <div style={{ fontSize: '11px' }}>{p.responsavel || '-'}</div>
                    </div>

                    {/* Botões de Ação Direta no Card */}
                    <div style={{ display: 'flex', gap: '8px', paddingTop: '6px', flexWrap: 'wrap' }} onClick={(e) => e.stopPropagation()}>
                      <button
                        onClick={() => onVerAnimal && p.animal_id && onVerAnimal(p.animal_id)}
                        className="btn btn-secondary btn-sm"
                        style={{ flex: '1 1 auto', justifyContent: 'center', fontSize: '12px', padding: '6px 10px' }}
                      >
                        <User size={14} />
                        <span>Abrir Ficha</span>
                      </button>

                      <button
                        onClick={() => onNovaPesagem && p.animal_id && onNovaPesagem(p.animal_id)}
                        className="btn btn-primary btn-sm"
                        style={{ flex: '1 1 auto', justifyContent: 'center', fontSize: '12px', padding: '6px 10px' }}
                      >
                        <Scale size={14} />
                        <span>Nova Pesagem</span>
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}


