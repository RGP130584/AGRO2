import React, { useState } from 'react';
import { ArrowLeft, Save } from 'lucide-react';
import { db } from '../../db/database.js';
import { useSync } from '../../contexts/SyncContext.jsx';
import { getActiveFazendaId } from '../../utils/fazendaHelper.js';

export default function LancamentoForm({ onSalvo, onCancelar }) {
  const { queueSyncEvent } = useSync();
  const [loading, setLoading] = useState(false);

  const [form, setForm] = useState({
    tipo: 'pagar',
    categoria: 'Insumos / Ração',
    descricao: '',
    valor: '',
    vencimento: new Date().toISOString().split('T')[0],
    fornecedor_cliente: '',
    status: 'pendente'
  });

  const handleSubmit = async (e) => {
    e.preventDefault();
    const val = parseFloat(form.valor);
    if (!form.descricao.trim() || !val || val <= 0) {
      alert('Informe a descrição e o valor do lançamento.');
      return;
    }

    setLoading(true);
    try {
      const activeFazId = await getActiveFazendaId();
      const id = `fin-${Date.now()}`;
      const payload = {
        id,
        fazenda_id: activeFazId,
        tipo: form.tipo,
        categoria: form.categoria,
        descricao: form.descricao.trim(),
        valor: val,
        vencimento: form.vencimento,
        data_pagamento: form.status === 'pago' ? form.vencimento : null,
        status: form.status,
        fornecedor_cliente: form.fornecedor_cliente.trim(),
        sync_status: 'pending',
        created_at: new Date().toISOString()
      };

      await db.financeiro_lancamentos.add(payload);
      await queueSyncEvent('financeiro_lancamentos', id, 'create', payload);

      alert('Lançamento financeiro registrado com sucesso!');
      onSalvo();
    } catch (err) {
      console.error('Erro ao salvar lançamento:', err);
      alert('Erro ao registrar lançamento.');
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
        <h2 style={{ fontSize: '20px' }}>Novo Lançamento Financeiro</h2>
      </div>

      <div className="card">
        <form onSubmit={handleSubmit}>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Tipo de Lançamento</label>
              <select
                className="form-select"
                value={form.tipo}
                onChange={(e) => setForm({ ...form, tipo: e.target.value })}
              >
                <option value="pagar">Conta a Pagar (Despesa)</option>
                <option value="receber">Conta a Receber (Receita / Venda)</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Categoria</label>
              <select
                className="form-select"
                value={form.categoria}
                onChange={(e) => setForm({ ...form, categoria: e.target.value })}
              >
                <option value="Insumos / Ração">Insumos / Ração</option>
                <option value="Medicamentos & Vacinas">Medicamentos & Vacinas</option>
                <option value="Venda de Gado Gordo">Venda de Gado Gordo</option>
                <option value="Venda de Bezerros">Venda de Bezerros</option>
                <option value="Veterinária & Serviços">Veterinária & Serviços</option>
                <option value="Manutenção de Pastos & Cerca">Manutenção de Pastos & Cerca</option>
                <option value="Combustível & Máquinas">Combustível & Máquinas</option>
                <option value="Outros">Outros</option>
              </select>
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Descrição *</label>
            <input
              type="text"
              className="form-input"
              value={form.descricao}
              onChange={(e) => setForm({ ...form, descricao: e.target.value })}
              placeholder="Ex: Compra de 50 sacos de sal mineral fosfatado"
              required
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Valor (R$) *</label>
              <input
                type="number"
                step="0.01"
                inputMode="decimal"
                pattern="[0-9]*"
                className="form-input"
                value={form.valor}
                onChange={(e) => setForm({ ...form, valor: e.target.value })}
                placeholder="Ex: 2700.00"
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Data de Vencimento</label>
              <input
                type="date"
                className="form-input"
                value={form.vencimento}
                onChange={(e) => setForm({ ...form, vencimento: e.target.value })}
                required
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Fornecedor / Cliente</label>
              <input
                type="text"
                className="form-input"
                value={form.fornecedor_cliente}
                onChange={(e) => setForm({ ...form, fornecedor_cliente: e.target.value })}
                placeholder="Ex: Frigorífico JBS / Cooperativa Agro"
              />
            </div>

            <div className="form-group">
              <label className="form-label">Situação Inicial</label>
              <select
                className="form-select"
                value={form.status}
                onChange={(e) => setForm({ ...form, status: e.target.value })}
              >
                <option value="pendente">Pendente / Em Aberto</option>
                <option value="pago">Já Liquidado / Pago</option>
              </select>
            </div>
          </div>

          <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
            <button type="button" onClick={onCancelar} className="btn btn-secondary btn-block">
              Cancelar
            </button>
            <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
              <Save size={16} />
              <span>{loading ? 'Salvando...' : 'Salvar Lançamento'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
