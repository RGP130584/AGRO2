import React, { useState, useEffect } from 'react';
import { ArrowLeft, Save } from 'lucide-react';
import { db } from '../../db/database.js';
import { useSync } from '../../contexts/SyncContext.jsx';
import { requireActiveFazendaId } from '../../utils/fazendaHelper.js';

export default function DietaForm({ onSalvo, onCancelar }) {
  const { queueSyncEvent } = useSync();
  const [lotes, setLotes] = useState([]);
  const [produtos, setProdutos] = useState([]);
  const [loading, setLoading] = useState(false);

  const [especie, setEspecie] = useState('Bovino');
  const [form, setForm] = useState({
    nome: '',
    descricao: '',
    lote_id: '',
    categoria: 'Boi Gordo',
    consumo_cabeca_dia_kg: '8.0',
    produto_id: ''
  });

  useEffect(() => {
    async function carregar() {
      const [listLotes, listProdutos] = await Promise.all([
        db.lotes.toArray(),
        db.produtos.filter((p) => ['racao', 'suplemento'].includes(p.tipo)).toArray()
      ]);

      setLotes(listLotes);
      setProdutos(listProdutos);

      const lotesFiltrados = listLotes.filter((l) => (l.especie || 'Bovino') === especie);
      if (lotesFiltrados.length > 0) setForm((prev) => ({ ...prev, lote_id: lotesFiltrados[0].id }));
      if (listProdutos.length > 0) setForm((prev) => ({ ...prev, produto_id: listProdutos[0].id }));
    }
    carregar();
  }, [especie]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.nome.trim() || !form.produto_id) {
      alert('Preencha o nome da dieta e selecione o produto.');
      return;
    }

    setLoading(true);
    try {
      const activeFazId = await requireActiveFazendaId();
      const id = `diet-${Date.now()}`;
      const payload = {
        id,
        fazenda_id: activeFazId,
        nome: form.nome.trim(),
        descricao: form.descricao.trim(),
        lote_id: form.lote_id,
        especie,
        categoria: form.categoria,
        consumo_cabeca_dia_kg: parseFloat(form.consumo_cabeca_dia_kg) || 0,
        produto_id: form.produto_id,
        ativa: true,
        sync_status: 'pending',
        created_at: new Date().toISOString()
      };

      await db.dietas.add(payload);
      await queueSyncEvent('dietas', id, 'create', payload);

      alert('Dieta cadastrada com sucesso!');
      onSalvo();
    } catch (err) {
      console.error('Erro ao salvar dieta:', err);
      alert(err.message || 'Erro ao salvar dieta.');
    } finally {
      setLoading(false);
    }
  };

  const lotesFiltrados = lotes.filter((l) => (l.especie || 'Bovino') === especie);

  const ESPECIES = [
    { id: 'Bovino', label: '🐄 Bovino' },
    { id: 'Ovino', label: '🐑 Ovino' },
    { id: 'Equino', label: '🐎 Equino' },
    { id: 'Búfalo', label: '🦬 Búfalo' },
    { id: 'Caprino', label: '🐐 Caprino' },
    { id: 'Outro', label: '🐫 Outro' }
  ];

  return (
    <div style={{ maxWidth: '580px', width: '100%', margin: '0 auto', boxSizing: 'border-box' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
        <button onClick={onCancelar} className="btn btn-secondary btn-sm">
          <ArrowLeft size={16} />
        </button>
        <h2 style={{ fontSize: '20px' }}>Formular Nova Dieta / Trato</h2>
      </div>

      <div className="card">
        {/* Selector de Espécie */}
        <div style={{ marginBottom: '16px' }}>
          <label className="form-label">Tipo de Animal (Espécie)</label>
          <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
            {ESPECIES.map((esp) => (
              <button
                key={esp.id}
                type="button"
                onClick={() => setEspecie(esp.id)}
                className={`btn btn-sm ${especie === esp.id ? 'btn-primary' : 'btn-secondary'}`}
                style={{ fontSize: '12px', flex: '1 1 auto', justifyContent: 'center' }}
              >
                {esp.label}
              </button>
            ))}
          </div>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">Nome da Dieta *</label>
            <input
              type="text"
              className="form-input"
              value={form.nome}
              onChange={(e) => setForm({ ...form, nome: e.target.value })}
              placeholder="Ex: Ração Terminação Confinamento Grão Inteiro"
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label">Descrição / Formulação</label>
            <textarea
              className="form-textarea"
              rows="2"
              value={form.descricao}
              onChange={(e) => setForm({ ...form, descricao: e.target.value })}
              placeholder="Ex: Milho moído + Farelo de soja + Núcleo mineral..."
            ></textarea>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Lote Vinculado ({especie})</label>
              <select
                className="form-select"
                value={form.lote_id}
                onChange={(e) => setForm({ ...form, lote_id: e.target.value })}
              >
                {lotesFiltrados.length === 0 ? (
                  <option value="">Nenhum lote de {especie} encontrado</option>
                ) : (
                  lotesFiltrados.map((l) => (
                    <option key={l.id} value={l.id}>{l.nome}</option>
                  ))
                )}
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Produto / Ração do Estoque *</label>
              <select
                className="form-select"
                value={form.produto_id}
                onChange={(e) => setForm({ ...form, produto_id: e.target.value })}
                required
              >
                {produtos.map((p) => (
                  <option key={p.id} value={p.id}>{p.nome} (Saldo: {p.saldo_atual})</option>
                ))}
              </select>
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Consumo Planejado (kg / cabeça / dia) *</label>
            <input
              type="number"
              step="0.1"
              inputMode="decimal"
              pattern="[0-9]*"
              className="form-input"
              value={form.consumo_cabeca_dia_kg}
              onChange={(e) => setForm({ ...form, consumo_cabeca_dia_kg: e.target.value })}
              required
            />
          </div>

          <div style={{ display: 'flex', gap: '10px', marginTop: '20px', flexWrap: 'wrap' }}>
            <button type="button" onClick={onCancelar} className="btn btn-secondary btn-block" style={{ flex: '1 1 auto' }}>
              Cancelar
            </button>
            <button type="submit" className="btn btn-primary btn-block" disabled={loading} style={{ flex: '1 1 auto' }}>
              <Save size={16} />
              <span>{loading ? 'Salvando...' : 'Salvar Dieta'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
