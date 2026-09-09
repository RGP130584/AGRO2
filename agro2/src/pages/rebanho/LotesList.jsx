import React, { useState, useEffect } from 'react';
import { Layers, Plus, ArrowLeft, MapPin, Users, Edit, Tag } from 'lucide-react';
import { db } from '../../db/database.js';

export default function LotesList({ onVoltar, onNovoLote, onEditarLote }) {
  const [lotes, setLotes] = useState([]);
  const [piquetes, setPiquetes] = useState([]);
  const [especieFiltro, setEspecieFiltro] = useState('Todos');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    carregarLotes();
  }, []);

  async function carregarLotes() {
    try {
      const [listLotes, listPiquetes] = await Promise.all([
        db.lotes.toArray(),
        db.piquetes.toArray()
      ]);

      const lotesComContagem = await Promise.all(
        listLotes.map(async (l) => {
          const count = await db.animais.where('lote_id').equals(l.id).count();
          return { ...l, quantidade: count };
        })
      );

      setLotes(lotesComContagem);
      setPiquetes(listPiquetes);
    } catch (err) {
      console.error('Erro ao carregar lotes:', err);
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

  const getNomePiquete = (piqueteId) => {
    const p = piquetes.find((item) => item.id === piqueteId);
    return p ? `${p.nome} (${p.area_ha} ha)` : 'Sem Piquete Definido';
  };

  const lotesFiltrados = lotes.filter(
    (l) => especieFiltro === 'Todos' || !l.especie || l.especie === especieFiltro
  );

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '10px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <button onClick={onVoltar} className="btn btn-secondary btn-sm">
            <ArrowLeft size={16} />
          </button>
          <div>
            <h2 style={{ fontSize: '20px' }}>Gestão de Lotes por Espécie</h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
              Separação exclusiva de lotes para Bovinos, Ovinos, Equinos, Búfalos e Caprinos
            </p>
          </div>
        </div>

        <button
          onClick={() => onNovoLote(especieFiltro !== 'Todos' ? especieFiltro : 'Bovino')}
          className="btn btn-primary btn-sm"
        >
          <Plus size={15} />
          <span>Novo Lote</span>
        </button>
      </div>

      {/* Abas de Seleção de Espécie */}
      <div style={{ marginBottom: '16px', overflowX: 'auto', WebkitOverflowScrolling: 'touch', paddingBottom: '4px' }}>
        <div style={{ display: 'flex', gap: '6px', minWidth: 'max-content' }}>
          {ESPECIES_OPCOES.map((esp) => (
            <button
              key={esp.id}
              onClick={() => setEspecieFiltro(esp.id)}
              className={`btn ${especieFiltro === esp.id ? 'btn-primary' : 'btn-secondary'} btn-sm`}
              style={{
                borderRadius: '20px',
                padding: '6px 14px',
                fontSize: '13px',
                fontWeight: 700
              }}
            >
              {esp.label}
            </button>
          ))}
        </div>
      </div>

      {/* Lista de Lotes em Grid Responsivo */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Carregando lotes...</div>
      ) : lotesFiltrados.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '40px 20px', color: 'var(--text-muted)' }}>
          <Tag size={36} style={{ margin: '0 auto 10px auto', color: '#cbd5e1' }} />
          <h4 style={{ fontSize: '15px', color: 'var(--text-main)', marginBottom: '4px' }}>
            Nenhum lote cadastrado {especieFiltro !== 'Todos' ? `para ${especieFiltro}s` : ''}
          </h4>
          <p style={{ fontSize: '13px' }}>Clique em "Novo Lote" para cadastrar um lote exclusivo para esta espécie.</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '14px', maxWidth: '100%', minWidth: 0 }}>
          {lotesFiltrados.map((lote) => (
            <div key={lote.id} className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
              <div className="card-header" style={{ marginBottom: '10px' }}>
                <h4 style={{ fontSize: '15px', fontWeight: 700, wordBreak: 'break-word' }}>{lote.nome}</h4>
                <span className="badge badge-info" style={{ flexShrink: 0 }}>{lote.quantidade} cab.</span>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', fontSize: '13px', color: 'var(--text-muted)' }}>
                <div>
                  <strong>Espécie Exclusiva:</strong> <span className="badge badge-warning" style={{ fontSize: '11px' }}>{lote.especie || 'Bovino'}</span>
                </div>
                <div>
                  <strong>Categoria:</strong> {lote.categoria}
                </div>
                <div>
                  <strong>Finalidade:</strong> {lote.finalidade}
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#15803d', marginTop: '2px' }}>
                  <MapPin size={14} />
                  <span>{getNomePiquete(lote.piquete_id)}</span>
                </div>
              </div>

              <div style={{ marginTop: '14px', paddingTop: '10px', borderTop: '1px solid var(--border)', display: 'flex', justifyContent: 'flex-end' }}>
                <button onClick={() => onEditarLote(lote.id)} className="btn btn-secondary btn-sm">
                  <Edit size={14} />
                  <span>Editar Lote</span>
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

