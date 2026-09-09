import React, { useState, useEffect } from 'react';
import { ArrowLeft, Save, AlertCircle } from 'lucide-react';
import { db } from '../../db/database.js';
import { useAuth } from '../../contexts/AuthContext.jsx';
import { useSync } from '../../contexts/SyncContext.jsx';
import CameraCapture from '../../components/CameraCapture.jsx';
import { getActiveFazendaId } from '../../utils/fazendaHelper.js';

export default function OcorrenciaForm({ onSalvo, onCancelar }) {
  const { user } = useAuth();
  const { queueSyncEvent } = useSync();

  const [animais, setAnimais] = useState([]);
  const [especieSelecionada, setEspecieSelecionada] = useState('Bovino');
  const [loading, setLoading] = useState(false);

  const [form, setForm] = useState({
    animal_id: '',
    tipo: 'Sintoma / Doença',
    gravidade: 'Média',
    sintoma: '',
    diagnostico: '',
    tratamento: '',
    data: new Date().toISOString().split('T')[0],
    foto: null
  });

  useEffect(() => {
    async function carregarAnimais() {
      const list = await db.animais.filter((a) => a.status === 'ativo').toArray();
      setAnimais(list);
      const bovinos = list.filter((a) => (a.especie || 'Bovino') === 'Bovino');
      if (bovinos.length > 0) {
        setForm((prev) => ({ ...prev, animal_id: bovinos[0].id }));
      } else if (list.length > 0) {
        setEspecieSelecionada(list[0].especie || 'Bovino');
        setForm((prev) => ({ ...prev, animal_id: list[0].id }));
      }
    }
    carregarAnimais();
  }, []);

  const handleEspecieChange = (novaEspecie) => {
    setEspecieSelecionada(novaEspecie);
    const disponiveis = animais.filter((a) => (a.especie || 'Bovino') === novaEspecie);
    setForm((prev) => ({
      ...prev,
      animal_id: disponiveis.length > 0 ? disponiveis[0].id : ''
    }));
  };

  const animaisDaEspecie = animais.filter((a) => (a.especie || 'Bovino') === especieSelecionada);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.animal_id || !form.sintoma.trim()) {
      alert('Selecione o animal e descreva o sintoma.');
      return;
    }

    setLoading(true);
    try {
      const activeFazId = await getActiveFazendaId();
      const id = `oco-${Date.now()}`;
      const animalObj = await db.animais.get(form.animal_id);

      const payload = {
        id,
        fazenda_id: activeFazId,
        animal_id: form.animal_id,
        lote_id: animalObj?.lote_id || '',
        tipo: form.tipo,
        gravidade: form.gravidade,
        sintoma: form.sintoma.trim(),
        diagnostico: form.diagnostico.trim(),
        tratamento: form.tratamento.trim(),
        data: form.data,
        responsavel: user?.nome || 'Operador',
        foto: form.foto,
        resolvido: false,
        sync_status: 'pending',
        created_at: new Date().toISOString()
      };

      await db.ocorrencias_sanitarias.add(payload);
      await queueSyncEvent('ocorrencias_sanitarias', id, 'create', payload);

      alert('Ocorrência sanitária registrada com sucesso!');
      onSalvo();
    } catch (err) {
      console.error('Erro ao registrar ocorrência:', err);
      alert('Erro ao registrar ocorrência.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '640px', margin: '0 auto', width: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
        <button onClick={onCancelar} className="btn btn-secondary btn-sm">
          <ArrowLeft size={16} />
        </button>
        <h2 style={{ fontSize: '20px' }}>Registrar Ocorrência Clínica / Sanitária</h2>
      </div>

      <div className="card">
        <form onSubmit={handleSubmit}>
          {/* Seleção de Espécie */}
          <div className="form-group">
            <label className="form-label">Filtrar por Espécie Animal *</label>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(100px, 1fr))', gap: '8px' }}>
              {[
                { id: 'Bovino', label: '🐄 Bovino' },
                { id: 'Ovino', label: '🐑 Ovino' },
                { id: 'Equino', label: '🐴 Equino' },
                { id: 'Búfalo', label: '🦬 Búfalo' },
                { id: 'Caprino', label: '🐐 Caprino' },
                { id: 'Outro', label: '📦 Outro' }
              ].map((item) => (
                <button
                  key={item.id}
                  type="button"
                  className={`btn ${especieSelecionada === item.id ? 'btn-primary' : 'btn-secondary'} btn-sm`}
                  onClick={() => handleEspecieChange(item.id)}
                  style={{ padding: '8px 6px', fontSize: '12px', fontWeight: 700 }}
                >
                  {item.label}
                </button>
              ))}
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Animal Acometido ({especieSelecionada}) *</label>
            <select
              className="form-select"
              value={form.animal_id}
              onChange={(e) => setForm({ ...form, animal_id: e.target.value })}
              required
            >
              {animaisDaEspecie.length === 0 ? (
                <option value="">Nenhum animal da espécie {especieSelecionada} cadastrado</option>
              ) : (
                animaisDaEspecie.map((a) => (
                  <option key={a.id} value={a.id}>
                    Brinco {a.brinco} — {a.raca} ({a.categoria})
                  </option>
                ))
              )}
            </select>
            {animaisDaEspecie.length === 0 && (
              <span style={{ fontSize: '11px', color: '#ea580c', marginTop: '4px' }}>
                ⚠️ Nenhum animal cadastrado como {especieSelecionada}.
              </span>
            )}
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Tipo de Ocorrência</label>
              <select
                className="form-select"
                value={form.tipo}
                onChange={(e) => setForm({ ...form, tipo: e.target.value })}
              >
                <option value="Sintoma / Doença">Sintoma / Doença</option>
                <option value="Lesão / Ferimento">Lesão / Ferimento</option>
                <option value="Claudicação / Casco">Claudicação / Casco</option>
                <option value="Tristeza Parasitária">Tristeza Parasitária</option>
                <option value="Óbito">Óbito / Mortalidade</option>
                <option value="Descarte Sanitário">Descarte Sanitário</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Gravidade</label>
              <select
                className="form-select"
                value={form.gravidade}
                onChange={(e) => setForm({ ...form, gravidade: e.target.value })}
              >
                <option value="Baixa">Baixa (Observação)</option>
                <option value="Média">Média (Requer Tratamento)</option>
                <option value="Alta">Alta (Urgência Veterinária)</option>
                <option value="Crítica">Crítica / Isolamento</option>
              </select>
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Sintomas / Ocorrência Observada *</label>
            <textarea
              className="form-textarea"
              rows="2"
              value={form.sintoma}
              onChange={(e) => setForm({ ...form, sintoma: e.target.value })}
              placeholder="Ex: Animal apático, isolado do lote, febre e secreção nasal..."
              required
            ></textarea>
          </div>

          <div className="form-group">
            <label className="form-label">Conduta / Tratamento Inicial</label>
            <textarea
              className="form-textarea"
              rows="2"
              value={form.tratamento}
              onChange={(e) => setForm({ ...form, tratamento: e.target.value })}
              placeholder="Ex: Isolado no piquete enfermaria, ministrado anti-inflamatório e hidratação..."
            ></textarea>
          </div>

          <CameraCapture
            foto={form.foto}
            onFotoChange={(fotoBase64) => setForm({ ...form, foto: fotoBase64 })}
            label="Foto da Lesão / Sintoma do Animal"
          />

          <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
            <button type="button" onClick={onCancelar} className="btn btn-secondary btn-block">
              Cancelar
            </button>
            <button
              type="submit"
              className="btn btn-primary btn-block"
              disabled={loading || animaisDaEspecie.length === 0}
            >
              <Save size={16} />
              <span>{loading ? 'Salvando...' : 'Salvar Ocorrência'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

