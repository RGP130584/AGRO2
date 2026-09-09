import React, { useState } from 'react';
import { Camera, Image as ImageIcon, X } from 'lucide-react';
import { comprimirImagem } from '../utils/imagemHelper.js';

export default function CameraCapture({ foto, onFotoChange, label = 'Foto / Anexo Visual' }) {
  const [loading, setLoading] = useState(false);

  const handleFile = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setLoading(true);
    try {
      const dataUrl = await comprimirImagem(file, 800, 0.7);
      onFotoChange(dataUrl);
    } catch (err) {
      console.error('Erro ao processar foto:', err);
      alert('Não foi possível processar a imagem.');
    } finally {
      setLoading(false);
    }
  };

  const handleRemove = () => {
    onFotoChange(null);
  };

  return (
    <div className="form-group">
      <label className="form-label">{label}</label>

      {foto ? (
        <div style={{ position: 'relative', width: '100%', maxWidth: '240px', borderRadius: '12px', overflow: 'hidden', border: '2px solid var(--border)' }}>
          <img src={foto} alt="Captura" style={{ width: '100%', height: '160px', objectFit: 'cover', display: 'block' }} />
          <button
            type="button"
            onClick={handleRemove}
            style={{
              position: 'absolute',
              top: '8px',
              right: '8px',
              background: 'rgba(220, 38, 38, 0.9)',
              color: 'white',
              border: 'none',
              borderRadius: '50%',
              width: '28px',
              height: '28px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer'
            }}
          >
            <X size={16} />
          </button>
        </div>
      ) : (
        <div style={{ display: 'flex', gap: '10px' }}>
          <label
            className="btn btn-secondary"
            style={{ flex: 1, cursor: 'pointer', borderStyle: 'dashed', borderWidth: '1.5px', padding: '14px' }}
          >
            <Camera size={18} className="text-primary" />
            <span>{loading ? 'Processando...' : 'Tirar Foto'}</span>
            <input
              type="file"
              accept="image/*"
              capture="environment"
              onChange={handleFile}
              style={{ display: 'none' }}
              disabled={loading}
            />
          </label>

          <label
            className="btn btn-secondary"
            style={{ flex: 1, cursor: 'pointer', borderStyle: 'dashed', borderWidth: '1.5px', padding: '14px' }}
          >
            <ImageIcon size={18} />
            <span>Galeria</span>
            <input
              type="file"
              accept="image/*"
              onChange={handleFile}
              style={{ display: 'none' }}
              disabled={loading}
            />
          </label>
        </div>
      )}
    </div>
  );
}
