import React, { useState, useEffect } from 'react';
import { ArrowLeft, Save, Wheat, AlertTriangle } from 'lucide-react';
import { db } from '../../db/database.js';
import { useAuth } from '../../contexts/AuthContext.jsx';
import { useSync } from '../../contexts/SyncContext.jsx';
import { requireActiveFazendaId } from '../../utils/fazendaHelper.js';

export default function FornecimentoForm({ onSalvo, onCancelar }) {
  const { user } = useAuth();
  const { queueSyncEvent } = useSync();

  const [lotes, setLotes] = useState([]);
  const [dietas, setDietas] = useState([]);
  const [produtos, setProdutos] = useState([]);
  const [loading, setLoading] = useState(false);
  const [especie, setEspecie] = useState('Bovino');

  const [form, setForm] = useState({
    lote_id: '',
    dieta_id: '',
    produto_id: '',
    data: new Date().toISOString().split('T')[0],
    quantidade_planejada_kg: 0,
    quantidade_fornecida_kg: '',
    observacao: ''
  });

  const [produtoAtual, setProdutoAtual] = useState(null);

  useEffect(() => {
    async function carregar() {
      const [listLotes, listDietas, listProdutos] = await Promise.all([
        db.lotes.toArray(),
        db.dietas.filter((d) => d.ativa).toArray(),
        db.produtos.filter((p) => ['racao', 'suplemento'].includes(p.tipo)).toArray()
      ]);

      setLotes(listLotes);
      setDietas(listDietas);
      setProdutos(listProdutos);

      const lotesFiltrados = listLotes.filter((l) => (l.especie || 'Bovino') === especie);
      if (lotesFiltrados.length > 0) {
        const primeiroLote = lotesFiltrados[0];
        setForm((prev) => ({ ...prev, lote_id: primeiroLote.id }));
        atualizarPlanejado(primeiroLote.id, listDietas, listProdutos);
      } else {
        setForm((prev) => ({ ...prev, lote_id: '', quantidade_planejada_kg: 0, quantidade_fornecida_kg: '' }));
      }
    }
    carregar();
  }, [especie]);

  const atualizarPlanejado = async (loteId, listaDietas = dietas, listaProdutos = produtos) => {
    const dieta = listaDietas.find((d) => d.lote_id === loteId) || listaDietas[0];
    const totalAnimais = await db.animais.where('lote_id').equals(loteId).count();

    if (dieta) {
      const totalPlanejado = (dieta.consumo_cabeca_dia_kg || 0) * (totalAnimais || 1);
      const prod = listaProdutos.find((p) => p.id === dieta.produto_id) || listaProdutos[0];
      setProdutoAtual(prod);

      setForm((prev) => ({
        ...prev,
        lote_id: loteId,
        dieta_id: dieta.id,
        produto_id: prod ? prod.id : '',
        quantidade_planejada_kg: Math.round(totalPlanejado),
        quantidade_fornecida_kg: String(Math.round(totalPlanejado))
      }));
    }
  };

  const handleLoteChange = (e) => {
    const lId = e.target.value;
    atualizarPlanejado(lId);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const qtdFornecida = parseFloat(form.quantidade_fornecida_kg);
    if (!qtdFornecida || qtdFornecida <= 0) {
      alert('Informe a quantidade fornecida em kg.');
      return;
    }

    setLoading(true);
    try {
      const activeFazId = await requireActiveFazendaId();
      const id = `forn-${Date.now()}`;
      const responsavel = user?.nome || 'Operador';

      const payload = {
        id,
        fazenda_id: activeFazId,
        lote_id: form.lote_id,
        especie,
        dieta_id: form.dieta_id,
        produto_id: form.produto_id,
        data: form.data,
        quantidade_planejada_kg: form.quantidade_planejada_kg,
        quantidade_fornecida_kg: qtdFornecida,
        responsavel,
        status_conformidade: Math.abs(qtdFornecida - form.quantidade_planejada_kg) > form.quantidade_planejada_kg * 0.15 ? 'divergente' : 'conforme',
        sync_status: 'pending',
        created_at: new Date().toISOString()
      };

      // 1. Gravar fornecimento
      await db.fornecimentos_dieta.add(payload);
      await queueSyncEvent('fornecimentos_dieta', id, 'create', payload);

      // 2. Baixa automática no estoque
      if (form.produto_id) {
        const prod = await db.produtos.get(form.produto_id);
        if (prod) {
          const novoSaldo = Math.max(0, (prod.saldo_atual || 0) - qtdFornecida);
          await db.produtos.update(prod.id, { saldo_atual: novoSaldo, sync_status: 'pending' });

          const movPayload = {
            id: `mov-${Date.now()}`,
            fazenda_id: activeFazId,
            produto_id: prod.id,
            tipo: 'saida',
            quantidade: qtdFornecida,
            data: form.data,
            motivo: `Trato / Fornecimento Nutricional (${qtdFornecida} kg)`,
            referencia_id: form.lote_id,
            responsavel,
            sync_status: 'pending',
            created_at: new Date().toISOString()
          };
          await db.estoque_movimentos.add(movPayload);
        }
      }

      alert('Fornecimento diário registrado e estoque atualizado com sucesso!');
      onSalvo();
    } catch (err) {
      console.error('Erro ao registrar fornecimento:', err);
      alert(err.message || 'Erro ao registrar fornecimento.');
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
        <h2 style={{ fontSize: '20px' }}>Lançar Fornecimento de Ração / Trato</h2>
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
            <label className="form-label">Lote que Recebeu o Trato ({especie}) *</label>
            <select className="form-select" value={form.lote_id} onChange={handleLoteChange} required>
              {lotesFiltrados.length === 0 ? (
                <option value="">Nenhum lote de {especie} encontrado</option>
              ) : (
                lotesFiltrados.map((l) => (
                  <option key={l.id} value={l.id}>{l.nome}</option>
                ))
              )}
            </select>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Data do Trato</label>
              <input
                type="date"
                className="form-input"
                value={form.data}
                onChange={(e) => setForm({ ...form, data: e.target.value })}
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Quantidade Planejada</label>
              <input
                type="text"
                className="form-input"
                value={`${form.quantidade_planejada_kg} kg`}
                disabled
                style={{ background: '#f8fafc', fontWeight: 600 }}
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Quantidade Efetivamente Fornecida (kg) *</label>
            <input
              type="number"
              step="1"
              inputMode="decimal"
              pattern="[0-9]*"
              className="form-input"
              value={form.quantidade_fornecida_kg}
              onChange={(e) => setForm({ ...form, quantidade_fornecida_kg: e.target.value })}
              placeholder="Ex: 240"
              required
              style={{ fontSize: '18px', fontWeight: 700, color: '#15803d' }}
            />
          </div>

          {produtoAtual && (
            <div style={{ background: '#f8fafc', padding: '12px', borderRadius: '10px', fontSize: '13px', marginBottom: '16px' }}>
              <div style={{ color: '#64748b' }}>Insumo no estoque que sofrerá baixa:</div>
              <div style={{ fontWeight: 700, color: 'var(--text-main)', marginTop: '2px' }}>
                {produtoAtual.nome} (Saldo atual: {produtoAtual.saldo_atual} {produtoAtual.unidade})
              </div>
            </div>
          )}

          <div style={{ display: 'flex', gap: '10px', marginTop: '20px', flexWrap: 'wrap' }}>
            <button type="button" onClick={onCancelar} className="btn btn-secondary btn-block" style={{ flex: '1 1 auto' }}>
              Cancelar
            </button>
            <button type="submit" className="btn btn-primary btn-block" disabled={loading} style={{ flex: '1 1 auto' }}>
              <Save size={16} />
              <span>{loading ? 'Gravando e Baixando Estoque...' : 'Confirmar e Baixar Estoque'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
