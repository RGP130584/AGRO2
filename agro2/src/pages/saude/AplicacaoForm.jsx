import React, { useState, useEffect } from 'react';
import { ArrowLeft, Save, AlertTriangle, ShieldCheck, HeartPulse, XCircle, PackageCheck, PackageX } from 'lucide-react';
import { db } from '../../db/database.js';
import { useAuth } from '../../contexts/AuthContext.jsx';
import { useSync } from '../../contexts/SyncContext.jsx';
import { calcularFimCarencia, statusCarencia } from '../../utils/carenciaHelper.js';
import { formatarData } from '../../utils/formatters.js';
import CameraCapture from '../../components/CameraCapture.jsx';
import { getActiveFazendaId } from '../../utils/fazendaHelper.js';

export default function AplicacaoForm({ animalIdInicial, onSalvo, onCancelar }) {
  const { user } = useAuth();
  const { queueSyncEvent } = useSync();

  const [tipoAlvo, setTipoAlvo] = useState(animalIdInicial ? 'individual' : 'lote'); // 'individual' | 'lote'
  const [animais, setAnimais] = useState([]);
  const [lotes, setLotes] = useState([]);
  const [produtos, setProdutos] = useState([]);
  const [loading, setLoading] = useState(false);
  const [carenciaAtivaAlerta, setCarenciaAtivaAlerta] = useState(null);
  const [qtdCabecasCalculada, setQtdCabecasCalculada] = useState(0);

  const [form, setForm] = useState({
    animal_id: animalIdInicial || '',
    lote_id: '',
    produto_id: '',
    data_aplicacao: new Date().toISOString().split('T')[0],
    dose: '5 ml',
    via: 'Subcutânea',
    motivo: '',
    foto: null
  });

  const [produtoSelecionado, setProdutoSelecionado] = useState(null);

  useEffect(() => {
    async function carregarDados() {
      const [listAnimais, listLotes, listProdutos] = await Promise.all([
        db.animais.filter((a) => a.status === 'ativo').toArray(),
        db.lotes.toArray(),
        db.produtos.filter((p) => ['medicamento', 'vacina'].includes(p.tipo)).toArray()
      ]);

      setAnimais(listAnimais);
      setLotes(listLotes);
      setProdutos(listProdutos);

      if (listProdutos.length > 0) {
        setForm((prev) => ({ ...prev, produto_id: listProdutos[0].id }));
        setProdutoSelecionado(listProdutos[0]);
      }

      if (listLotes.length > 0 && !animalIdInicial) {
        setForm((prev) => ({ ...prev, lote_id: listLotes[0].id }));
      }
    }
    carregarDados();
  }, [animalIdInicial]);

  // Efeito rigoroso para checar se o animal/lote JÁ possui vacinação/medicamento com carência ativa
  useEffect(() => {
    async function checarCarenciaEContagem() {
      const hojeStr = new Date().toISOString().split('T')[0];
      let alvos = [];

      if (tipoAlvo === 'individual' && form.animal_id) {
        const a = await db.animais.get(form.animal_id);
        if (a) alvos = [a];
      } else if (tipoAlvo === 'lote' && form.lote_id) {
        alvos = await db.animais.where('lote_id').equals(form.lote_id).toArray();
      }

      setQtdCabecasCalculada(alvos.length);

      if (alvos.length === 0) {
        setCarenciaAtivaAlerta(null);
        return;
      }

      let animaisEmCarencia = [];
      for (const a of alvos) {
        if (a.carencia_fim && a.carencia_fim >= hojeStr) {
          // Busca detalhes da última aplicação registrada para esse animal
          const aplicacoes = await db.aplicacoes_sanitarias
            .where('animal_id')
            .equals(a.id)
            .toArray();

          aplicacoes.sort((x, y) => new Date(y.created_at || y.data_aplicacao) - new Date(x.created_at || x.data_aplicacao));
          const ultApl = aplicacoes.find((apl) => apl.carencia_fim && apl.carencia_fim >= hojeStr) || aplicacoes[0];

          animaisEmCarencia.push({
            brinco: a.brinco,
            produtoNome: ultApl?.produto_nome || a.ultima_aplicacao_nome || 'Vacina / Medicamento',
            dataAplicacao: ultApl?.data_aplicacao || 'Data Recente',
            carenciaFim: a.carencia_fim
          });
        }
      }

      if (animaisEmCarencia.length > 0) {
        setCarenciaAtivaAlerta(animaisEmCarencia);
      } else {
        setCarenciaAtivaAlerta(null);
      }
    }

    checarCarenciaEContagem();
  }, [form.animal_id, form.lote_id, form.produto_id, tipoAlvo]);

  const handleProdutoChange = (prodId) => {
    const p = produtos.find((item) => item.id === prodId);
    setProdutoSelecionado(p);
    setForm({ ...form, produto_id: prodId });
  };

  const carenciaCalculada = produtoSelecionado
    ? calcularFimCarencia(form.data_aplicacao, produtoSelecionado.carencia_dias)
    : null;

  const saldoAtualEstoque = produtoSelecionado?.saldo_atual ?? 0;
  const estoqueInsuficiente = qtdCabecasCalculada > 0 && saldoAtualEstoque < qtdCabecasCalculada;

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (carenciaAtivaAlerta && carenciaAtivaAlerta.length > 0) {
      const lista = carenciaAtivaAlerta.map(a => `• Brinco ${a.brinco}: ${a.produtoNome} (Carência até ${formatarData(a.carenciaFim)})`).join('\n');
      alert(`❌ APLICAÇÃO BLOQUEADA!\n\nExiste(m) animal(is) com vacinação/medicamento recente em período de carência ativa:\n\n${lista}\n\nNão é permitido aplicar vacinas ou remédios enquanto a carência vigente não for concluída.`);
      return;
    }

    if (!form.produto_id) {
      alert('Selecione um produto/medicamento.');
      return;
    }

    if (tipoAlvo === 'individual' && !form.animal_id) {
      alert('Selecione o animal.');
      return;
    }

    if (tipoAlvo === 'lote' && !form.lote_id) {
      alert('Selecione o lote.');
      return;
    }

    if (estoqueInsuficiente) {
      alert(`❌ ESTOQUE INSUFICIENTE!\n\nSaldo atual no estoque: ${saldoAtualEstoque} ${produtoSelecionado?.unidade || 'doses'}.\nNecessário para aplicação: ${qtdCabecasCalculada} ${produtoSelecionado?.unidade || 'doses'}.\n\nAtualize o estoque do insumo antes de confirmar.`);
      return;
    }

    setLoading(true);
    try {
      const responsavel = user?.nome || 'Operador Agro';
      const produtoNome = produtoSelecionado?.nome || 'Medicamento';

      let animaisAlvos = [];
      if (tipoAlvo === 'individual') {
        const a = await db.animais.get(form.animal_id);
        if (a) animaisAlvos = [a];
      } else {
        animaisAlvos = await db.animais.where('lote_id').equals(form.lote_id).toArray();
      }

      if (animaisAlvos.length === 0) {
        alert('Nenhum animal encontrado para esta aplicação.');
        setLoading(false);
        return;
      }
      
      const activeFazId = await getActiveFazendaId();

      // 1. Criar registro de aplicação para cada animal
      for (const animal of animaisAlvos) {
        const aplicacaoId = `apl-${Date.now()}-${Math.random().toString(36).substr(2, 6)}`;
        const payloadApl = {
          id: aplicacaoId,
          animal_id: animal.id,
          lote_id: animal.lote_id,
          fazenda_id: activeFazId,
          produto_id: form.produto_id,
          produto_nome: produtoNome,
          data_aplicacao: form.data_aplicacao,
          carencia_fim: carenciaCalculada,
          dose: form.dose,
          via: form.via,
          motivo: form.motivo,
          responsavel,
          foto: form.foto,
          sync_status: 'pending',
          created_at: new Date().toISOString()
        };

        await db.aplicacoes_sanitarias.add(payloadApl);
        await queueSyncEvent('aplicacoes_sanitarias', aplicacaoId, 'create', payloadApl);

        // Atualizar carência e nome da última vacina/medicação aplicada no cadastro do animal
        const updateData = {
          ultima_aplicacao_nome: produtoNome,
          data_ultima_aplicacao: form.data_aplicacao,
          updated_at: new Date().toISOString(),
          sync_status: 'pending'
        };

        if (carenciaCalculada) {
          if (!animal.carencia_fim || carenciaCalculada > animal.carencia_fim) {
            updateData.carencia_fim = carenciaCalculada;
          }
        }

        await db.animais.update(animal.id, updateData);
        const updatedAnimal = await db.animais.get(animal.id);
        if (updatedAnimal) {
          await queueSyncEvent('animais', animal.id, 'update', updatedAnimal);
        }
      }

      // 2. Baixa atômica no estoque do produto
      if (produtoSelecionado) {
        const novoSaldo = Math.max(0, produtoSelecionado.saldo_atual - animaisAlvos.length);
        await db.produtos.update(produtoSelecionado.id, {
          saldo_atual: novoSaldo,
          sync_status: 'pending'
        });
        await queueSyncEvent('produtos', produtoSelecionado.id, 'update', { ...produtoSelecionado, saldo_atual: novoSaldo });

        // Registrar movimento oficial de saída de estoque
        const movId = `mov-${Date.now()}`;
        const payloadMov = {
          id: movId,
          fazenda_id: activeFazId,
          produto_id: produtoSelecionado.id,
          tipo: 'saida',
          quantidade: animaisAlvos.length,
          data: form.data_aplicacao,
          motivo: `Aplicação Sanitária (${animaisAlvos.length} cabeças - ${produtoNome})`,
          referencia_id: form.lote_id || form.animal_id,
          responsavel,
          sync_status: 'pending',
          created_at: new Date().toISOString()
        };
        await db.estoque_movimentos.add(payloadMov);
        await queueSyncEvent('estoque_movimentos', movId, 'create', payloadMov);
      }

      alert(`✅ Aplicação registrada com sucesso! Baixa de ${animaisAlvos.length} ${produtoSelecionado?.unidade || 'dose(s)'} efetuada no estoque.`);
      onSalvo();
    } catch (err) {
      console.error('Erro ao registrar aplicação:', err);
      alert('Erro ao registrar aplicação sanitária.');
    } finally {
      setLoading(false);
    }
  };

  const hojeStr = new Date().toISOString().split('T')[0];

  return (
    <div style={{ maxWidth: '640px', margin: '0 auto' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '20px' }}>
        <button onClick={onCancelar} className="btn btn-secondary btn-sm">
          <ArrowLeft size={16} />
        </button>
        <h2 style={{ fontSize: '20px' }}>Registrar Aplicação Sanitária</h2>
      </div>

      <div className="card">
        <form onSubmit={handleSubmit}>
          {/* Tipo de Alvo: Individual ou Lote */}
          <div className="form-group">
            <label className="form-label">Aplicar em:</label>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
              <button
                type="button"
                className={`btn ${tipoAlvo === 'individual' ? 'btn-primary' : 'btn-secondary'}`}
                onClick={() => setTipoAlvo('individual')}
              >
                Animal Individual
              </button>
              <button
                type="button"
                className={`btn ${tipoAlvo === 'lote' ? 'btn-primary' : 'btn-secondary'}`}
                onClick={() => setTipoAlvo('lote')}
              >
                Lote Inteiro
              </button>
            </div>
          </div>

          {tipoAlvo === 'individual' ? (
            <div className="form-group">
              <label className="form-label">Selecionar Animal (Brinco / Raça) *</label>
              <select
                className="form-select"
                value={form.animal_id}
                onChange={(e) => setForm({ ...form, animal_id: e.target.value })}
                required
              >
                <option value="">Selecione o animal...</option>
                {animais.map((a) => {
                  const emCarencia = a.carencia_fim && a.carencia_fim >= hojeStr;
                  return (
                    <option key={a.id} value={a.id} disabled={emCarencia}>
                      {a.brinco} — {a.raca} ({a.categoria}, {a.peso_atual} kg) {emCarencia ? `🚫 BLOQUEADO (Carência até ${formatarData(a.carencia_fim)})` : ''}
                    </option>
                  );
                })}
              </select>
            </div>
          ) : (
            <div className="form-group">
              <label className="form-label">Selecionar Lote *</label>
              <select
                className="form-select"
                value={form.lote_id}
                onChange={(e) => setForm({ ...form, lote_id: e.target.value })}
                required
              >
                <option value="">Selecione o lote...</option>
                {lotes.map((l) => {
                  const animaisDoLote = animais.filter((a) => a.lote_id === l.id);
                  const emCarenciaCount = animaisDoLote.filter((a) => a.carencia_fim && a.carencia_fim >= hojeStr).length;
                  const loteBloqueado = animaisDoLote.length > 0 && emCarenciaCount > 0;
                  return (
                    <option key={l.id} value={l.id} disabled={loteBloqueado}>
                      {l.nome} ({l.categoria}) {loteBloqueado ? `🚫 BLOQUEADO: ${emCarenciaCount} animal(is) em carência` : ''}
                    </option>
                  );
                })}
              </select>
            </div>
          )}

          <div className="form-group">
            <label className="form-label">Medicamento / Vacina *</label>
            <select
              className="form-select"
              value={form.produto_id}
              onChange={(e) => handleProdutoChange(e.target.value)}
              required
            >
              {produtos.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.nome} (Carência: {p.carencia_dias} dias | Saldo Atual: {p.saldo_atual} {p.unidade})
                </option>
              ))}
            </select>
          </div>

          {/* PAINEL DE BLOQUEIO RIGOROSO QUANDO ANIMAL ESTÁ EM CARÊNCIA ATIVA */}
          {carenciaAtivaAlerta && (
            <div style={{
              backgroundColor: '#fef2f2',
              border: '2px solid #ef4444',
              borderRadius: '12px',
              padding: '16px',
              marginBottom: '16px',
              color: '#991b1b'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontWeight: 800, fontSize: '15px', marginBottom: '6px' }}>
                <XCircle size={22} color="#dc2626" />
                <span>APLICAÇÃO BLOQUEADA: Animal em Período de Carência Ativa</span>
              </div>
              <div style={{ fontSize: '13px', lineHeight: '1.5' }}>
                O(s) animal(is) selecionado(s) já possui(em) vacinação/medicamento aplicado e está(ão) em <strong>período de retenção sanitária</strong>:
              </div>
              <ul style={{ marginTop: '8px', paddingLeft: '20px', fontSize: '13px', fontWeight: 700 }}>
                {carenciaAtivaAlerta.map((a, idx) => (
                  <li key={idx} style={{ marginBottom: '4px' }}>
                    Brinco <strong>{a.brinco}</strong> — Aplicado: <em>{a.produtoNome}</em> (Carência ativa até <strong>{a.carenciaFim.split('-').reverse().join('/')}</strong>)
                  </li>
                ))}
              </ul>
              <div style={{ fontSize: '12px', marginTop: '10px', color: '#7f1d1d', fontWeight: 600, fontStyle: 'italic', backgroundColor: '#fee2e2', padding: '8px 12px', borderRadius: '6px' }}>
                ⚠️ Não é permitido registrar novas aplicações sanitárias em animais em período de carência vigente.
              </div>
            </div>
          )}

          {/* PAINEL DE CONTROLE DE ESTOQUE EM TEMPO REAL */}
          {!carenciaAtivaAlerta && produtoSelecionado && qtdCabecasCalculada > 0 && (
            <div
              style={{
                backgroundColor: estoqueInsuficiente ? '#fef2f2' : '#f0fdf4',
                border: `1px solid ${estoqueInsuficiente ? '#fca5a5' : '#86efac'}`,
                borderRadius: '12px',
                padding: '12px 16px',
                marginBottom: '16px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                fontSize: '13px'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                {estoqueInsuficiente ? (
                  <PackageX size={20} color="#dc2626" />
                ) : (
                  <PackageCheck size={20} color="#16a34a" />
                )}
                <div>
                  <div style={{ fontWeight: 700, color: estoqueInsuficiente ? '#991b1b' : '#166534' }}>
                    {estoqueInsuficiente ? '❌ Estoque Insuficiente' : '📦 Controle de Estoque Vinculado'}
                  </div>
                  <div style={{ color: estoqueInsuficiente ? '#b91c1c' : '#15803d' }}>
                    Saldo Atual: <strong>{saldoAtualEstoque} {produtoSelecionado.unidade}</strong> | Baixa Prevista: <strong>-{qtdCabecasCalculada} {produtoSelecionado.unidade}</strong>
                  </div>
                </div>
              </div>

              <div style={{ textAlign: 'right', fontWeight: 800, fontSize: '14px', color: estoqueInsuficiente ? '#dc2626' : '#16a34a' }}>
                Restante: {saldoAtualEstoque - qtdCabecasCalculada} {produtoSelecionado.unidade}
              </div>
            </div>
          )}

          {/* Destaque Visual de Carência Calculada (Quando liberado) */}
          {!carenciaAtivaAlerta && (
            <div
              style={{
                background: produtoSelecionado?.carencia_dias > 0 ? '#fff5f5' : '#f0fdf4',
                border: `1px solid ${produtoSelecionado?.carencia_dias > 0 ? '#fca5a5' : '#86efac'}`,
                borderRadius: '12px',
                padding: '14px',
                marginBottom: '16px',
                display: 'flex',
                alignItems: 'center',
                gap: '12px'
              }}
            >
              {produtoSelecionado?.carencia_dias > 0 ? (
                <AlertTriangle size={24} color="#dc2626" />
              ) : (
                <ShieldCheck size={24} color="#16a34a" />
              )}
              <div>
                <div style={{ fontWeight: 700, fontSize: '14px', color: produtoSelecionado?.carencia_dias > 0 ? '#991b1b' : '#166534' }}>
                  {produtoSelecionado?.carencia_dias > 0
                    ? `Período de Carência Previsto: ${produtoSelecionado.carencia_dias} dias`
                    : 'Carência Zero — Sem restrição de abate'}
                </div>
                {carenciaCalculada && (
                  <div style={{ fontSize: '13px', color: '#b91c1c' }}>
                    Liberado para abate a partir de: <strong>{carenciaCalculada.split('-').reverse().join('/')}</strong>
                  </div>
                )}
              </div>
            </div>
          )}

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Data da Aplicação</label>
              <input
                type="date"
                className="form-input"
                value={form.data_aplicacao}
                onChange={(e) => setForm({ ...form, data_aplicacao: e.target.value })}
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Dose por Cabeça</label>
              <input
                type="text"
                className="form-input"
                value={form.dose}
                onChange={(e) => setForm({ ...form, dose: e.target.value })}
                placeholder="Ex: 5 ml ou 1 frasco"
                required
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Via de Aplicação</label>
              <select
                className="form-select"
                value={form.via}
                onChange={(e) => setForm({ ...form, via: e.target.value })}
              >
                <option value="Subcutânea">Subcutânea (SC)</option>
                <option value="Intramuscular">Intramuscular (IM)</option>
                <option value="Intravenosa">Intravenosa (IV)</option>
                <option value="Oral">Oral</option>
                <option value="Pour-on">Pour-on (Dorsal)</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Motivo / Diagnóstico</label>
              <input
                type="text"
                className="form-input"
                value={form.motivo}
                onChange={(e) => setForm({ ...form, motivo: e.target.value })}
                placeholder="Ex: Prevenção Aftosa / Tristeza Parasitária"
              />
            </div>
          </div>

          <CameraCapture
            foto={form.foto}
            onFotoChange={(fotoBase64) => setForm({ ...form, foto: fotoBase64 })}
            label="Foto do Frasco / Lote / Aplicação"
          />

          <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
            <button type="button" onClick={onCancelar} className="btn btn-secondary btn-block">
              Cancelar
            </button>
            <button
              type="submit"
              className="btn btn-primary btn-block"
              disabled={loading || !!carenciaAtivaAlerta || estoqueInsuficiente}
              style={{
                opacity: (carenciaAtivaAlerta || estoqueInsuficiente) ? 0.6 : 1,
                cursor: (carenciaAtivaAlerta || estoqueInsuficiente) ? 'not-allowed' : 'pointer'
              }}
            >
              <Save size={16} />
              <span>{loading ? 'Processando Aplicação...' : 'Confirmar Aplicação'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
