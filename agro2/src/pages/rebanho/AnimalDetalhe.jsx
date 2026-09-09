import React, { useState, useEffect } from 'react';
import { ArrowLeft, Edit, Scale, HeartPulse, History, Calendar, CheckCircle2, AlertTriangle, ShieldAlert, Trash2 } from 'lucide-react';
import { db } from '../../db/database.js';
import BadgeCarencia from '../../components/BadgeCarencia.jsx';
import { formatarData, formatarNumero } from '../../utils/formatters.js';

export default function AnimalDetalhe({ animalId, onVoltar, onEditar, onRegistrarPesagem, onRegistrarAplicacao }) {
  const [animal, setAnimal] = useState(null);
  const [lote, setLote] = useState(null);
  const [pesagens, setPesagens] = useState([]);
  const [aplicacoes, setAplicacoes] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function carregarFicha() {
      try {
        const found = await db.animais.get(animalId);
        if (!found) return;

        setAnimal(found);

        if (found.lote_id) {
          const l = await db.lotes.get(found.lote_id);
          setLote(l);
        }

        const [listPesagens, listAplicacoes] = await Promise.all([
          db.pesagens.where('animal_id').equals(animalId).reverse().sortBy('data'),
          db.aplicacoes_sanitarias.where('animal_id').equals(animalId).reverse().sortBy('data_aplicacao')
        ]);

        setPesagens(listPesagens);
        setAplicacoes(listAplicacoes);
      } catch (err) {
        console.error('Erro ao carregar detalhes do animal:', err);
      } finally {
        setLoading(false);
      }
    }
    carregarFicha();
  }, [animalId]);

  if (loading || !animal) {
    return <div style={{ padding: '40px', textAlign: 'center' }}>Carregando ficha do animal...</div>;
  }

  const hojeStr = new Date().toISOString().split('T')[0];
  const emCarencia = animal.carencia_fim && animal.carencia_fim >= hojeStr;

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      {/* Header com Voltar e Ações */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '10px' }}>
        <button onClick={onVoltar} className="btn btn-secondary btn-sm">
          <ArrowLeft size={16} />
          <span>Voltar ao Rebanho</span>
        </button>

        <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap', maxWidth: '100%' }}>
          <button onClick={() => onRegistrarPesagem(animal.id)} className="btn btn-secondary btn-sm">
            <Scale size={14} />
            <span>Nova Pesagem</span>
          </button>

          {emCarencia ? (
            <button
              disabled
              className="btn btn-secondary btn-sm"
              style={{ opacity: 0.6, cursor: 'not-allowed', color: '#dc2626', borderColor: '#fca5a5', backgroundColor: '#fef2f2' }}
              title={`Aplicação Bloqueada: Carência sanitária ativa até ${formatarData(animal.carencia_fim)}`}
            >
              <ShieldAlert size={14} color="#dc2626" />
              <span>Em Carência</span>
            </button>
          ) : (
            <button onClick={() => onRegistrarAplicacao(animal.id)} className="btn btn-secondary btn-sm">
              <HeartPulse size={14} color="#dc2626" />
              <span>Vacina / Remédio</span>
            </button>
          )}

          <button onClick={() => onEditar(animal.id)} className="btn btn-primary btn-sm">
            <Edit size={14} />
            <span>Editar</span>
          </button>
        </div>
      </div>

      {/* Card Principal da Ficha */}
      <div className="card" style={{ marginBottom: '20px', maxWidth: '100%', minWidth: 0 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '16px' }}>
          
          {/* Foto + Dados Primários */}
          <div style={{ display: 'flex', gap: '14px', alignItems: 'center', flexWrap: 'wrap', flex: '1 1 240px', minWidth: 0 }}>
            {animal.foto ? (
              <img
                src={animal.foto}
                alt={animal.brinco}
                style={{ width: '72px', height: '72px', borderRadius: '14px', objectFit: 'cover', border: '2px solid var(--border)', flexShrink: 0 }}
              />
            ) : (
              <div
                style={{
                  width: '72px',
                  height: '72px',
                  borderRadius: '14px',
                  background: 'linear-gradient(135deg, #15803d, #166534)',
                  color: 'white',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '20px',
                  fontWeight: 800,
                  flexShrink: 0
                }}
              >
                {animal.brinco.substring(0, 4)}
              </div>
            )}

            <div style={{ flex: '1 1 180px', minWidth: 0 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flexWrap: 'wrap', maxWidth: '100%' }}>
                <h2 style={{ fontSize: '20px', fontWeight: 800, wordBreak: 'break-word' }}>Brinco: {animal.brinco}</h2>
                <BadgeCarencia carenciaFim={animal.carencia_fim} produtoNome={animal.ultima_aplicacao_nome} />
              </div>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)', marginTop: '4px', wordBreak: 'break-word' }}>
                {animal.especie ? `${animal.especie} • ` : ''}{animal.raca} • {animal.categoria} • {animal.sexo}
              </div>
              {animal.rfid && (
                <div style={{ fontSize: '12px', color: '#64748b', marginTop: '4px', wordBreak: 'break-all' }}>
                  Microchip / RFID: <strong>{animal.rfid}</strong>
                </div>
              )}
            </div>
          </div>

          {/* Destaque de Peso Atual */}
          <div
            style={{
              flex: '1 1 130px',
              minWidth: '130px',
              padding: '12px 16px',
              background: '#f8fafc',
              borderRadius: '12px',
              border: '1px solid var(--border)'
            }}
          >
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', fontWeight: 600 }}>
              Peso Atual
            </div>
            <div style={{ fontSize: '24px', fontWeight: 800, color: 'var(--text-main)', fontFamily: 'var(--font-display)' }}>
              {animal.peso_atual} kg
            </div>
            <div style={{ fontSize: '12px', color: '#15803d', fontWeight: 600 }}>
              ≈ {(animal.peso_atual / 30).toFixed(1)} @ arrobas
            </div>
          </div>
        </div>

        {/* Detalhes Técnicos em Grid Responsivo */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(130px, 1fr))',
            gap: '12px',
            marginTop: '16px',
            paddingTop: '16px',
            borderTop: '1px solid var(--border)'
          }}
        >
          <div>
            <span style={{ fontSize: '11px', color: '#64748b', textTransform: 'uppercase', fontWeight: 600 }}>Lote Atual</span>
            <div style={{ fontWeight: 600, fontSize: '13px' }}>{lote ? lote.nome : 'Sem Lote'}</div>
          </div>
          <div>
            <span style={{ fontSize: '11px', color: '#64748b', textTransform: 'uppercase', fontWeight: 600 }}>Nascimento</span>
            <div style={{ fontWeight: 600, fontSize: '13px' }}>{formatarData(animal.data_nascimento)}</div>
          </div>
          <div>
            <span style={{ fontSize: '11px', color: '#64748b', textTransform: 'uppercase', fontWeight: 600 }}>GMD Recente</span>
            <div style={{ fontWeight: 700, fontSize: '13px', color: animal.gmd_recente > 0 ? '#16a34a' : 'inherit' }}>
              {animal.gmd_recente > 0 ? `+${formatarNumero(animal.gmd_recente, 2)} kg/d` : '-'}
            </div>
          </div>
          <div>
            <span style={{ fontSize: '11px', color: '#64748b', textTransform: 'uppercase', fontWeight: 600 }}>Última Pesagem</span>
            <div style={{ fontWeight: 600, fontSize: '13px' }}>{formatarData(animal.data_ultima_pesagem)}</div>
          </div>
        </div>
      </div>

      {/* Histórico de Pesagens & GMD */}
      <div className="card" style={{ marginBottom: '20px', maxWidth: '100%', minWidth: 0 }}>
        <div className="card-header">
          <h4 className="card-title">
            <Scale size={18} className="text-primary" />
            <span>Histórico de Pesagens & GMD</span>
          </h4>
        </div>

        {pesagens.length === 0 ? (
          <div style={{ padding: '20px', textAlign: 'center', color: 'var(--text-muted)' }}>
            Nenhuma pesagem registrada para este animal.
          </div>
        ) : (
          <div className="table-container">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Data</th>
                  <th>Peso</th>
                  <th>Anterior</th>
                  <th>Dias</th>
                  <th>GMD</th>
                  <th>Resp.</th>
                </tr>
              </thead>
              <tbody>
                {pesagens.map((p) => (
                  <tr key={p.id}>
                    <td>{formatarData(p.data)}</td>
                    <td style={{ fontWeight: 700 }}>{p.peso} kg</td>
                    <td style={{ color: 'var(--text-muted)' }}>{p.peso_anterior ? `${p.peso_anterior} kg` : '-'}</td>
                    <td>{p.dias_decorridos ? `${p.dias_decorridos} d` : '-'}</td>
                    <td>
                      {p.gmd > 0 ? (
                        <span style={{ color: '#16a34a', fontWeight: 700 }}>
                          +{formatarNumero(p.gmd, 2)} kg/d
                        </span>
                      ) : (
                        '-'
                      )}
                    </td>
                    <td style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{p.responsavel || '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Histórico Sanitário e Aplicações */}
      <div className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
        <div className="card-header">
          <h4 className="card-title">
            <HeartPulse size={18} color="#dc2626" />
            <span>Histórico Sanitário & Medicamentos</span>
          </h4>
        </div>

        {aplicacoes.length === 0 ? (
          <div style={{ padding: '20px', textAlign: 'center', color: 'var(--text-muted)' }}>
            Nenhuma aplicação sanitária registrada para este animal.
          </div>
        ) : (
          <div className="table-container">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Data</th>
                  <th>Medicamento / Vacina</th>
                  <th>Dose / Via</th>
                  <th>Motivo</th>
                  <th>Status Carência</th>
                  <th>Resp.</th>
                </tr>
              </thead>
              <tbody>
                {aplicacoes.map((apl) => (
                  <tr key={apl.id}>
                    <td>{formatarData(apl.data_aplicacao)}</td>
                    <td style={{ fontWeight: 600 }}>{apl.produto_nome}</td>
                    <td>{apl.dose} ({apl.via})</td>
                    <td style={{ fontSize: '12px' }}>{apl.motivo || '-'}</td>
                    <td>
                      <BadgeCarencia carenciaFim={apl.carencia_fim} />
                    </td>
                    <td style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{apl.responsavel || '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
