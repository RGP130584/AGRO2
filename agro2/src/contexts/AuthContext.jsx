import React, { createContext, useContext, useState, useEffect } from 'react';
import { db } from '../db/database.js';
import { clearDemoDataIfPresent } from '../db/clearDemo.js';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function initAuth() {
      try {
        await clearDemoDataIfPresent();
        const savedUserId = localStorage.getItem('agro2_current_user_id');
        if (savedUserId) {
          let found = await db.usuarios.get(savedUserId);

          if (!found) {
            // Tenta buscar no Supabase
            try {
              const { supabase } = await import('../lib/supabase.js');
              const { data } = await supabase.from('usuarios').select('*').eq('id', savedUserId).maybeSingle();
              if (data) {
                found = data;
                await db.usuarios.put(data);
              }
            } catch (sbErr) {
              console.warn('[Supabase Init User Error]:', sbErr.message);
            }
          }

          if (found && found.ativo) {
            setUser(found);
          }
        }
      } catch (err) {
        console.error('Erro ao inicializar autenticação:', err);
      } finally {
        setLoading(false);
      }
    }
    initAuth();
  }, []);

  const login = async (email, senha) => {
    const cleanEmail = (email || '').trim().toLowerCase();
    
    // 1. Procura localmente no IndexedDB
    let userFound = await db.usuarios
      .filter((u) => u.email.toLowerCase() === cleanEmail && u.senha === senha && u.ativo)
      .first();

    // 2. Se não encontrou no aparelho, tenta buscar na nuvem (Supabase)
    if (!userFound) {
      try {
        const { supabase } = await import('../lib/supabase.js');
        const { data, error } = await supabase
          .from('usuarios')
          .select('*')
          .eq('email', cleanEmail)
          .eq('senha', senha)
          .maybeSingle();

        if (data && !error) {
          userFound = data;
          await db.usuarios.put(data); // Salva no IndexedDB local para acesso offline
        }
      } catch (err) {
        console.warn('[Auth Supabase Login Error]:', err.message);
      }
    }

    if (!userFound) {
      throw new Error('E-mail ou senha incorretos.');
    }

    setUser(userFound);
    localStorage.setItem('agro2_current_user_id', userFound.id);
    return userFound;
  };

  const registerUser = async ({ nome, email, senha, perfil = 'proprietario', fazendaNome }) => {
    const cleanEmail = (email || '').trim().toLowerCase();
    
    // Verifica duplicidade local
    const existing = await db.usuarios.filter((u) => u.email.toLowerCase() === cleanEmail).first();
    if (existing) {
      throw new Error('Já existe um usuário cadastrado com este e-mail.');
    }

    const newUser = {
      id: `user-${Date.now()}-${Math.random().toString(36).substring(2, 7)}`,
      nome: nome.trim(),
      email: cleanEmail,
      senha,
      perfil,
      ativo: true,
      created_at: new Date().toISOString()
    };

    // Salva localmente
    await db.usuarios.add(newUser);

    // Envia para o Supabase (Nuvem)
    try {
      const { supabase } = await import('../lib/supabase.js');
      await supabase.from('usuarios').upsert(newUser);
    } catch (err) {
      console.warn('[Auth Supabase Register User Error]:', err.message);
    }

    if (fazendaNome && fazendaNome.trim()) {
      const newFazenda = {
        id: `faz-${Date.now()}`,
        nome: fazendaNome.trim(),
        proprietario_nome: nome.trim(),
        sync_status: 'synced',
        created_at: new Date().toISOString()
      };
      
      await db.fazendas.add(newFazenda);

      try {
        const { supabase } = await import('../lib/supabase.js');
        await supabase.from('fazendas').upsert(newFazenda);
      } catch (err) {
        console.warn('[Auth Supabase Register Fazenda Error]:', err.message);
      }
    }

    setUser(newUser);
    localStorage.setItem('agro2_current_user_id', newUser.id);
    return newUser;
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('agro2_current_user_id');
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, registerUser, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
