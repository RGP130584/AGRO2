import React, { useState, useEffect } from 'react';
import { ArrowLeft, Save, Plus, Edit3 } from 'lucide-react';
import { db } from '../../db/database.js';
import { useSync } from '../../contexts/SyncContext.jsx';
import CameraCapture from '../../components/CameraCapture.jsx';
import { requireActiveFazendaId } from '../../utils/fazendaHelper.js';

const RACAS_SUGERIDAS = {
  Bovino: ['Nelore', 'Nelore Mocho', 'Nelore P.O.', 'Angus', 'Cruzamento Angus/Nelore', 'Senepol', 'Brahman', 'Girolando', 'Gir Leiteiro', 'Holandês', 'Brangus', 'Wagyu', 'Outra'],
  Ovino: ['Dorper', 'Santa Inês', 'Texel', 'Hampshire Down', 'Suffolk', 'Morada Nova', 'Ile de France', 'Outra'],
  Equino: ['Mangalarga Marchador', 'Crioulo', 'Quarto de Milha', 'Campolina', 'Appaloosa', 'Pampa', 'Outra'],
  Búfalo: ['Murrah', 'Jafarabadi', 'Carabao', 'Mediterrâneo', 'Outra'],
  Caprino: ['Anglo Nubiana', 'Boer', 'Saanen', 'Toggenburg', 'Outra'],
  Outro: ['Misto', 'SRD (Sem Raça Definida)', 'Outra']
};

const CATEGORIAS_SUGERIDAS = {
  Bovino: ['Bezerro(a)', 'Garrote', 'Novilha', 'Boi Gordo', 'Vaca Leiteira', 'Vaca Solteira', 'Touro Reprodutor'],
  Ovino: ['Cordeiro(a)', 'Borrego(a)', 'Matriz', 'Reprodutor (Carneiro)'],
  Equino: ['Potro(a)', 'Potranca', 'Égua', 'Garanhão', 'Cavalo de Lida'],
  Búfalo: ['Bezerro(a) Bubalino', 'Garrote Bubalino', 'Búfala Leiteira', 'Búfalo Engorda', 'Búfalo Reprodutor'],
  Caprino: ['Cabrito(a)', 'Matriz (Cabra)', 'Bode Reprodutor'],
  Outro: ['Jovem / Crub', 'Adulto / Manejo', 'Reprodutor']
};

