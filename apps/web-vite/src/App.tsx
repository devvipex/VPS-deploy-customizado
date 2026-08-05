import { useState } from 'react';
import { useOnlineStatus } from './hooks/useOnlineStatus';
import './App.css';

function App() {
  const { isOnline, syncStatus } = useOnlineStatus();
  const [offlineNotes, setOfflineNotes] = useState<string[]>([]);
  const [inputNote, setInputNote] = useState('');

  const handleAddNote = (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputNote.trim()) return;
    setOfflineNotes(prev => [...prev, inputNote]);
    setInputNote('');
  };

  return (
    <div className="mobile-container">
      {/* Banner de status de rede */}
      <div className={`network-banner ${isOnline ? 'online' : 'offline'}`}>
        <span className="dot"></span>
        {isOnline ? 'Conectado (Online)' : 'Modo Offline - Funcionalidades salvas localmente'}
      </div>

      {/* Banner de sincronização */}
      {syncStatus && (
        <div className="sync-banner">
          🔄 {syncStatus}
        </div>
      )}

      <header className="app-header">
        <h1>🚀 Base PWA Offline-First</h1>
        <p className="subtitle">Mobile-First MVP Stack</p>
      </header>

      <main className="app-content">
        <section className="card">
          <h2>📱 Demonstração Offline-First</h2>
          <p className="card-desc">
            Desconecte a internet para testar. Você pode adicionar notas offline e elas serão preservadas!
          </p>

          <form onSubmit={handleAddNote} className="note-form">
            <input
              type="text"
              value={inputNote}
              onChange={e => setInputNote(e.target.value)}
              placeholder="Digite um dado para salvar offline..."
              className="note-input"
            />
            <button type="submit" className="note-btn">Salvar</button>
          </form>

          {offlineNotes.length > 0 && (
            <ul className="notes-list">
              {offlineNotes.map((note, index) => (
                <li key={index} className="note-item">
                  📌 {note}
                </li>
              ))}
            </ul>
          )}
        </section>

        <section className="card">
          <h2>🔗 Links de Serviços da VPS</h2>
          <div className="services-grid">
            <a href="http://localhost:3000" target="_blank" rel="noreferrer" className="service-chip">
              ⚙️ NestJS API (:3000)
            </a>
            <a href="http://localhost:8080" target="_blank" rel="noreferrer" className="service-chip">
              🏗️ Jenkins CI/CD (:8080)
            </a>
            <a href="http://localhost:9000" target="_blank" rel="noreferrer" className="service-chip">
              📦 MinIO Storage (:9000)
            </a>
            <a href="http://localhost:5678" target="_blank" rel="noreferrer" className="service-chip">
              ⚡ n8n Workflows (:5678)
            </a>
          </div>
        </section>
      </main>

      <footer className="app-footer">
        <p>Vite PWA + NestJS VPS Deploy Boilerplate</p>
      </footer>
    </div>
  );
}

export default App;
