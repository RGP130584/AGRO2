import React, { useState, useEffect } from 'react';
import { FileText, ShieldCheck, Printer, Download, Scale, Wheat, Layers } from 'lucide-react';
import { db } from '../../db/database.js';
import BadgeCarencia from '../../components/BadgeCarencia.jsx';
import { formatarData, formatarNumero, formatarMoeda } from '../../utils/formatters.js';

export default function RelatoriosDashboard({ onVerFichaAnimal }) {
  const [lotes, setLotes] = useState([]);
  const [especieFiltro, setEspecieFiltro] = useState('Todos');
  const [loteSelecionado, setLoteSelecionado] = useState('');
  const [animaisLote, setAnimaisLote] = useState([]);
  const [aplicacoesLote, setAplicacoesLote] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function carregarLotes() {
      const listLotes = await db.lotes.toArray();
      setLotes(listLotes);

      const lotesFiltrados = listLotes.filter((l) => especieFiltro === 'Todos' || (l.especie || 'Bovino') === especieFiltro);
      if (lotesFiltrados.length > 0) {
        setLoteSelecionado(lotesFiltrados[0].id);
        carregarRelatorioLote(lotesFiltrados[0].id);
      } else {
        setLoteSelecionado('');
        setAnimaisLote([]);
        setAplicacoesLote([]);
      }
    }
    carregarLotes();
  }, [especieFiltro]);

  const carregarRelatorioLote = async (loteId) => {
    if (!loteId) return;
    setLoading(true);
    try {
      const [animais, aplicacoes] = await Promise.all([
        db.animais.where('lote_id').equals(loteId).toArray(),
        db.aplicacoes_sanitarias.where('lote_id').equals(loteId).toArray()
      ]);
      setAnimaisLote(animais);
      setAplicacoesLote(aplicacoes);
    } catch (err) {
      console.error('Erro ao gerar relatório:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleLoteChange = (e) => {
    const lId = e.target.value;
    setLoteSelecionado(lId);
    carregarRelatorioLote(lId);
  };

  const handleImprimir = () => {
    window.print();
  };

  const ESPECIES = [
    { id: 'Todos', label: '🌐 Todos' },
    { id: 'Bovino', label: '🐄 Bovinos' },
    { id: 'Ovino', label: '🐑 Ovinos' },
    { id: 'Equino', label: '🐎 Equinos' },
    { id: 'Búfalo', label: '🦬 Búfalos' },
    { id: 'Caprino', label: '🐐 Caprinos' },
    { id: 'Outro', label: '🐫 Outros' }
  ];

  const lotesFiltrados = lotes.filter((l) => especieFiltro === 'Todos' || (l.especie || 'Bovino') === especieFiltro);
  const loteObj = lotes.find((l) => l.id === loteSelecionado);
  const hojeStr = new Date().toISOString().split('T')[0];
  const animaisSobCarencia = animaisLote.filter((a) => a.carencia_fim && a.carencia_fim >= hojeStr);

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Relatórios & Rastreabilidade Sanitária (GTA)</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Documento de conformidade de carência para frigoríficos e transporte
          </p>
        </div>

        <button onClick={handleImprimir} className="btn btn-secondary btn-sm" style={{ flex: '1 1 auto', justifyContent: 'center' }}>
          <Printer size={16} />
          <span>Imprimir Ficha do Lote</span>
        </button>
      </div>

      {/* Selector de Espécie para Relatório */}
      <div style={{ marginBottom: '16px' }}>
        <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
          {ESPECIES.map((esp) => (
            <button
              key={esp.id}
              onClick={() => setEspecieFiltro(esp.id)}
              className={`btn btn-sm ${especieFiltro === esp.id ? 'btn-primary' : 'btn-secondary'}`}
              style={{ fontSize: '12px', flex: '1 1 auto', justifyContent: 'center' }}
            >
              {esp.label}
            </button>
          ))}
        </div>
      </div>

      {/* Seletor de Lote */}
      <div className="card" style={{ marginBottom: '20px', padding: '16px', maxWidth: '100%', minWidth: 0 }}>
        <div className="form-group" style={{ marginBottom: 0 }}>
          <label className="form-label">Selecionar Lote para Emissão do Laudo ({especieFiltro})</label>
          <select className="form-select" value={loteSelecionado} onChange={handleLoteChange}>
            {lotesFiltrados.length === 0 ? (
              <option value="">Nenhum lote encontrado nesta categoria</option>
            ) : (
              lotesFiltrados.map((l) => (
                <option key={l.id} value={l.id}>{l.nome} ({l.especie || 'Bovino'} - {l.categoria})</option>
              ))
            )}
          </select>
        </div>
      </div>

      {/* Relatório Formatado */}
      <div className="card" id="relatorio-imprimivel" style={{ padding: '20px', maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
        <div style={{ borderBottom: '2px solid #0f172a', paddingBottom: '16px', marginBottom: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '10px' }}>
          <div>
            <h3 style={{ fontSize: '18px', color: '#0f172a', fontWeight: 800 }}>LAUDO DE RASTREABILIDADE & CONFORMIDADE SANITÁRIA</h3>
            <div style={{ fontSize: '12px', color: '#64748b' }}>
              Fazenda Santa Fé & Pecuária • Rio Verde - GO • Data: {formatarData(hojeStr)}
            </div>
          </div>
          <div>
            <span className={`badge ${animaisSobCarencia.length === 0 ? 'badge-liberado' : 'badge-carencia'}`} style={{ fontSize: '12px', padding: '6px 12px' }}>
              {animaisSobCarencia.length === 0 ? '✅ Lote 100% Liberado para Abate' : `🚨 ${animaisSobCarencia.length} Animais Sob Carência`}
            </span>
          </div>
        </div>

        {/* Resumo do Lote */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))', gap: '10px', background: '#f8fafc', padding: '14px', borderRadius: '10px', marginBottom: '20px' }}>
          <div>
            <div style={{ fontSize: '11px', color: '#64748b', textTransform: 'uppercase' }}>Lote</div>
            <div style={{ fontWeight: 700, fontSize: '14px' }}>{loteObj?.nome || 'Nenhum'}</div>
          </div>
          <div>
            <div style={{ fontSize: '11px', color: '#64748b', textTransform: 'uppercase' }}>Espécie</div>
            <div style={{ fontWeight: 600, fontSize: '14px' }}>{loteObj?.especie || 'Bovino'}</div>
          </div>
          <div>
            <div style={{ fontSize: '11px', color: '#64748b', textTransform: 'uppercase' }}>Total Animais</div>
            <div style={{ fontWeight: 700, fontSize: '14px' }}>{animaisLote.length} cab.</div>
          </div>
          <div>
            <div style={{ fontSize: '11px', color: '#64748b', textTransform: 'uppercase' }}>Peso Médio</div>
            <div style={{ fontWeight: 700, color: '#15803d', fontSize: '14px' }}>
              {animaisLote.length > 0
                ? `${Math.round(animaisLote.reduce((acc, a) => acc + (a.peso_atual || 0), 0) / animaisLote.length)} kg`
                : '-'}
            </div>
          </div>
        </div>

        {/* Cards Responsivos de Animais para o Relatório no Celular */}
        <h4 style={{ fontSize: '15px', marginBottom: '10px' }}>1. Relação Individual de Animais do Lote</h4>
        {animaisLote.length === 0 ? (
          <div style={{ fontSize: '13px', color: '#64748b', padding: '12px' }}>Nenhum animal neste lote.</div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '20px' }}>
            {animaisLote.map((a) => (
              <div
                key={a.id}
                onClick={() => onVerFichaAnimal && onVerFichaAnimal(a.id)}
                style={{
                  padding: '10px 12px',
                  borderRadius: '8px',
                  background: '#ffffff',
                  border: '1px solid var(--border)',
                  display: 'flex',
                  justify: 'space-between',
                  alignItems: 'center',
                  cursor: 'pointer',
                  flexWrap: 'wrap',
                  gap: '6px'
                }}
              >
                <div>
                  <span style={{ fontWeight: 800, fontSize: '14px', color: 'var(--primary)', marginRight: '8px' }}>
                    Brinco {a.brinco}
                  </span>
                  <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                    {a.raca} • {a.categoria}
                  </span>
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <span style={{ fontWeight: 700, fontSize: '14px' }}>{a.peso_atual} kg</span>
                  <BadgeCarencia carenciaFim={a.carencia_fim} />
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Histórico de Medicamentos Aplicados */}
        <h4 style={{ fontSize: '15px', marginBottom: '10px' }}>2. Histórico Sanitário / Aplicações Recentes</h4>
        {aplicacoesLote.length === 0 ? (
          <div style={{ fontSize: '13px', color: '#64748b', padding: '10px' }}>
            Nenhum medicamento com carência ativa registrado para este lote nos últimos 90 dias.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            {aplicacoesLote.map((apl) => (
              <div key={apl.id} style={{ padding: '10px 12px', borderRadius: '8px', background: '#f8fafc', border: '1px solid var(--border)', fontSize: '12px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontWeight: 700, fontSize: '13px' }}>
                  <span>{apl.produto_nome} (Dose: {apl.dose})</span>
                  <span>{formatarData(apl.data_aplicacao)}</span>
                </div>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '4px', color: 'var(--text-muted)' }}>
                  <span>Via: {apl.via}</span>
                  <span>Carência até: <strong>{formatarData(apl.carencia_fim)}</strong></span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
