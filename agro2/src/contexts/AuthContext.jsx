import React, { createContext, useContext, useState, useEffect } from 'react';
import { db } from '../db/database.js';
import { seedDatabaseIfEmpty } from '../db/seed.js';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function initAuth() {
      try {
        await seedDatabaseIfEmpty();
        const savedUserId = localStorage.getItem('agro2_current_user_id');
        if (savedUserId) {
          const found = await db.usuarios.get(savedUserId);
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
    const userFound = await db.usuarios
      .filter((u) => u.email.toLowerCase() === cleanEmail && u.senha === senha && u.ativo)
      .first();

    if (!userFound) {
      throw new Error('E-mail ou senha incorretos.');
    }

    setUser(userFound);
    localStorage.setItem('agro2_current_user_id', userFound.id);
    return userFound;
  };

  const registerUser = async ({ nome, email, senha, perfil = 'proprietario', fazendaNome }) => {
    const cleanEmail = (email || '').trim().toLowerCase();
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

    await db.usuarios.add(newUser);

    if (fazendaNome && fazendaNome.trim()) {
      const existingFaz = await db.fazendas.toCollection().first();
      if (!existingFaz) {
        await db.fazendas.add({
          id: `faz-${Date.now()}`,
          nome: fazendaNome.trim(),
          proprietario_nome: nome.trim(),
          sync_status: 'pending',
          created_at: new Date().toISOString()
        });
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
