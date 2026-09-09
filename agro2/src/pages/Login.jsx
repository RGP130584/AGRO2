import React, { useState } from 'react';
import { Layers, ArrowRight, UserPlus, LogIn, Building2, User, Mail, Lock, Shield } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext.jsx';

export default function Login() {
  const { login, registerUser } = useAuth();
  const [isRegistering, setIsRegistering] = useState(false);

  // Formulário Login
  const [email, setEmail] = useState('');
  const [senha, setSenha] = useState('');

  // Formulário Cadastro
  const [nome, setNome] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regSenha, setRegSenha] = useState('');
  const [confirmSenha, setConfirmSenha] = useState('');
  const [perfil, setPerfil] = useState('proprietario');
  const [fazendaNome, setFazendaNome] = useState('');

  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLoginSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(email, senha);
    } catch (err) {
      setError(err.message || 'Erro ao realizar login.');
    } finally {
      setLoading(false);
    }
  };

  const handleRegisterSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (regSenha !== confirmSenha) {
      setError('As senhas digitadas não coincidem.');
      return;
    }

    if (regSenha.length < 4) {
      setError('A senha deve ter no mínimo 4 caracteres.');
      return;
    }

    setLoading(true);
    try {
      await registerUser({
        nome,
        email: regEmail,
        senha: regSenha,
        perfil,
        fazendaNome
      });
    } catch (err) {
      setError(err.message || 'Erro ao cadastrar conta.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        background: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '20px'
      }}
    >
      <div
        style={{
          width: '100%',
          maxWidth: '460px',
          background: '#ffffff',
          borderRadius: 'var(--radius-xl)',
          padding: '32px 28px',
          boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.4)'
        }}
      >
        {/* Cabeçalho */}
        <div style={{ textAlign: 'center', marginBottom: '24px' }}>
          <div
            style={{
              width: '56px',
              height: '56px',
              background: 'linear-gradient(135deg, #22c55e, #15803d)',
              borderRadius: '16px',
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: 'white',
              boxShadow: '0 8px 16px rgba(34, 197, 94, 0.35)',
              marginBottom: '12px'
            }}
          >
            <Layers size={30} strokeWidth={2.5} />
          </div>
          <h1 style={{ fontSize: '24px', fontWeight: 800, color: '#0f172a' }}>AGRO 2</h1>
          <p style={{ fontSize: '13px', color: '#64748b', marginTop: '4px' }}>
            Gestão Pecuária Inteligente & Controle Sanitário Offline
          </p>
        </div>

        {/* Abas Alternadoras (Entrar vs Criar Conta) */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            background: '#f1f5f9',
            borderRadius: '10px',
            padding: '4px',
            marginBottom: '20px'
          }}
        >
          <button
            type="button"
            onClick={() => {
              setIsRegistering(false);
              setError('');
            }}
            style={{
              padding: '10px',
              borderRadius: '8px',
              border: 'none',
              fontSize: '13px',
              fontWeight: 600,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
              transition: 'all 0.2s',
              background: !isRegistering ? '#ffffff' : 'transparent',
              color: !isRegistering ? '#0f172a' : '#64748b',
              boxShadow: !isRegistering ? '0 2px 4px rgba(0,0,0,0.08)' : 'none'
            }}
          >
            <LogIn size={15} />
            <span>Já sou cadastrado</span>
          </button>

          <button
            type="button"
            onClick={() => {
              setIsRegistering(true);
              setError('');
            }}
            style={{
              padding: '10px',
              borderRadius: '8px',
              border: 'none',
              fontSize: '13px',
              fontWeight: 600,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '6px',
              transition: 'all 0.2s',
              background: isRegistering ? '#ffffff' : 'transparent',
              color: isRegistering ? '#15803d' : '#64748b',
              boxShadow: isRegistering ? '0 2px 4px rgba(0,0,0,0.08)' : 'none'
            }}
          >
            <UserPlus size={15} />
            <span>Primeiro Acesso</span>
          </button>
        </div>

        {error && (
          <div
            style={{
              background: '#fee2e2',
              color: '#b91c1c',
              padding: '10px 14px',
              borderRadius: '8px',
              fontSize: '13px',
              fontWeight: 500,
              marginBottom: '16px'
            }}
          >
            {error}
          </div>
        )}

        {/* Formulário de Login */}
        {!isRegistering ? (
          <form onSubmit={handleLoginSubmit}>
            <div className="form-group">
              <label className="form-label">E-mail</label>
              <input
                type="email"
                className="form-input"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Seu e-mail cadastrado"
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Senha</label>
              <input
                type="password"
                className="form-input"
                value={senha}
                onChange={(e) => setSenha(e.target.value)}
                placeholder="••••••"
                required
              />
            </div>

            <button
              type="submit"
              className="btn btn-primary btn-block btn-lg"
              disabled={loading}
              style={{ marginTop: '12px' }}
            >
              <span>{loading ? 'Entrando...' : 'Entrar no Sistema'}</span>
              <ArrowRight size={18} />
            </button>
          </form>
        ) : (
          /* Formulário de Primeiro Acesso / Cadastro */
          <form onSubmit={handleRegisterSubmit}>
            <div className="form-group">
              <label className="form-label">Nome Completo</label>
              <input
                type="text"
                className="form-input"
                value={nome}
                onChange={(e) => setNome(e.target.value)}
                placeholder="Ex: João da Silva"
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Nome da Fazenda / Propriedade</label>
              <input
                type="text"
                className="form-input"
                value={fazendaNome}
                onChange={(e) => setFazendaNome(e.target.value)}
                placeholder="Ex: Fazenda Santa Maria"
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Perfil de Acesso</label>
              <select
                className="form-select"
                value={perfil}
                onChange={(e) => setPerfil(e.target.value)}
              >
                <option value="proprietario">Proprietário / Gerente</option>
                <option value="veterinario">Veterinário / Zootecnista</option>
                <option value="colaborador">Operador de Campo / Vaqueiro</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">E-mail para Login</label>
              <input
                type="email"
                className="form-input"
                value={regEmail}
                onChange={(e) => setRegEmail(e.target.value)}
                placeholder="seuemail@exemplo.com"
                required
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label className="form-label">Criar Senha</label>
                <input
                  type="password"
                  className="form-input"
                  value={regSenha}
                  onChange={(e) => setRegSenha(e.target.value)}
                  placeholder="••••••"
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Confirmar Senha</label>
                <input
                  type="password"
                  className="form-input"
                  value={confirmSenha}
                  onChange={(e) => setConfirmSenha(e.target.value)}
                  placeholder="••••••"
                  required
                />
              </div>
            </div>

            <button
              type="submit"
              className="btn btn-primary btn-block btn-lg"
              disabled={loading}
              style={{ marginTop: '12px', background: 'linear-gradient(135deg, #15803d, #166534)' }}
            >
              <span>{loading ? 'Cadastrando...' : 'Criar Conta e Iniciar'}</span>
              <UserPlus size={18} />
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
