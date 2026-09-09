import React, { useState, useEffect } from 'react';
import { HeartPulse, Plus, AlertTriangle, ShieldCheck, ShieldAlert, FileSpreadsheet, Eye, Activity, Tag } from 'lucide-react';
import { db } from '../../db/database.js';
import BadgeCarencia from '../../components/BadgeCarencia.jsx';
import { formatarData } from '../../utils/formatters.js';

export default function SaudeDashboard({ onNovaAplicacao, onNovaOcorrencia, onVerAnimal }) {
  const [animaisCarencia, setAnimaisCarencia] = useState([]);
  const [historicoAplicacoes, setHistoricoAplicacoes] = useState([]);
  const [ocorrencias, setOcorrencias] = useState([]);
  const [especieFiltro, setEspecieFiltro] = useState('Todos');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    carregarSaude();
  }, []);

  async function carregarSaude() {
    try {
      const hojeStr = new Date().toISOString().split('T')[0];
      const [animais, aplicacoes, listaOcorrencias] = await Promise.all([
        db.animais.filter((a) => a.carencia_fim && a.carencia_fim >= hojeStr).toArray(),
        db.aplicacoes_sanitarias.reverse().limit(30).toArray(),
        db.ocorrencias_sanitarias.reverse().limit(10).toArray()
      ]);

      setAnimaisCarencia(animais);
      setHistoricoAplicacoes(aplicacoes);
      setOcorrencias(listaOcorrencias);
    } catch (err) {
      console.error('Erro ao carregar dados de saúde:', err);
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

  const animaisCarenciaFiltrados = animaisCarencia.filter(
    (a) => especieFiltro === 'Todos' || (a.especie || 'Bovino') === especieFiltro
  );

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '10px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Saúde Animal & Controle Sanitário</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Protocolos vacinais, carência rigorosa para abate e ocorrências clínicas
          </p>
        </div>

        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', maxWidth: '100%' }}>
          <button onClick={onNovaOcorrencia} className="btn btn-secondary btn-sm">
            <Activity size={15} />
            <span>Ocorrência</span>
          </button>

          <button onClick={() => onNovaAplicacao()} className="btn btn-primary btn-sm">
            <Plus size={15} />
            <span>Aplicar Vacina</span>
          </button>
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

      {/* Alerta de Carência em Destaque (Cartões Responsivos sem Rolagem Lateral) */}
      <div className="card" style={{ marginBottom: '20px', borderColor: animaisCarenciaFiltrados.length > 0 ? '#f87171' : 'var(--border)', maxWidth: '100%', minWidth: 0 }}>
        <div className="card-header">
          <h4 className="card-title" style={{ color: animaisCarenciaFiltrados.length > 0 ? '#dc2626' : 'var(--text-main)' }}>
            <AlertTriangle size={18} color={animaisCarenciaFiltrados.length > 0 ? '#dc2626' : '#16a34a'} />
            <span>Animais em Período de Carência ({animaisCarenciaFiltrados.length})</span>
          </h4>
        </div>

        {animaisCarenciaFiltrados.length === 0 ? (
          <div style={{ padding: '20px', textAlign: 'center', color: 'var(--text-muted)' }}>
            <ShieldCheck size={32} color="#16a34a" style={{ margin: '0 auto 6px auto', display: 'block' }} />
            <div style={{ fontWeight: 600, color: 'var(--text-main)', fontSize: '14px' }}>Nenhum animal em carência {especieFiltro !== 'Todos' ? `para ${especieFiltro}s` : ''}</div>
            <div style={{ fontSize: '12px' }}>100% liberado para abate, comercialização e consumo.</div>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {animaisCarenciaFiltrados.map((a) => (
              <div
                key={a.id}
                style={{
                  padding: '12px 14px',
                  borderRadius: '12px',
                  background: '#fef2f2',
                  border: '1px solid #fca5a5',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '8px'
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div style={{ fontWeight: 800, fontSize: '15px', color: '#991b1b' }}>
                    Brinco {a.brinco}
                  </div>
                  <span style={{ fontSize: '12px', color: '#b91c1c', fontWeight: 700 }}>
                    Até {formatarData(a.carencia_fim)}
                  </span>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '13px' }}>
                  <div style={{ color: '#7f1d1d' }}>
                    {a.especie ? `${a.especie} • ` : ''}{a.raca} ({a.categoria}, {a.peso_atual} kg)
                  </div>
                  <BadgeCarencia carenciaFim={a.carencia_fim} produtoNome={a.ultima_aplicacao_nome} />
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '6px', borderTop: '1px dashed #fca5a5' }}>
                  <span style={{ fontSize: '11px', color: '#991b1b', fontWeight: 600 }}>
                    🚫 Aplicações Bloqueadas em Carência
                  </span>
                  <button onClick={() => onVerAnimal(a.id)} className="btn btn-secondary btn-sm" style={{ padding: '4px 10px', fontSize: '11px' }}>
                    <Eye size={13} />
                    <span>Ver Ficha</span>
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Histórico Recente de Aplicações em Cartões Responsivos */}
      <div className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
        <div className="card-header">
          <h4 className="card-title">
            <HeartPulse size={18} className="text-primary" />
            <span>Últimas Aplicações Registradas</span>
          </h4>
        </div>

        {historicoAplicacoes.length === 0 ? (
          <div style={{ padding: '20px', textAlign: 'center', color: 'var(--text-muted)' }}>
            Nenhuma aplicação registrada até o momento.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {historicoAplicacoes.map((apl) => (
              <div
                key={apl.id}
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
                    {apl.produto_nome}
                  </span>
                  <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: 600 }}>
                    {formatarData(apl.data_aplicacao)}
                  </span>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '12px', color: 'var(--text-muted)' }}>
                  <div>Dose / Via: <strong>{apl.dose} ({apl.via})</strong></div>
                  <BadgeCarencia carenciaFim={apl.carencia_fim} />
                </div>

                {apl.motivo && (
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontStyle: 'italic' }}>
                    Motivo: {apl.motivo}
                  </div>
                )}

                <div style={{ fontSize: '11px', color: '#94a3b8', textAlign: 'right', borderTop: '1px dashed #e2e8f0', paddingTop: '4px' }}>
                  Resp: {apl.responsavel || '-'}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

