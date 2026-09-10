import React, { useState, useEffect } from 'react';
import { ArrowLeft, Save } from 'lucide-react';
import { db } from '../../db/database.js';
import { useAuth } from '../../contexts/AuthContext.jsx';
import { useSync } from '../../contexts/SyncContext.jsx';
import { requireActiveFazendaId } from '../../utils/fazendaHelper.js';

export default function MovimentoForm({ onSalvo, onCancelar }) {
  const { user } = useAuth();
  const { queueSyncEvent } = useSync();

  const [produtos, setProdutos] = useState([]);
  const [loading, setLoading] = useState(false);

  const [form, setForm] = useState({
    produto_id: '',
    tipo: 'entrada',
    quantidade: '',
    data: new Date().toISOString().split('T')[0],
    motivo: 'Compra de Insumos',
    valor_total: ''
  });

  useEffect(() => {
    async function carregar() {
      const list = await db.produtos.toArray();
      setProdutos(list);
      if (list.length > 0) setForm((prev) => ({ ...prev, produto_id: list[0].id }));
    }
    carregar();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const qtd = parseFloat(form.quantidade);
    if (!form.produto_id || !qtd || qtd <= 0) {
      alert('Informe o produto e a quantidade.');
      return;
    }

    setLoading(true);
    try {
      const activeFazId = await requireActiveFazendaId();
      const prod = await db.produtos.get(form.produto_id);
      if (!prod) return;

      const novoSaldo = form.tipo === 'entrada' ? prod.saldo_atual + qtd : Math.max(0, prod.saldo_atual - qtd);
      await db.produtos.update(prod.id, { saldo_atual: novoSaldo, sync_status: 'pending' });

      const movId = `mov-${Date.now()}`;
      const payloadMov = {
        id: movId,
        fazenda_id: activeFazId,
        produto_id: prod.id,
        tipo: form.tipo,
        quantidade: qtd,
        data: form.data,
        motivo: form.motivo.trim(),
        responsavel: user?.nome || 'Operador',
        sync_status: 'pending',
        created_at: new Date().toISOString()
      };

      await db.estoque_movimentos.add(payloadMov);
      await queueSyncEvent('estoque_movimentos', movId, 'create', payloadMov);

      // Se for entrada com valor financeiro, criar lançamento no financeiro
      if (form.tipo === 'entrada' && form.valor_total && parseFloat(form.valor_total) > 0) {
        const finId = `fin-${Date.now()}`;
        const payloadFin = {
          id: finId,
          fazenda_id: activeFazId,
          tipo: 'pagar',
          categoria: 'Insumos / Estoque',
          descricao: `Compra: ${prod.nome} (${qtd} ${prod.unidade})`,
          valor: parseFloat(form.valor_total),
          vencimento: form.data,
          data_pagamento: form.data,
          status: 'pago',
          fornecedor_cliente: 'Fornecedor Agropecuário',
          sync_status: 'pending',
          created_at: new Date().toISOString()
        };
        await db.financeiro_lancamentos.add(payloadFin);
        await queueSyncEvent('financeiro_lancamentos', finId, 'create', payloadFin);
      }

      alert('Movimento de estoque registrado com sucesso!');
      onSalvo();
    } catch (err) {
      console.error('Erro ao registrar movimento:', err);
      alert(err.message || 'Erro ao registrar movimento de estoque.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '580px', margin: '0 auto' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
        <button onClick={onCancelar} className="btn btn-secondary btn-sm">
          <ArrowLeft size={16} />
        </button>
        <h2 style={{ fontSize: '20px' }}>Registrar Entrada / Movimentação de Estoque</h2>
      </div>

      <div className="card">
        <form onSubmit={handleSubmit}>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Tipo de Movimento</label>
              <select
                className="form-select"
                value={form.tipo}
                onChange={(e) => setForm({ ...form, tipo: e.target.value })}
              >
                <option value="entrada">Entrada / Compra</option>
                <option value="saida">Saída / Ajuste de Perda</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Produto *</label>
              <select
                className="form-select"
                value={form.produto_id}
                onChange={(e) => setForm({ ...form, produto_id: e.target.value })}
                required
              >
                {produtos.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.nome} (Saldo atual: {p.saldo_atual} {p.unidade})
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Quantidade *</label>
              <input
                type="number"
                step="1"
                inputMode="decimal"
                pattern="[0-9]*"
                className="form-input"
                value={form.quantidade}
                onChange={(e) => setForm({ ...form, quantidade: e.target.value })}
                placeholder="Ex: 50"
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Data da Movimentação</label>
              <input
                type="date"
                className="form-input"
                value={form.data}
                onChange={(e) => setForm({ ...form, data: e.target.value })}
                required
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Motivo / Fornecedor</label>
              <input
                type="text"
                className="form-input"
                value={form.motivo}
                onChange={(e) => setForm({ ...form, motivo: e.target.value })}
                placeholder="Ex: Nota Fiscal 1234 — Agro Insumos"
              />
            </div>

            {form.tipo === 'entrada' && (
              <div className="form-group">
                <label className="form-label">Valor Total (R$) — Opcional</label>
                <input
                  type="number"
                  step="0.01"
                  inputMode="decimal"
                  pattern="[0-9]*"
                  className="form-input"
                  value={form.valor_total}
                  onChange={(e) => setForm({ ...form, valor_total: e.target.value })}
                  placeholder="Ex: 3400.00"
                />
              </div>
            )}
          </div>

          <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
            <button type="button" onClick={onCancelar} className="btn btn-secondary btn-block">
              Cancelar
            </button>
            <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
              <Save size={16} />
              <span>{loading ? 'Salvando...' : 'Salvar Movimento'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
