import React, { useState, useEffect } from 'react';
import { ArrowLeft, Save, Scale, TrendingUp } from 'lucide-react';
import { db } from '../../db/database.js';
import { useAuth } from '../../contexts/AuthContext.jsx';
import { useSync } from '../../contexts/SyncContext.jsx';
import { calcularGMD, kgParaArroba } from '../../utils/gmdHelper.js';
import { formatarNumero } from '../../utils/formatters.js';
import { requireActiveFazendaId } from '../../utils/fazendaHelper.js';

export default function RegistroPesagem({ animalIdInicial, onSalvo, onCancelar }) {
  const { user } = useAuth();
  const { queueSyncEvent } = useSync();

  const [animais, setAnimais] = useState([]);
  const [especieSelecionada, setEspecieSelecionada] = useState('Bovino');
  const [animalSelecionado, setAnimalSelecionado] = useState(null);
  const [loading, setLoading] = useState(false);

  const [form, setForm] = useState({
    animal_id: animalIdInicial || '',
    data: new Date().toISOString().split('T')[0],
    peso: ''
  });

  useEffect(() => {
    async function carregarAnimais() {
      const list = await db.animais.filter((a) => a.status === 'ativo').toArray();
      setAnimais(list);

      if (animalIdInicial) {
        const found = list.find((a) => a.id === animalIdInicial);
        if (found) {
          const esp = found.especie || 'Bovino';
          setEspecieSelecionada(esp);
          setAnimalSelecionado(found);
          setForm((prev) => ({ ...prev, animal_id: found.id }));
          return;
        }
      }

      // Inicializa com primeira espécie com animais ou 'Bovino'
      const animaisBovino = list.filter((a) => (a.especie || 'Bovino') === 'Bovino');
      if (animaisBovino.length > 0) {
        setAnimalSelecionado(animaisBovino[0]);
        setForm((prev) => ({ ...prev, animal_id: animaisBovino[0].id }));
      } else if (list.length > 0) {
        setEspecieSelecionada(list[0].especie || 'Bovino');
        setAnimalSelecionado(list[0]);
        setForm((prev) => ({ ...prev, animal_id: list[0].id }));
      }
    }
    carregarAnimais();
  }, [animalIdInicial]);

  const handleEspecieChange = (novaEspecie) => {
    setEspecieSelecionada(novaEspecie);
    const disponiveis = animais.filter((a) => (a.especie || 'Bovino') === novaEspecie);
    if (disponiveis.length > 0) {
      setAnimalSelecionado(disponiveis[0]);
      setForm((prev) => ({ ...prev, animal_id: disponiveis[0].id }));
    } else {
      setAnimalSelecionado(null);
      setForm((prev) => ({ ...prev, animal_id: '' }));
    }
  };

  const handleAnimalChange = (e) => {
    const id = e.target.value;
    const found = animais.find((a) => a.id === id);
    setAnimalSelecionado(found);
    setForm({ ...form, animal_id: id });
  };

  const animaisDaEspecie = animais.filter((a) => (a.especie || 'Bovino') === especieSelecionada);
  const pesoNovoNum = parseFloat(form.peso) || 0;
  const gmdCalc = animalSelecionado && pesoNovoNum > 0
    ? calcularGMD(pesoNovoNum, animalSelecionado.peso_atual, form.data, animalSelecionado.data_ultima_pesagem)
    : { gmd: 0, diasDecorridos: 0, ganhoTotalKg: 0 };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.animal_id || !pesoNovoNum || pesoNovoNum <= 0) {
      alert('Selecione o animal e informe o peso aferido.');
      return;
    }

    setLoading(true);
    try {
      const activeFazId = await requireActiveFazendaId();
      const id = `pes-${Date.now()}`;
      const responsavel = user?.nome || 'Operador';

      const payload = {
        id,
        animal_id: form.animal_id,
        lote_id: animalSelecionado?.lote_id || '',
        fazenda_id: activeFazId,
        data: form.data,
        peso: pesoNovoNum,
        peso_anterior: animalSelecionado?.peso_atual || 0,
        dias_decorridos: gmdCalc.diasDecorridos,
        gmd: gmdCalc.gmd,
        responsavel,
        sync_status: 'pending',
        created_at: new Date().toISOString()
      };

      // 1. Gravar pesagem
      await db.pesagens.add(payload);
      await queueSyncEvent('pesagens', id, 'create', payload);

      // 2. Atualizar peso atual do animal
      await db.animais.update(animalSelecionado.id, {
        peso_atual: pesoNovoNum,
        data_ultima_pesagem: form.data,
        gmd_recente: gmdCalc.gmd > 0 ? gmdCalc.gmd : animalSelecionado.gmd_recente,
        updated_at: new Date().toISOString(),
        sync_status: 'pending'
      });
      const updatedAnimal = await db.animais.get(animalSelecionado.id);
      if (updatedAnimal) {
        await queueSyncEvent('animais', animalSelecionado.id, 'update', updatedAnimal);
      }

      alert(`✅ Pesagem registrada com sucesso! GMD: +${formatarNumero(gmdCalc.gmd, 2)} kg/dia.`);
      onSalvo();
    } catch (err) {
      console.error('Erro ao registrar pesagem:', err);
      alert(err.message || 'Erro ao registrar pesagem.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '580px', margin: '0 auto', width: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
        <button onClick={onCancelar} className="btn btn-secondary btn-sm">
          <ArrowLeft size={16} />
        </button>
        <h2 style={{ fontSize: '20px' }}>Registrar Pesagem do Animal</h2>
      </div>

      <div className="card">
        <form onSubmit={handleSubmit}>
          {/* Seleção de Espécie Animal para Pesagem */}
          <div className="form-group">
            <label className="form-label">Filtrar Animal por Espécie *</label>
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
            <label className="form-label">Animal ({especieSelecionada}) *</label>
            <select
              className="form-select"
              value={form.animal_id}
              onChange={handleAnimalChange}
              required
            >
              {animaisDaEspecie.length === 0 ? (
                <option value="">Nenhum animal da espécie {especieSelecionada} cadastrado</option>
              ) : (
                animaisDaEspecie.map((a) => (
                  <option key={a.id} value={a.id}>
                    Brinco {a.brinco} — {a.raca} ({a.categoria}, Peso Atual: {a.peso_atual} kg)
                  </option>
                ))
              )}
            </select>
            {animaisDaEspecie.length === 0 && (
              <span style={{ fontSize: '11px', color: '#ea580c', marginTop: '4px' }}>
                ⚠️ Nenhum animal cadastrado como {especieSelecionada}. Selecione outra espécie acima.
              </span>
            )}
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Data da Pesagem</label>
              <input
                type="date"
                className="form-input"
                value={form.data}
                onChange={(e) => setForm({ ...form, data: e.target.value })}
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Novo Peso Aferido (kg) *</label>
              <input
                type="number"
                step="0.1"
                inputMode="decimal"
                pattern="[0-9]*"
                className="form-input"
                value={form.peso}
                onChange={(e) => setForm({ ...form, peso: e.target.value })}
                placeholder="Ex: 535"
                required
                style={{ fontSize: '18px', fontWeight: 700, color: '#15803d' }}
              />
            </div>
          </div>

          {/* Cálculo em Tempo Real de GMD e Arrobas */}
          {pesoNovoNum > 0 && animalSelecionado && (
            <div
              style={{
                background: '#f0fdf4',
                border: '1px solid #86efac',
                borderRadius: '12px',
                padding: '16px',
                marginBottom: '20px'
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                <span style={{ fontSize: '13px', color: '#166534', fontWeight: 600 }}>Peso em Arrobas (@):</span>
                <span style={{ fontSize: '15px', fontWeight: 800, color: '#15803d' }}>
                  {kgParaArroba(pesoNovoNum)} @
                </span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                <span style={{ fontSize: '13px', color: '#166534', fontWeight: 600 }}>Ganho de Peso Total:</span>
                <span style={{ fontSize: '14px', fontWeight: 700, color: '#15803d' }}>
                  {gmdCalc.ganhoTotalKg > 0 ? `+${gmdCalc.ganhoTotalKg} kg` : `${gmdCalc.ganhoTotalKg} kg`} ({gmdCalc.diasDecorridos} dias)
                </span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'space-between', borderTop: '1px solid #bbf7d0', paddingTop: '8px' }}>
                <span style={{ fontSize: '14px', color: '#166534', fontWeight: 700 }}>Ganho Médio Diário (GMD):</span>
                <span style={{ fontSize: '16px', fontWeight: 800, color: '#15803d' }}>
                  +{formatarNumero(gmdCalc.gmd, 2)} kg/dia
                </span>
              </div>
            </div>
          )}

          <div style={{ display: 'flex', gap: '10px', marginTop: '10px' }}>
            <button type="button" onClick={onCancelar} className="btn btn-secondary btn-block">
              Cancelar
            </button>
            <button
              type="submit"
              className="btn btn-primary btn-block"
              disabled={loading || animaisDaEspecie.length === 0}
            >
              <Save size={16} />
              <span>{loading ? 'Salvando...' : 'Salvar Pesagem'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

