import React, { useState, useEffect } from 'react';
import { DollarSign, Plus, ArrowUpRight, ArrowDownRight, CheckCircle2, Clock } from 'lucide-react';
import { db } from '../../db/database.js';
import { formatarMoeda, formatarData } from '../../utils/formatters.js';

export default function FinanceiroList({ onNovoLancamento }) {
  const [lancamentos, setLancamentos] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    carregarFinanceiro();
  }, []);

  async function carregarFinanceiro() {
    try {
      const list = await db.financeiro_lancamentos.reverse().sortBy('vencimento');
      setLancamentos(list);
    } catch (err) {
      console.error('Erro ao carregar financeiro:', err);
    } finally {
      setLoading(false);
    }
  }

  const handleMarcarPago = async (id, statusAtual) => {
    try {
      const novoStatus = statusAtual === 'pago' ? 'pendente' : 'pago';
      const dataPag = novoStatus === 'pago' ? new Date().toISOString().split('T')[0] : null;
      await db.financeiro_lancamentos.update(id, {
        status: novoStatus,
        data_pagamento: dataPag,
        sync_status: 'pending'
      });
      await carregarFinanceiro();
    } catch (e) {
      console.error('Erro ao alternar status do lançamento:', e);
    }
  };

  const totalPagar = lancamentos
    .filter((l) => l.tipo === 'pagar' && l.status === 'pendente')
    .reduce((acc, l) => acc + (l.valor || 0), 0);

  const totalReceber = lancamentos
    .filter((l) => l.tipo === 'receber' && l.status === 'pendente')
    .reduce((acc, l) => acc + (l.valor || 0), 0);

  const saldoLiquido = totalReceber - totalPagar;

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Financeiro da Pecuária</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Contas a pagar, receitas de venda de gado e apuração de custos operacionais
          </p>
        </div>

        <button onClick={onNovoLancamento} className="btn btn-primary btn-sm" style={{ flex: '1 1 auto', justifyContent: 'center' }}>
          <Plus size={16} />
          <span>Novo Lançamento</span>
        </button>
      </div>

      {/* KPI Cards Financeiros */}
      <div className="kpi-grid">
        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">A Receber (Pendente)</div>
            <div className="kpi-value" style={{ color: '#16a34a' }}>{formatarMoeda(totalReceber)}</div>
          </div>
          <div className="kpi-icon" style={{ background: '#dcfce7', color: '#15803d' }}>
            <ArrowUpRight size={24} />
          </div>
        </div>

        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">A Pagar (Pendente)</div>
            <div className="kpi-value" style={{ color: '#dc2626' }}>{formatarMoeda(totalPagar)}</div>
          </div>
          <div className="kpi-icon" style={{ background: '#fee2e2', color: '#dc2626' }}>
            <ArrowDownRight size={24} />
          </div>
        </div>

        <div className="kpi-card">
          <div className="kpi-info">
            <div className="kpi-label">Projeção de Saldo</div>
            <div className="kpi-value" style={{ color: saldoLiquido >= 0 ? '#15803d' : '#dc2626' }}>
              {formatarMoeda(saldoLiquido)}
            </div>
          </div>
          <div className="kpi-icon" style={{ background: '#e0f2fe', color: '#0284c7' }}>
            <DollarSign size={24} />
          </div>
        </div>
      </div>

      {/* Cards de Lançamentos Responsivos */}
      <div className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
        <div className="card-header">
          <h4 className="card-title">
            <DollarSign size={18} className="text-primary" />
            <span>Fluxo de Caixa & Lançamentos</span>
          </h4>
        </div>

        {lancamentos.length === 0 ? (
          <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)' }}>
            Nenhum lançamento financeiro registrado.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {lancamentos.map((l) => (
              <div
                key={l.id}
                style={{
                  padding: '14px',
                  borderRadius: '10px',
                  background: '#f8fafc',
                  border: '1px solid var(--border)',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '8px'
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div style={{ fontWeight: 700, fontSize: '15px' }}>{l.descricao}</div>
                  <span style={{ fontWeight: 800, fontSize: '16px', color: l.tipo === 'receber' ? '#16a34a' : '#dc2626' }}>
                    {l.tipo === 'receber' ? `+${formatarMoeda(l.valor)}` : `-${formatarMoeda(l.valor)}`}
                  </span>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '6px', fontSize: '12px', color: 'var(--text-muted)' }}>
                  <div>
                    <span className={`badge ${l.tipo === 'receber' ? 'badge-liberado' : 'badge-warning'}`} style={{ fontSize: '10px', marginRight: '6px' }}>
                      {l.tipo === 'receber' ? 'Receita' : 'Despesa'}
                    </span>
                    <span>{l.categoria}</span>
                    {l.fornecedor_cliente && <span> • {l.fornecedor_cliente}</span>}
                  </div>
                  <div>Vencimento: <strong>{formatarData(l.vencimento)}</strong></div>
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', borderTop: '1px dashed #e2e8f0', paddingTop: '8px', marginTop: '4px' }}>
                  {l.status === 'pago' ? (
                    <span className="badge badge-liberado" style={{ fontSize: '11px' }}>
                      <CheckCircle2 size={12} /> {l.tipo === 'receber' ? 'Recebido' : 'Pago'}
                    </span>
                  ) : (
                    <span className="badge badge-warning" style={{ fontSize: '11px' }}>
                      <Clock size={12} /> Pendente
                    </span>
                  )}

                  <button
                    onClick={() => handleMarcarPago(l.id, l.status)}
                    className="btn btn-secondary btn-sm"
                    style={{ fontSize: '12px', padding: '4px 10px' }}
                  >
                    {l.status === 'pago' ? 'Reabrir' : 'Liquidar'}
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
