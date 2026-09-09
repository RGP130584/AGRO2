import React, { useState, useEffect } from 'react';
import { Users, Plus, Shield, Stethoscope, UserCheck, Phone, Mail, Trash2, Save, Check, X } from 'lucide-react';
import { db } from '../../db/database.js';
import { useSync } from '../../contexts/SyncContext.jsx';
import { useAuth } from '../../contexts/AuthContext.jsx';
import { getRolePermissions, saveRolePermissions } from '../../utils/permissionHelper.js';

const MODULOS_CONFIG = [
  { id: 'rebanho', label: 'Cadastro de Rebanho & Lotes' },
  { id: 'pesagem', label: 'Pesagens & Cálculo de GMD' },
  { id: 'saude', label: 'Saúde (Vacinas / Medicamentos)' },
  { id: 'nutricao', label: 'Trato Diário & Dietas' },
  { id: 'estoque', label: 'Controle de Estoque & Insumos' },
  { id: 'financeiro', label: 'Módulo Financeiro (Contas / DRE)' },
  { id: 'relatorios', label: 'Relatórios & Emissão de GTA' },
  { id: 'equipe', label: 'Gestão de Equipe & Permissões' },
  { id: 'sync', label: 'Sincronização & Admin Server' },
];

export default function EquipeList() {
  const { user: usuarioLogado } = useAuth();
  const { queueSyncEvent } = useSync();
  const [usuarios, setUsuarios] = useState([]);
  const [loading, setLoading] = useState(true);
  const [modalNovo, setModalNovo] = useState(false);
  const [abaAtiva, setAbaAtiva] = useState('membros'); // 'membros' | 'permissoes'

  const [permissions, setPermissions] = useState(getRolePermissions());
  const [permSavedNotice, setPermSavedNotice] = useState(false);

  const [form, setForm] = useState({
    nome: '',
    email: '',
    senha: '123',
    perfil: 'colaborador',
    telefone: '',
    crmv: ''
  });

  useEffect(() => {
    carregarEquipe();
  }, []);

  async function carregarEquipe() {
    try {
      const list = await db.usuarios.filter((u) => u.ativo !== false).toArray();
      setUsuarios(list);
    } catch (e) {
      console.error('Erro ao carregar equipe:', e);
    } finally {
      setLoading(false);
    }
  }

  const handleSalvarMembro = async (e) => {
    e.preventDefault();
    if (!form.nome.trim() || !form.email.trim()) {
      alert('Nome e e-mail são obrigatórios.');
      return;
    }

    try {
      const id = `usr-${Date.now()}`;
      const payload = {
        id,
        nome: form.nome.trim(),
        email: form.email.trim().toLowerCase(),
        senha: form.senha || '123',
        perfil: form.perfil,
        telefone: form.telefone.trim(),
        crmv: form.crmv.trim(),
        ativo: true,
        created_at: new Date().toISOString()
      };

      await db.usuarios.add(payload);
      await queueSyncEvent('usuarios', id, 'create', payload);

      setModalNovo(false);
      setForm({ nome: '', email: '', senha: '123', perfil: 'colaborador', telefone: '', crmv: '' });
      await carregarEquipe();
      alert('Membro da equipe cadastrado com sucesso!');
    } catch (err) {
      console.error('Erro ao cadastrar usuário:', err);
      alert('Erro ao cadastrar membro da equipe.');
    }
  };

  const handleRemoverMembro = async (usuarioId, nome) => {
    if (usuarioLogado && usuarioLogado.id === usuarioId) {
      alert('Você não pode remover seu próprio usuário logado.');
      return;
    }

    if (!window.confirm(`Tem certeza que deseja remover ${nome} da equipe?`)) {
      return;
    }

    try {
      await db.usuarios.update(usuarioId, { ativo: false });
      await queueSyncEvent('usuarios', usuarioId, 'delete', { id: usuarioId, ativo: false });
      await carregarEquipe();
      alert('Membro removido com sucesso!');
    } catch (err) {
      console.error('Erro ao remover usuário:', err);
      alert('Erro ao remover usuário.');
    }
  };

  const togglePermission = (perfil, moduloId) => {
    if (perfil === 'proprietario') return; // Proprietario tem acesso mestre inalteravel

    setPermissions((prev) => {
      const updated = {
        ...prev,
        [perfil]: {
          ...prev[perfil],
          [moduloId]: !prev[perfil]?.[moduloId]
        }
      };
      return updated;
    });
  };

  const handleSalvarMatrizPermissoes = () => {
    saveRolePermissions(permissions);
    setPermSavedNotice(true);
    setTimeout(() => setPermSavedNotice(false), 3000);
  };

  const getBadgePerfil = (perfil) => {
    switch (perfil) {
      case 'proprietario':
        return <span className="badge badge-info"><Shield size={12} /> Proprietário / Gerente</span>;
      case 'veterinario':
        return <span className="badge badge-liberado"><Stethoscope size={12} /> Veterinário Responsável</span>;
      default:
        return <span className="badge badge-secondary"><UserCheck size={12} /> Colaborador / Campeiro</span>;
    }
  };

  return (
    <div>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h2 style={{ fontSize: '20px' }}>Equipe & Controle Personalizado de Acessos</h2>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Gerenciamento de membros da fazenda, registros de CRMV e matriz interativa de permissões
          </p>
        </div>

        <div style={{ display: 'flex', gap: '10px' }}>
          <button
            onClick={() => setAbaAtiva(abaAtiva === 'membros' ? 'permissoes' : 'membros')}
            className="btn btn-secondary"
          >
            <Shield size={16} />
            <span>{abaAtiva === 'membros' ? 'Configurar Permissões' : 'Ver Membros da Equipe'}</span>
          </button>

          <button onClick={() => setModalNovo(true)} className="btn btn-primary">
            <Plus size={16} />
            <span>Adicionar Membro</span>
          </button>
        </div>
      </div>

      {abaAtiva === 'membros' ? (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '16px' }}>
          {usuarios.map((u) => (
            <div key={u.id} className="card" style={{ position: 'relative' }}>
              <div className="card-header" style={{ marginBottom: '12px' }}>
                <div>
                  <h4 style={{ fontSize: '16px', fontWeight: 700 }}>{u.nome}</h4>
                  <div style={{ marginTop: '4px' }}>{getBadgePerfil(u.perfil)}</div>
                </div>

                <button
                  onClick={() => handleRemoverMembro(u.id, u.nome)}
                  className="btn btn-secondary btn-sm"
                  style={{ color: '#dc2626', borderColor: '#fee2e2', padding: '6px' }}
                  title="Remover Membro da Equipe"
                >
                  <Trash2 size={16} />
                </button>
              </div>

              <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '13px', color: 'var(--text-muted)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                  <Mail size={14} />
                  <span>{u.email}</span>
                </div>
                {u.telefone && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <Phone size={14} />
                    <span>{u.telefone}</span>
                  </div>
                )}
                {u.crmv && (
                  <div style={{ color: '#15803d', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <Stethoscope size={14} />
                    <span>CRMV: {u.crmv}</span>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      ) : (
        /* Matriz de Permissões Interativa para o Admin Editar */
        <div className="card">
          <div className="card-header" style={{ flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h4 className="card-title">
                <Shield size={18} className="text-primary" />
                <span>Matriz Editável de Permissões por Perfil</span>
              </h4>
              <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                Marque ou desmarque os módulos que cada tipo de usuário tem autorização para acessar na fazenda.
              </p>
            </div>

            <button onClick={handleSalvarMatrizPermissoes} className="btn btn-primary btn-sm">
              <Save size={14} />
              <span>Salvar Permissões</span>
            </button>
          </div>

          {permSavedNotice && (
            <div style={{ backgroundColor: '#dcfce7', color: '#15803d', border: '1px solid #86efac', padding: '10px 14px', borderRadius: '8px', marginBottom: '16px', fontSize: '13px', fontWeight: 600, display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Check size={16} />
              <span>Matriz de permissões atualizada com sucesso!</span>
            </div>
          )}

          <div className="table-container">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Módulo do Sistema</th>
                  <th style={{ textAlign: 'center' }}>Colaborador (Campo)</th>
                  <th style={{ textAlign: 'center' }}>Veterinário Responsável</th>
                  <th style={{ textAlign: 'center' }}>Proprietário / Gerente</th>
                </tr>
              </thead>
              <tbody>
                {MODULOS_CONFIG.map((mod) => (
                  <tr key={mod.id}>
                    <td style={{ fontWeight: 600 }}>{mod.label}</td>
                    
                    {/* Checkbox Colaborador */}
                    <td style={{ textAlign: 'center' }}>
                      <input
                        type="checkbox"
                        style={{ width: '18px', height: '18px', cursor: 'pointer', accentColor: '#16a34a' }}
                        checked={permissions.colaborador?.[mod.id] ?? false}
                        onChange={() => togglePermission('colaborador', mod.id)}
                      />
                    </td>

                    {/* Checkbox Veterinario */}
                    <td style={{ textAlign: 'center' }}>
                      <input
                        type="checkbox"
                        style={{ width: '18px', height: '18px', cursor: 'pointer', accentColor: '#16a34a' }}
                        checked={permissions.veterinario?.[mod.id] ?? false}
                        onChange={() => togglePermission('veterinario', mod.id)}
                      />
                    </td>

                    {/* Checkbox Proprietario (Fixo Acesso Mestre) */}
                    <td style={{ textAlign: 'center' }}>
                      <span className="badge badge-info" style={{ fontSize: '11px' }}>
                        ✓ Acesso Mestre
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Modal Novo Membro */}
      {modalNovo && (
        <div className="modal-overlay" onClick={() => setModalNovo(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '480px' }}>
            <h3 style={{ marginBottom: '16px' }}>Novo Membro da Equipe</h3>
            <form onSubmit={handleSalvarMembro}>
              <div className="form-group">
                <label className="form-label">Nome Completo *</label>
                <input
                  type="text"
                  className="form-input"
                  value={form.nome}
                  onChange={(e) => setForm({ ...form, nome: e.target.value })}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">E-mail de Acesso *</label>
                <input
                  type="email"
                  className="form-input"
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                  required
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label className="form-label">Perfil de Acesso</label>
                  <select
                    className="form-select"
                    value={form.perfil}
                    onChange={(e) => setForm({ ...form, perfil: e.target.value })}
                  >
                    <option value="colaborador">Colaborador / Campeiro</option>
                    <option value="veterinario">Veterinário Responsável</option>
                    <option value="proprietario">Proprietário / Gerente</option>
                  </select>
                </div>

                <div className="form-group">
                  <label className="form-label">Telefone</label>
                  <input
                    type="text"
                    className="form-input"
                    value={form.telefone}
                    onChange={(e) => setForm({ ...form, telefone: e.target.value })}
                    placeholder="(62) 99999-9999"
                  />
                </div>
              </div>

              {form.perfil === 'veterinario' && (
                <div className="form-group">
                  <label className="form-label">Número CRMV</label>
                  <input
                    type="text"
                    className="form-input"
                    value={form.crmv}
                    onChange={(e) => setForm({ ...form, crmv: e.target.value })}
                    placeholder="Ex: CRMV-GO 12345"
                  />
                </div>
              )}

              <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
                <button type="button" onClick={() => setModalNovo(false)} className="btn btn-secondary btn-block">
                  Cancelar
                </button>
                <button type="submit" className="btn btn-primary btn-block">
                  Salvar Membro
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