export default function AnimalForm({ animalId, onSalvo, onCancelar }) {
  const { queueSyncEvent } = useSync();
  const [lotes, setLotes] = useState([]);
  const [loading, setLoading] = useState(false);

  const [form, setForm] = useState({
    brinco: '',
    rfid: '',
    especie: 'Bovino',
    raca: 'Nelore',
    raca_custom: '',
    categoria: 'Boi Gordo',
    sexo: 'Macho',
    data_nascimento: '',
    peso_atual: '',
    lote_id: '',
    foto: null
  });

  const [isCustomRaca, setIsCustomRaca] = useState(false);

  useEffect(() => {
    async function carregar() {
      const listLotes = await db.lotes.toArray();
      setLotes(listLotes);

      if (animalId) {
        const found = await db.animais.get(animalId);
        if (found) {
          const esp = found.especie || 'Bovino';
          const racasPredefinidas = RACAS_SUGERIDAS[esp] || RACAS_SUGERIDAS.Bovino;
          const eCustom = found.raca && !racasPredefinidas.includes(found.raca);

          setForm({
            brinco: found.brinco || '',
            rfid: found.rfid || '',
            especie: esp,
            raca: eCustom ? 'Outra' : (found.raca || 'Nelore'),
            raca_custom: eCustom ? found.raca : '',
            categoria: found.categoria || 'Boi Gordo',
            sexo: found.sexo || 'Macho',
            data_nascimento: found.data_nascimento || '',
            peso_atual: found.peso_atual ? String(found.peso_atual) : '',
            lote_id: found.lote_id || '',
            foto: found.foto || null
          });
          setIsCustomRaca(eCustom);
        }
      } else if (listLotes.length > 0) {
        setForm((prev) => ({ ...prev, lote_id: listLotes[0].id }));
      }
    }
    carregar();
  }, [animalId]);

  const handleEspecieChange = (novaEspecie) => {
    const racasDisponiveis = RACAS_SUGERIDAS[novaEspecie] || RACAS_SUGERIDAS.Outro;
    const categoriasDisponiveis = CATEGORIAS_SUGERIDAS[novaEspecie] || CATEGORIAS_SUGERIDAS.Outro;
    const lotesFiltrados = lotes.filter((l) => !l.especie || l.especie === novaEspecie);

    setForm((prev) => ({
      ...prev,
      especie: novaEspecie,
      raca: racasDisponiveis[0],
      raca_custom: '',
      categoria: categoriasDisponiveis[0],
      lote_id: lotesFiltrados.length > 0 ? lotesFiltrados[0].id : ''
    }));
    setIsCustomRaca(false);
  };

  const handleRacaChange = (novaRaca) => {
    if (novaRaca === 'Outra') {
      setIsCustomRaca(true);
      setForm((prev) => ({ ...prev, raca: 'Outra' }));
    } else {
      setIsCustomRaca(false);
      setForm((prev) => ({ ...prev, raca: novaRaca, raca_custom: '' }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.brinco.trim()) {
      alert('Informe o número do brinco / identificador do animal.');
      return;
    }

    const racaFinal = isCustomRaca ? (form.raca_custom.trim() || 'Outra') : form.raca;

    setLoading(true);
    try {
      const activeFazId = await requireActiveFazendaId();
      const id = animalId || `ani-${Date.now()}`;
      const payload = {
        id,
        fazenda_id: activeFazId,
        lote_id: form.lote_id || null,
        brinco: form.brinco.trim().toUpperCase(),
        rfid: form.rfid.trim() || null,
        especie: form.especie,
        raca: racaFinal,
        categoria: form.categoria,
        sexo: form.sexo,
        data_nascimento: form.data_nascimento || null,
        peso_atual: form.peso_atual ? parseFloat(form.peso_atual) : 0,
        foto: form.foto || null,
        status: 'ativo',
        sync_status: 'pending',
        updated_at: new Date().toISOString()
      };

      if (!animalId) {
        payload.created_at = new Date().toISOString();
      }

      await db.animais.put(payload);
      await queueSyncEvent('animais', id, animalId ? 'update' : 'create', payload);

      alert(`Animal ${form.brinco} ${animalId ? 'atualizado' : 'cadastrado'} com sucesso!`);
      onSalvo();
    } catch (err) {
      console.error('Erro ao salvar animal:', err);
      alert(err.message || 'Erro ao salvar animal.');
    } finally {
      setLoading(false);
    }
  };

  const listaRacas = RACAS_SUGERIDAS[form.especie] || RACAS_SUGERIDAS.Outro;
  const listaCategorias = CATEGORIAS_SUGERIDAS[form.especie] || CATEGORIAS_SUGERIDAS.Outro;
  const lotesDaEspecie = lotes.filter((l) => !l.especie || l.especie === form.especie);

  return (
    <div style={{ maxWidth: '600px', margin: '0 auto', width: '100%', minWidth: 0, overflowX: 'hidden' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
        <button onClick={onCancelar} className="btn btn-secondary btn-sm">
          <ArrowLeft size={16} />
        </button>
        <h2 style={{ fontSize: '20px' }}>{animalId ? 'Editar Animal' : 'Novo Animal no Rebanho'}</h2>
      </div>

      <div className="card">
        <form onSubmit={handleSubmit}>
          {/* Seleção Primária de Espécie */}
          <div className="form-group">
            <label className="form-label">Espécie Animal *</label>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(110px, 1fr))', gap: '8px' }}>
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
                  className={`btn ${form.especie === item.id ? 'btn-primary' : 'btn-secondary'} btn-sm`}
                  onClick={() => handleEspecieChange(item.id)}
                  style={{ padding: '8px 10px', fontSize: '13px' }}
                >
                  {item.label}
                </button>
              ))}
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Brinco / Identificação Visual *</label>
              <input
                type="text"
                className="form-input"
                value={form.brinco}
                onChange={(e) => setForm({ ...form, brinco: e.target.value.toUpperCase() })}
                placeholder="Ex: BR-1002"
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Microchip / Eletrônico (RFID)</label>
              <input
                type="text"
                className="form-input"
                value={form.rfid}
                onChange={(e) => setForm({ ...form, rfid: e.target.value })}
                placeholder="Ex: 982000412389101"
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Raça ({form.especie}) *</label>
              <select
                className="form-select"
                value={form.raca}
                onChange={(e) => handleRacaChange(e.target.value)}
                required
              >
                {listaRacas.map((r) => (
                  <option key={r} value={r}>{r}</option>
                ))}
              </select>

              {isCustomRaca && (
                <div style={{ marginTop: '8px' }}>
                  <input
                    type="text"
                    className="form-input"
                    value={form.raca_custom}
                    onChange={(e) => setForm({ ...form, raca_custom: e.target.value })}
                    placeholder={`Digite o nome da raça de ${form.especie}...`}
                    required
                  />
                  <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                    💡 A nova raça será cadastrada no seu acervo local.
                  </span>
                </div>
              )}
            </div>

            <div className="form-group">
              <label className="form-label">Lote de Destino ({form.especie})</label>
              <select
                className="form-select"
                value={form.lote_id}
                onChange={(e) => setForm({ ...form, lote_id: e.target.value })}
              >
                <option value="">Sem Lote Atribuído</option>
                {lotesDaEspecie.map((l) => (
                  <option key={l.id} value={l.id}>{l.nome}</option>
                ))}
              </select>
              {lotesDaEspecie.length === 0 && (
                <span style={{ fontSize: '11px', color: '#ea580c', marginTop: '4px' }}>
                  ⚠️ Nenhum lote exclusivo de {form.especie} cadastrado.
                </span>
              )}
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Categoria</label>
              <select
                className="form-select"
                value={form.categoria}
                onChange={(e) => setForm({ ...form, categoria: e.target.value })}
              >
                {listaCategorias.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Sexo</label>
              <select
                className="form-select"
                value={form.sexo}
                onChange={(e) => setForm({ ...form, sexo: e.target.value })}
              >
                <option value="Macho">Macho</option>
                <option value="Fêmea">Fêmea</option>
              </select>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Data de Nascimento</label>
              <input
                type="date"
                className="form-input"
                value={form.data_nascimento}
                onChange={(e) => setForm({ ...form, data_nascimento: e.target.value })}
              />
            </div>

            <div className="form-group">
              <label className="form-label">Peso Inicial / Atual (kg)</label>
              <input
                type="number"
                step="0.1"
                inputMode="decimal"
                pattern="[0-9]*"
                className="form-input"
                value={form.peso_atual}
                onChange={(e) => setForm({ ...form, peso_atual: e.target.value })}
                placeholder="Ex: 480"
              />
            </div>
          </div>

          <CameraCapture
            foto={form.foto}
            onFotoChange={(fotoBase64) => setForm({ ...form, foto: fotoBase64 })}
            label="Foto do Animal / Identificador"
          />

          <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
            <button type="button" onClick={onCancelar} className="btn btn-secondary btn-block">
              Cancelar
            </button>
            <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
              <Save size={16} />
              <span>{loading ? 'Salvando...' : 'Salvar Animal'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
