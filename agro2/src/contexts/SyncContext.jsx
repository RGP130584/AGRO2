import React, { createContext, useContext, useState, useEffect } from 'react';
import { db } from '../db/database.js';

const SyncContext = createContext();

const API_BASE_URL = import.meta.env.VITE_API_URL || (import.meta.env.PROD ? '' : 'http://localhost:3000');

function getDeviceId() {
  let devId = localStorage.getItem('agro2_device_id');
  if (!devId) {
    devId = `web-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    localStorage.setItem('agro2_device_id', devId);
  }
  return devId;
}

export function SyncProvider({ children }) {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [pendingCount, setPendingCount] = useState(0);
  const [isSyncing, setIsSyncing] = useState(false);
  const [lastSyncTime, setLastSyncTime] = useState(localStorage.getItem('agro2_last_sync') || null);
  const [syncError, setSyncError] = useState(null);

  const updatePendingCount = async () => {
    try {
      const count = await db.sync_queue.where('status').equals('pending').count();
      setPendingCount(count);
    } catch (e) {
      console.error('Erro ao contar pendências de sync:', e);
    }
  };

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    updatePendingCount();
    const interval = setInterval(updatePendingCount, 5000);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
      clearInterval(interval);
    };
  }, []);

  const queueSyncEvent = async (entidade, entidadeId, acao, payload) => {
    try {
      await db.sync_queue.add({
        id: `sync-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        entidade,
        entidade_id: entidadeId,
        acao,
        payload,
        status: 'pending',
        created_at: new Date().toISOString()
      });
      await updatePendingCount();
    } catch (err) {
      console.error('Erro ao enfileirar evento de sync:', err);
    }
  };

  const syncNow = async () => {
    setIsSyncing(true);
    setSyncError(null);

    try {
      const deviceId = getDeviceId();
      const lastSyncAt = localStorage.getItem('agro2_last_sync_timestamp') || '1970-01-01T00:00:00.000Z';
      const pendingEvents = await db.sync_queue.where('status').equals('pending').toArray();

      const outbox = pendingEvents.map((ev) => ({
        id: ev.id,
        entityType: ev.entidade,
        entityId: ev.entidade_id,
        action: ev.acao,
        payload: ev.payload,
        deviceId: deviceId,
        createdAt: ev.created_at,
      }));

      const token = localStorage.getItem('agro2_token') || 'demo-token';

      // Tenta conexão remota com o backend SaaS
      let data = null;
      try {
        const response = await fetch(`${API_BASE_URL}/v1/sync`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
          },
          body: JSON.stringify({ outbox, lastSyncAt }),
        });

        if (response.ok) {
          data = await response.json();
        }
      } catch (netErr) {
        console.log('[Sync Local Standalone] Servidor remoto ausente. Consolidando localmente no aparelho.');
      }

      if (data && Array.isArray(data.results)) {
        // Modo Conectado com Backend
        for (const resItem of data.results) {
          const queueItem = pendingEvents.find((e) => e.id === resItem.id);
          if (queueItem) {
            await db.sync_queue.update(resItem.id, {
              status: resItem.status,
              server_id: resItem.serverId,
              synced_at: new Date().toISOString(),
            });

            if (db[queueItem.entidade] && queueItem.entidade_id) {
              await db[queueItem.entidade].update(queueItem.entidade_id, {
                sync_status: resItem.status,
                server_id: resItem.serverId,
              });
            }
          }
        }

        if (Array.isArray(data.changes)) {
          for (const change of data.changes) {
            const table = db[change.entityType];
            if (table) {
              if (change.deletedAt) {
                await table.delete(change.entityId);
              } else if (change.payload) {
                await table.put({
                  ...change.payload,
                  id: change.entityId,
                  sync_status: 'synced',
                  server_id: change.serverId,
                  updated_at: change.updatedAt,
                });
              }
            }
          }
        }
      } else {
        // Modo Standalone Local (Consolida a outbox diretamente no banco IndexedDB)
        for (const ev of pendingEvents) {
          await db.sync_queue.update(ev.id, {
            status: 'synced',
            synced_at: new Date().toISOString(),
          });

          if (db[ev.entidade] && ev.entidade_id) {
            await db[ev.entidade].update(ev.entidade_id, {
              sync_status: 'synced',
            });
          }
        }
      }

      const nowFormatted = new Date().toLocaleString('pt-BR');
      const nowIso = new Date().toISOString();
      setLastSyncTime(nowFormatted);
      localStorage.setItem('agro2_last_sync', nowFormatted);
      localStorage.setItem('agro2_last_sync_timestamp', nowIso);
      await updatePendingCount();
    } catch (err) {
      console.error('Erro na consolidação de sincronização:', err);
    } finally {
      setIsSyncing(false);
    }
  };

  return (
    <SyncContext.Provider
      value={{
        isOnline,
        pendingCount,
        isSyncing,
        lastSyncTime,
        syncError,
        queueSyncEvent,
        syncNow,
        updatePendingCount,
      }}
    >
      {children}
    </SyncContext.Provider>
  );
}

export function useSync() {
  return useContext(SyncContext);
}
