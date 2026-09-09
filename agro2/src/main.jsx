import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css';

// Registrar Service Worker para PWA Offline
if ('serviceWorker' in navigator && (import.meta.env.PROD || window.location.hostname === 'localhost')) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').then((reg) => {
      console.log('[PWA] Service Worker registrado com sucesso no escopo:', reg.scope);
    }).catch((err) => {
      console.log('[PWA] Falha ao registrar ServiceWorker:', err);
    });
  });
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
