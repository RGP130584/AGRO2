import React, { useState, useEffect } from 'react';
import {
  Layers,
  HeartPulse,
  Scale,
  Wheat,
  AlertTriangle,
  PlusCircle,
  TrendingUp,
  Package,
  Calendar,
  CheckCircle,
  ArrowRight
} from 'lucide-react';
import { db } from '../db/database.js';
import BadgeCarencia from '../components/BadgeCarencia.jsx';
import { formatarNumero, formatarData } from '../utils/formatters.js';

export default function Dashboard({ onNavigate }) {
  const [loading, setLoading] = useState(true);
  const [especieFiltro, setEspecieFiltro] = useState('Todos');
  const [metrics, setMetrics] = useState({
    totalAnimais: 0,
    animaisEmCarencia: 0,
    gmdMedio: 0,
    totalLotes: 0,
    produtosBaixoEstoque: 0
  });
  const [animaisCarencia, setAnimaisCarencia] = useState([]);
  const [lotesResumo, setLotesResumo] = useState([]);

  useEffect(() => {
    async function carregarDashboard() {
      try {
        const todosAnimais = await db.animais.filter((a) => a.status === 'ativo').toArray();
        const todosLotes = await db.lotes.toArray();
        const produtos = await db.produtos.toArray();

        // Filtrar por espécie se selecionado
        const animais = todosAnimais.filter((a) => especieFiltro === 'Todos' || (a.especie || 'Bovino') === especieFiltro);
        const lotes = todosLotes.filter((l) => especieFiltro === 'Todos' || (l.especie || 'Bovino') === especieFiltro);

        // Checar carência
        const hojeStr = new Date().toISOString().split('T')[0];
        const sobCarencia = animais.filter((a) => a.carencia_fim && a.carencia_fim >= hojeStr);

        // GMD Médio
        const gmds = animais.filter((a) => a.gmd_recente > 0).map((a) => a.gmd_recente);
        const mediaGmd = gmds.length > 0 ? gmds.reduce((a, b) => a + b, 0) / gmds.length : 0;

        // Produtos com estoque baixo
        const baixos = produtos.filter((p) => p.saldo_atual <= p.estoque_minimo);

        // Lotes com contagem
        const lotesContados = await Promise.all(
          lotes.map(async (l) => {
            const count = await db.animais.where('lote_id').equals(l.id).count();
            return { ...l, quantidade: count };
          })
        );

        setMetrics({
          totalAnimais: animais.length,
          animaisEmCarencia: sobCarencia.length,
          gmdMedio: mediaGmd,
          totalLotes: lotes.length,
          produtosBaixoEstoque: baixos.length
        });

        setAnimaisCarencia(sobCarencia);
        setLotesResumo(lotesContados);
      } catch (err) {
        console.error('Erro ao carregar dashboard:', err);
      } finally {
        setLoading(false);
      }
    }
    carregarDashboard();
  }, [especieFiltro]);

  const ESPECIES = [
    { id: 'Todos', label: '🌐 Todos' },
    { id: 'Bovino', label: '🐄 Bovinos' },
    { id: 'Ovino', label: '🐑 Ovinos' },
    { id: 'Equino', label: '🐎 Equinos' },
    { id: 'Búfalo', label: '🦬 Búfalos' },
    { id: 'Caprino', label: '🐐 Caprinos' },
    { id: 'Outro', label: '🐫 Outros' }
  ];

  if (loading) {
    return <div style={{ padding: '40px', textAlign: 'center' }}>Carregando dados do rebanho...</div>;
  }

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      {/* Abas de Seleção de Espécie (Mobile-First Wrap) */}
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

      {/* Top Banner Alerta de Carência */}
      {metrics.animaisEmCarencia > 0 && (
        <div
          style={{
            background: 'linear-gradient(90deg, #fee2e2, #fecaca)',
            border: '1px solid #f87171',
            borderRadius: 'var(--radius-lg)',
            padding: '14px 16px',
            marginBottom: '20px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '12px',
            flexWrap: 'wrap'
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ background: '#dc2626', color: 'white', padding: '8px', borderRadius: '50%' }}>
              <AlertTriangle size={20} />
            </div>
            <div>
              <div style={{ fontWeight: 700, color: '#991b1b', fontSize: '15px' }}>
                Atenção Sanitária: {metrics.animaisEmCarencia} {metrics.animaisEmCarencia === 1 ? 'animal' : 'animais'} {especieFiltro !== 'Todos' ? `de ${especieFiltro}` : ''} em carência
              </div>
              <div style={{ fontSize: '13px', color: '#b91c1c' }}>
                Proibido envio para abate ou ordenha até o vencimento da carência.
              </div>
            </div>
          </div>
          <button
            onClick={() => onNavigate('saude')}
            className="btn btn-sm"
            style={{ background: '#dc2626', color: 'white', border: 'none', flex: '1 1 auto', justifyContent: 'center' }}
          >
            Ver Detalhes
          </button>
        </div>
      )}

      {/* KPI Cards Grid */}
      <div className="kpi-grid">
        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">Rebanho ({especieFiltro})</div>
            <div className="kpi-value">{metrics.totalAnimais} <span style={{ fontSize: '14px', fontWeight: 500, color: '#64748b' }}>cab.</span></div>
          </div>
          <div className="kpi-icon" style={{ background: '#dcfce7', color: '#15803d' }}>
            <Layers size={24} />
          </div>
        </div>

        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">GMD Médio</div>
            <div className="kpi-value" style={{ color: '#16a34a' }}>
              +{formatarNumero(metrics.gmdMedio, 2)} <span style={{ fontSize: '14px', fontWeight: 500, color: '#64748b' }}>kg/dia</span>
            </div>
          </div>
          <div className="kpi-icon" style={{ background: '#e0f2fe', color: '#0284c7' }}>
            <TrendingUp size={24} />
          </div>
        </div>

        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">Carência Ativa</div>
            <div className="kpi-value" style={{ color: metrics.animaisEmCarencia > 0 ? '#dc2626' : '#15803d' }}>
              {metrics.animaisEmCarencia} <span style={{ fontSize: '14px', fontWeight: 500, color: '#64748b' }}>animais</span>
            </div>
          </div>
          <div className="kpi-icon" style={{ background: metrics.animaisEmCarencia > 0 ? '#fee2e2' : '#dcfce7', color: metrics.animaisEmCarencia > 0 ? '#dc2626' : '#15803d' }}>
            <HeartPulse size={24} />
          </div>
        </div>

        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">Lotes em Manejo</div>
            <div className="kpi-value">{metrics.totalLotes}</div>
          </div>
          <div className="kpi-icon" style={{ background: '#fef3c7', color: '#d97706' }}>
            <Wheat size={24} />
          </div>
        </div>
      </div>

      {/* Ações Rápidas de Campo */}
      <div style={{ marginBottom: '24px' }}>
        <h3 style={{ fontSize: '16px', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span>⚡ Ações Rápidas de Campo</span>
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))', gap: '10px' }}>
          <button
            onClick={() => onNavigate('saude_aplicar')}
            className="btn btn-secondary"
            style={{ padding: '14px 12px', display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: '8px', textAlign: 'left' }}
          >
            <div style={{ background: '#fee2e2', color: '#dc2626', padding: '8px', borderRadius: '10px' }}>
              <HeartPulse size={18} />
            </div>
            <div>
              <div style={{ fontWeight: 700, fontSize: '13px' }}>Registrar Vacina</div>
              <div style={{ fontSize: '11px', color: '#64748b' }}>Com controle de carência</div>
            </div>
          </button>

          <button
            onClick={() => onNavigate('pesagem_nova')}
            className="btn btn-secondary"
            style={{ padding: '14px 12px', display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: '8px', textAlign: 'left' }}
          >
            <div style={{ background: '#e0f2fe', color: '#0284c7', padding: '8px', borderRadius: '10px' }}>
              <Scale size={18} />
            </div>
            <div>
              <div style={{ fontWeight: 700, fontSize: '13px' }}>Registrar Pesagem</div>
              <div style={{ fontSize: '11px', color: '#64748b' }}>Cálculo automático GMD</div>
            </div>
          </button>

          <button
            onClick={() => onNavigate('nutricao_fornecer')}
            className="btn btn-secondary"
            style={{ padding: '14px 12px', display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: '8px', textAlign: 'left' }}
          >
            <div style={{ background: '#fef3c7', color: '#d97706', padding: '8px', borderRadius: '10px' }}>
              <Wheat size={18} />
            </div>
            <div>
              <div style={{ fontWeight: 700, fontSize: '13px' }}>Fornecer Ração</div>
              <div style={{ fontSize: '11px', color: '#64748b' }}>Baixa no estoque</div>
            </div>
          </button>

          <button
            onClick={() => onNavigate('rebanho_novo')}
            className="btn btn-secondary"
            style={{ padding: '14px 12px', display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: '8px', textAlign: 'left' }}
          >
            <div style={{ background: '#dcfce7', color: '#15803d', padding: '8px', borderRadius: '10px' }}>
              <PlusCircle size={18} />
            </div>
            <div>
              <div style={{ fontWeight: 700, fontSize: '13px' }}>Cadastrar Animal</div>
              <div style={{ fontSize: '11px', color: '#64748b' }}>Brinco, raça e peso</div>
            </div>
          </button>
        </div>
      </div>

      {/* Grid: Lotes Ativos + Animais em Carência */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '16px' }}>
        {/* Card Lotes */}
        <div className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
          <div className="card-header">
            <h4 className="card-title">
              <Layers size={18} className="text-primary" />
              <span>Lotes ({especieFiltro})</span>
            </h4>
            <button onClick={() => onNavigate('rebanho')} className="btn btn-secondary btn-sm">
              Ver Todos
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {lotesResumo.length === 0 ? (
              <div style={{ padding: '16px', color: '#64748b', fontSize: '13px' }}>Nenhum lote registrado.</div>
            ) : (
              lotesResumo.map((lote) => (
                <div
                  key={lote.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '12px 14px',
                    background: '#f8fafc',
                    borderRadius: '10px',
                    border: '1px solid var(--border)'
                  }}
                >
                  <div>
                    <div style={{ fontWeight: 700, fontSize: '14px' }}>{lote.nome}</div>
                    <div style={{ fontSize: '12px', color: '#64748b' }}>
                      {lote.especie || 'Bovino'} • {lote.categoria}
                    </div>
                  </div>
                  <div style={{ textAlign: 'right' }}>
                    <span className="badge badge-info" style={{ fontSize: '13px', padding: '4px 10px' }}>
                      {lote.quantidade} cab.
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Card Animais em Carência */}
        <div className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
          <div className="card-header">
            <h4 className="card-title">
              <HeartPulse size={18} color="#dc2626" />
              <span>Monitoramento de Carência</span>
            </h4>
            <button onClick={() => onNavigate('saude')} className="btn btn-secondary btn-sm">
              Módulo Saúde
            </button>
          </div>

          {animaisCarencia.length === 0 ? (
            <div style={{ padding: '30px', textAlign: 'center', color: '#64748b' }}>
              <CheckCircle size={36} color="#16a34a" style={{ margin: '0 auto 8px auto', display: 'block' }} />
              <div style={{ fontWeight: 600 }}>Nenhum animal sob carência no momento</div>
              <div style={{ fontSize: '12px' }}>Todos os animais liberados para abate e manejo</div>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {animaisCarencia.map((animal) => (
                <div
                  key={animal.id}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    padding: '12px 14px',
                    background: '#fff5f5',
                    borderRadius: '10px',
                    border: '1px solid #fecaca'
                  }}
                >
                  <div>
                    <div style={{ fontWeight: 700, fontSize: '14px', color: '#991b1b' }}>
                      Brinco {animal.brinco} ({animal.especie || 'Bovino'})
                    </div>
                    <div style={{ fontSize: '12px', color: '#b91c1c' }}>
                      {animal.raca} • {animal.peso_atual} kg
                    </div>
                  </div>
                  <BadgeCarencia carenciaFim={animal.carencia_fim} />
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
