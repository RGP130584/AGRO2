import React, { useState, useEffect } from 'react';
import { Search, Plus, Filter, Eye, Scale, HeartPulse, Layers, Tag } from 'lucide-react';
import { db } from '../../db/database.js';
import BadgeCarencia from '../../components/BadgeCarencia.jsx';
import { formatarNumero } from '../../utils/formatters.js';

export default function RebanhoList({ onNovoAnimal, onVerDetalhe, onVerLotes }) {
  const [animais, setAnimais] = useState([]);
  const [lotes, setLotes] = useState([]);
  const [busca, setBusca] = useState('');
  const [especieFiltro, setEspecieFiltro] = useState('Todos');
  const [loteFiltro, setLoteFiltro] = useState('');
  const [carenciaFiltro, setCarenciaFiltro] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    carregarDados();
    const handleSyncUpdate = () => carregarDados();
    window.addEventListener('agro2_sync_updated', handleSyncUpdate);
    return () => window.removeEventListener('agro2_sync_updated', handleSyncUpdate);
  }, []);

  async function carregarDados() {
    try {
      const [listAnimais, listLotes] = await Promise.all([
        db.animais.filter((a) => !a.status || a.status === 'ativo').toArray(),
        db.lotes.toArray()
      ]);
      setAnimais(listAnimais);
      setLotes(listLotes);
    } catch (err) {
      console.error('Erro ao carregar animais:', err);
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

  const animaisFiltrados = animais.filter((animal) => {
    const termo = busca.toLowerCase();
    const matchesBusca =
      (animal.brinco && animal.brinco.toLowerCase().includes(termo)) ||
      (animal.rfid && animal.rfid.toLowerCase().includes(termo)) ||
      (animal.raca && animal.raca.toLowerCase().includes(termo));

    const matchesEspecie = especieFiltro === 'Todos' || (animal.especie || 'Bovino') === especieFiltro;
    const matchesLote = !loteFiltro || animal.lote_id === loteFiltro;

    const hojeStr = new Date().toISOString().split('T')[0];
    const emCarencia = animal.carencia_fim && animal.carencia_fim >= hojeStr;
    const matchesCarencia = !carenciaFiltro || emCarencia;

    return matchesBusca && matchesEspecie && matchesLote && matchesCarencia;
  });

  const lotesFiltradosPorEspecie = lotes.filter(
    (l) => especieFiltro === 'Todos' || !l.especie || l.especie === especieFiltro
  );

  const getNomeLote = (loteId) => {
    const l = lotes.find((item) => item.id === loteId);
    return l ? l.nome : 'Sem Lote';
  };

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      {/* Top Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '10px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Rebanho Multiespécie</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Controle individual por brinco, espécie e isolamento de lotes
          </p>
        </div>

        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', maxWidth: '100%' }}>
          <button onClick={onVerLotes} className="btn btn-secondary btn-sm">
            <Layers size={15} />
            <span>Gerenciar Lotes</span>
          </button>

          <button onClick={onNovoAnimal} className="btn btn-primary btn-sm">
            <Plus size={15} />
            <span>Novo Animal</span>
          </button>
        </div>
      </div>

      {/* Abas de Seleção de Espécie (Isolamento de Acervo) */}
      <div style={{ marginBottom: '16px', overflowX: 'auto', WebkitOverflowScrolling: 'touch', paddingBottom: '4px' }}>
        <div style={{ display: 'flex', gap: '6px', minWidth: 'max-content' }}>
          {ESPECIES_OPCOES.map((esp) => (
            <button
              key={esp.id}
              onClick={() => {
                setEspecieFiltro(esp.id);
                setLoteFiltro('');
              }}
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

      {/* Barra de Filtros e Busca */}
      <div className="card" style={{ marginBottom: '16px', padding: '14px', maxWidth: '100%', minWidth: 0 }}>
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap', alignItems: 'center' }}>
          <div style={{ position: 'relative', flex: '1 1 200px', minWidth: 0 }}>
            <Search size={16} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: '#94a3b8' }} />
            <input
              type="text"
              className="form-input"
              style={{ paddingLeft: '36px', height: '42px', fontSize: '14px' }}
              placeholder="Buscar brinco, RFID ou raça..."
              value={busca}
              onChange={(e) => setBusca(e.target.value)}
            />
          </div>

          <select
            className="form-select"
            style={{ flex: '1 1 160px', height: '42px', fontSize: '14px', minWidth: 0 }}
            value={loteFiltro}
            onChange={(e) => setLoteFiltro(e.target.value)}
          >
            <option value="">{especieFiltro === 'Todos' ? 'Todos os Lotes' : `Lotes de ${especieFiltro}`}</option>
            {lotesFiltradosPorEspecie.map((l) => (
              <option key={l.id} value={l.id}>{l.nome}</option>
            ))}
          </select>

          <button
            onClick={() => setCarenciaFiltro(!carenciaFiltro)}
            className={`btn ${carenciaFiltro ? 'btn-danger' : 'btn-secondary'} btn-sm`}
            style={{ height: '42px', padding: '0 12px' }}
          >
            <HeartPulse size={15} />
            <span>{carenciaFiltro ? '⚠️ Em Carência' : 'Carência'}</span>
          </button>
        </div>
      </div>

      {/* Lista de Animais em Tabela Responsiva */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px' }}>Carregando rebanho...</div>
      ) : animaisFiltrados.length === 0 ? (
        <div className="card" style={{ textAlign: 'center', padding: '40px 20px', color: 'var(--text-muted)' }}>
          <Tag size={36} style={{ margin: '0 auto 10px auto', color: '#cbd5e1' }} />
          <h4 style={{ fontSize: '15px', color: 'var(--text-main)', marginBottom: '4px' }}>
            Nenhum animal encontrado {especieFiltro !== 'Todos' ? `em ${especieFiltro}s` : ''}
          </h4>
          <p style={{ fontSize: '13px' }}>Tente selecionar outra espécie ou ajustar os filtros de busca.</p>
        </div>
      ) : (
        <div className="table-container" style={{ width: '100%', maxWidth: '100%', overflowX: 'auto', WebkitOverflowScrolling: 'touch' }}>
          <table className="data-table">
            <thead>
              <tr>
                <th>Brinco / RFID</th>
                <th>Espécie / Raça</th>
                <th>Lote Exclusivo</th>
                <th>Peso Actual</th>
                <th>GMD</th>
                <th>Carência</th>
                <th style={{ textAlign: 'right' }}>Ações</th>
              </tr>
            </thead>
            <tbody>
              {animaisFiltrados.map((animal) => (
                <tr key={animal.id}>
                  <td>
                    <div style={{ fontWeight: 700, fontSize: '14px', color: 'var(--text-main)' }}>
                      {animal.brinco}
                    </div>
                    {animal.rfid && (
                      <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                        {animal.rfid}
                      </div>
                    )}
                  </td>
                  <td>
                    <div style={{ fontWeight: 600, fontSize: '13px' }}>
                      {animal.especie ? `${animal.especie} • ` : ''}{animal.raca}
                    </div>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                      {animal.categoria} • {animal.sexo}
                    </div>
                  </td>
                  <td>
                    <span className="badge badge-info">{getNomeLote(animal.lote_id)}</span>
                  </td>
                  <td>
                    <div style={{ fontWeight: 700 }}>
                      {animal.peso_atual ? `${animal.peso_atual} kg` : '-'}
                    </div>
                    {animal.peso_atual && (
                      <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                        ≈ {(animal.peso_atual / 30).toFixed(1)} @
                      </div>
                    )}
                  </td>
                  <td>
                    {animal.gmd_recente > 0 ? (
                      <span style={{ fontWeight: 700, color: '#16a34a', fontSize: '13px' }}>
                        +{formatarNumero(animal.gmd_recente, 2)} kg/d
                      </span>
                    ) : (
                      <span style={{ color: 'var(--text-muted)', fontSize: '12px' }}>-</span>
                    )}
                  </td>
                  <td>
                    <BadgeCarencia carenciaFim={animal.carencia_fim} produtoNome={animal.ultima_aplicacao_nome} />
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    <button
                      onClick={() => onVerDetalhe(animal.id)}
                      className="btn btn-secondary btn-sm"
                      title="Ver Ficha Completa"
                    >
                      <Eye size={14} />
                      <span>Ficha</span>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

