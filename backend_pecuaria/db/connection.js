/**
 * db/connection.js — Conexão SQLite e helpers de Promise
 * 
 * Centraliza a criação do banco e exporta helpers assíncronos
 * usados por todos os módulos do backend.
 */
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbFile = process.env.NODE_ENV === 'test'
  ? ':memory:'
  : (process.env.VERCEL
      ? '/tmp/backend.db'
      : path.resolve(__dirname, '..', process.env.DB_FILE || 'backend.db'));

const db = new sqlite3.Database(dbFile, (err) => {
  if (err) {
    console.error('Erro ao conectar ao SQLite:', err.message);
  } else {
    console.log(`Conectado ao SQLite (${process.env.NODE_ENV === 'test' ? ':memory:' : dbFile})`);
  }
});

// Helpers para executar SQL com Promises
const runAsync = (sql, params = []) => new Promise((resolve, reject) => {
  db.run(sql, params, function (err) {
    if (err) reject(err);
    else resolve(this);
  });
});

const getAsync = (sql, params = []) => new Promise((resolve, reject) => {
  db.get(sql, params, (err, row) => {
    if (err) reject(err);
    else resolve(row);
  });
});

const allAsync = (sql, params = []) => new Promise((resolve, reject) => {
  db.all(sql, params, (err, rows) => {
    if (err) reject(err);
    else resolve(rows);
  });
});

module.exports = { db, dbFile, runAsync, getAsync, allAsync };
