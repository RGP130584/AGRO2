import React, { useState, useEffect } from 'react';
import { ArrowLeft, Save } from 'lucide-react';
import { db } from '../../db/database.js';
import { useSync } from '../../contexts/SyncContext.jsx';
import { getActiveFazendaId } from '../../utils/fazendaHelper.js';

export default function LoteForm({ loteId, especieInicial, onSalvo, onCancelar }) {
  const { queueSyncEvent } = useSync();
  const [piquetes, setPiquetes] = useState([]);
  const [loading, setLoading] = useState(false);

  const [form, setForm] = useState({
    nome: '',
    especie: especieInicial || 'Bovino',
    categoria: 'Boi Gordo',
    finalidade: 'Engorda Intensiva',
    piquete_id: ''
  });

  useEffect(() => {
    async function carregar() {
      const listPiquetes = await db.piquetes.toArray();
      setPiquetes(listPiquetes);

      if (loteId) {
        const found = await db.lotes.get(loteId);
        if (found) {
          setForm({
            nome: found.nome || '',
            especie: found.especie || 'Bovino',
            categoria: found.categoria || 'Boi Gordo',
            finalidade: found.finalidade || 'Engorda Intensiva',
            piquete_id: found.piquete_id || ''
          });
        }
      } else if (listPiquetes.length > 0) {
        setForm((prev) => ({ ...prev, piquete_id: listPiquetes[0].id }));
      }
    }
    carregar();
  }, [loteId]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.nome.trim()) {
      alert('Informe o nome do lote.');
      return;
    }

    setLoading(true);
    try {
      const activeFazId = await getActiveFazendaId();
      const id = loteId || `lot-${Date.now()}`;
      const payload = {
        id,
        fazenda_id: activeFazId,
        nome: form.nome.trim(),
        especie: form.especie,
        categoria: form.categoria,
        finalidade: form.finalidade,
        piquete_id: form.piquete_id,
        sync_status: 'pending',
        updated_at: new Date().toISOString()
      };

      if (!loteId) {
        payload.created_at = new Date().toISOString();
        await db.lotes.add(payload);
        await queueSyncEvent('lotes', id, 'create', payload);
      } else {
        await db.lotes.update(id, payload);
        await queueSyncEvent('lotes', id, 'update', payload);
      }

      onSalvo(id);
    } catch (err) {
      console.error('Erro ao salvar lote:', err);
      alert('Erro ao salvar lote.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '560px', margin: '0 auto', minWidth: 0, width: '100%', overflowX: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
        <button onClick={onCancelar} className="btn btn-secondary btn-sm">
          <ArrowLeft size={16} />
        </button>
        <h2 style={{ fontSize: '20px' }}>{loteId ? 'Editar Lote' : 'Novo Lote de Animais'}</h2>
      </div>

      <div className="card">
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">Espécie Animal do Lote *</label>
            <select
              className="form-select"
              value={form.especie}
              onChange={(e) => setForm({ ...form, especie: e.target.value })}
              required
            >
              <option value="Bovino">🐄 Bovinos (Gado de Corte / Leite)</option>
              <option value="Ovino">🐑 Ovinos (Ovelhas / Carneiros)</option>
              <option value="Equino">🐴 Equinos (Cavalos / Éguas)</option>
              <option value="Búfalo">🦬 Búfalos (Bubalinos)</option>
              <option value="Caprino">🐐 Caprinos (Cabras / Bodes)</option>
              <option value="Outro">📦 Outra Espécie</option>
            </select>
          </div>

          <div className="form-group">
            <label className="form-label">Nome / Identificação do Lote *</label>
            <input
              type="text"
              className="form-input"
              value={form.nome}
              onChange={(e) => setForm({ ...form, nome: e.target.value })}
              placeholder="Ex: Lote 05 — Recria Piquete 02"
              required
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Categoria Padrão</label>
              <select
                className="form-select"
                value={form.categoria}
                onChange={(e) => setForm({ ...form, categoria: e.target.value })}
              >
                <option value="Bezerro(a)">Bezerro(a) / Cordeiro(a) / Potro(a)</option>
                <option value="Garrote / Borrego">Garrote / Borrego / Potranca</option>
                <option value="Novilha / Matriz">Novilha / Matriz</option>
                <option value="Boi Gordo / Engorda">Engorda / Terminação</option>
                <option value="Vaca Leiteira">Vaca Leiteira / Matriz Produção</option>
                <option value="Reprodutor">Reprodutor / Touro / Bode / Garanhão</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Finalidade</label>
              <select
                className="form-select"
                value={form.finalidade}
                onChange={(e) => setForm({ ...form, finalidade: e.target.value })}
              >
                <option value="Engorda Intensiva">Engorda Intensiva</option>
                <option value="Recria a Pasto">Recria a Pasto</option>
                <option value="Reprodução e IATF">Reprodução e IATF</option>
                <option value="Desmama e Adaptação">Desmama e Adaptação</option>
                <option value="Terminação Confinamento">Terminação Confinamento</option>
              </select>
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Piquete / Localização</label>
            <select
              className="form-select"
              value={form.piquete_id}
              onChange={(e) => setForm({ ...form, piquete_id: e.target.value })}
            >
              {piquetes.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.nome} ({p.tipo_pastagem})
                </option>
              ))}
            </select>
          </div>

          <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
            <button type="button" onClick={onCancelar} className="btn btn-secondary btn-block">
              Cancelar
            </button>
            <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
              <Save size={16} />
              <span>{loading ? 'Salvando...' : 'Salvar Lote'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

