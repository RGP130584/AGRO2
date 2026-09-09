import React, { useState, useEffect } from 'react';
import { Package, Plus, AlertTriangle, ArrowDownRight, ArrowUpRight, CheckCircle2 } from 'lucide-react';
import { db } from '../../db/database.js';
import { formatarData, formatarMoeda } from '../../utils/formatters.js';

export default function EstoqueList({ onNovaEntrada }) {
  const [produtos, setProdutos] = useState([]);
  const [movimentos, setMovimentos] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    carregarEstoque();
  }, []);

  async function carregarEstoque() {
    try {
      const [listProdutos, listMovimentos] = await Promise.all([
        db.produtos.toArray(),
        db.estoque_movimentos.reverse().limit(20).toArray()
      ]);
      setProdutos(listProdutos);
      setMovimentos(listMovimentos);
    } catch (err) {
      console.error('Erro ao carregar estoque:', err);
    } finally {
      setLoading(false);
    }
  }

  const getNomeProduto = (produtoId) => {
    const p = produtos.find((item) => item.id === produtoId);
    return p ? p.nome : 'Produto';
  };

  return (
    <div style={{ maxWidth: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Estoque de Insumos & Medicamentos</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Saldos, alerta de estoque mínimo, baixas automáticas de saúde/trato e validade
          </p>
        </div>

        <button onClick={onNovaEntrada} className="btn btn-primary btn-sm" style={{ flex: '1 1 auto', justifyContent: 'center' }}>
          <Plus size={16} />
          <span>Lançar Entrada / Compra</span>
        </button>
      </div>

      {/* Grid de Saldos em Estoque */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '14px', marginBottom: '24px' }}>
        {produtos.map((p) => {
          const isBaixo = p.saldo_atual <= p.estoque_minimo;
          return (
            <div key={p.id} className="card" style={{ borderColor: isBaixo ? '#fca5a5' : 'var(--border)' }}>
              <div className="card-header" style={{ marginBottom: '8px' }}>
                <h4 style={{ fontSize: '15px', fontWeight: 700 }}>{p.nome}</h4>
                <span className={`badge ${isBaixo ? 'badge-warning' : 'badge-info'}`} style={{ textTransform: 'capitalize' }}>
                  {p.tipo}
                </span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginTop: '12px' }}>
                <div>
                  <div style={{ fontSize: '11px', color: '#64748b', textTransform: 'uppercase', fontWeight: 600 }}>
                    Saldo Atual
                  </div>
                  <div style={{ fontSize: '22px', fontWeight: 800, color: isBaixo ? '#dc2626' : '#15803d' }}>
                    {p.saldo_atual} <span style={{ fontSize: '13px', fontWeight: 500 }}>{p.unidade}</span>
                  </div>
                </div>

                <div style={{ textAlign: 'right', fontSize: '12px', color: 'var(--text-muted)' }}>
                  <div>Mínimo: {p.estoque_minimo} {p.unidade}</div>
                  <div>Validade: {formatarData(p.validade)}</div>
                </div>
              </div>

              {isBaixo && (
                <div style={{ background: '#fffbeb', color: '#b45309', padding: '6px 10px', borderRadius: '6px', fontSize: '11px', fontWeight: 600, marginTop: '12px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <AlertTriangle size={13} />
                  <span>Estoque abaixo do limite de segurança!</span>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Histórico de Movimentações */}
      <div className="card" style={{ maxWidth: '100%', minWidth: 0 }}>
        <div className="card-header">
          <h4 className="card-title">
            <Package size={18} className="text-primary" />
            <span>Últimas Movimentações no Estoque</span>
          </h4>
        </div>

        {movimentos.length === 0 ? (
          <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)' }}>
            Nenhuma movimentação de estoque registrada.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {movimentos.map((m) => (
              <div
                key={m.id}
                style={{
                  padding: '12px 14px',
                  borderRadius: '10px',
                  background: '#f8fafc',
                  border: '1px solid var(--border)',
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '6px'
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ fontWeight: 700, fontSize: '14px' }}>{getNomeProduto(m.produto_id)}</span>
                  {m.tipo === 'entrada' ? (
                    <span className="badge badge-liberado" style={{ fontSize: '11px' }}>
                      <ArrowUpRight size={12} /> +{m.quantidade} (Entrada)
                    </span>
                  ) : (
                    <span className="badge badge-warning" style={{ fontSize: '11px' }}>
                      <ArrowDownRight size={12} /> -{m.quantidade} (Saída)
                    </span>
                  )}
                </div>

                <div style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'flex', justifyContent: 'space-between', flexWrap: 'wrap', gap: '4px' }}>
                  <span>{m.motivo}</span>
                  <span>{formatarData(m.data)}</span>
                </div>
                {m.responsavel && (
                  <div style={{ fontSize: '11px', color: '#94a3b8' }}>Responsável: {m.responsavel}</div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
