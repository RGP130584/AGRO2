import React, { useState } from 'react';
import { AuthProvider, useAuth } from './contexts/AuthContext.jsx';
import { SyncProvider } from './contexts/SyncContext.jsx';
import Layout from './components/Layout.jsx';

import Login from './pages/Login.jsx';
import Dashboard from './pages/Dashboard.jsx';

import RebanhoList from './pages/rebanho/RebanhoList.jsx';
import AnimalDetalhe from './pages/rebanho/AnimalDetalhe.jsx';
import AnimalForm from './pages/rebanho/AnimalForm.jsx';
import LotesList from './pages/rebanho/LotesList.jsx';
import LoteForm from './pages/rebanho/LoteForm.jsx';

import SaudeDashboard from './pages/saude/SaudeDashboard.jsx';
import AplicacaoForm from './pages/saude/AplicacaoForm.jsx';
import OcorrenciaForm from './pages/saude/OcorrenciaForm.jsx';

import NutricaoList from './pages/nutricao/NutricaoList.jsx';
import DietaForm from './pages/nutricao/DietaForm.jsx';
import FornecimentoForm from './pages/nutricao/FornecimentoForm.jsx';

import PesagemList from './pages/pesagem/PesagemList.jsx';
import RegistroPesagem from './pages/pesagem/RegistroPesagem.jsx';

import EstoqueList from './pages/estoque/EstoqueList.jsx';
import MovimentoForm from './pages/estoque/MovimentoForm.jsx';

import FinanceiroList from './pages/financeiro/FinanceiroList.jsx';
import LancamentoForm from './pages/financeiro/LancamentoForm.jsx';

import RelatoriosDashboard from './pages/relatorios/RelatoriosDashboard.jsx';
import EquipeList from './pages/equipe/EquipeList.jsx';
import SyncStatus from './pages/sync/SyncStatus.jsx';
import OnboardingModal from './components/OnboardingModal.jsx';

function MainApp() {
  const { user, loading } = useAuth();
  const [activePage, setActivePage] = useState('dashboard');
  const [selectedAnimalId, setSelectedAnimalId] = useState(null);
  const [selectedLoteId, setSelectedLoteId] = useState(null);

  if (loading) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#0f172a', color: 'white' }}>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: '24px', fontWeight: 800, marginBottom: '8px' }}>AGRO 2</div>
          <div style={{ color: '#94a3b8', fontSize: '14px' }}>Inicializando banco local seguro...</div>
        </div>
      </div>
    );
  }

  if (!user) {
    return <Login />;
  }

  const navigateTo = (page, param = null) => {
    if (page === 'rebanho_detalhe' || page === 'rebanho_editar' || page === 'pesagem_nova' || page === 'saude_aplicar') {
      setSelectedAnimalId(param);
    }
    if (page === 'rebanho_lote_editar') {
      setSelectedLoteId(param);
    }
    setActivePage(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const renderContent = () => {
    switch (activePage) {
      case 'dashboard':
        return <Dashboard onNavigate={navigateTo} />;

      // Rebanho
      case 'rebanho':
        return (
          <RebanhoList
            onNovoAnimal={() => navigateTo('rebanho_novo')}
            onVerDetalhe={(id) => navigateTo('rebanho_detalhe', id)}
            onVerLotes={() => navigateTo('rebanho_lotes')}
          />
        );
      case 'rebanho_novo':
        return (
          <AnimalForm
            animalId={null}
            onSalvo={(id) => navigateTo('rebanho_detalhe', id)}
            onCancelar={() => navigateTo('rebanho')}
          />
        );
      case 'rebanho_editar':
        return (
          <AnimalForm
            animalId={selectedAnimalId}
            onSalvo={(id) => navigateTo('rebanho_detalhe', id)}
            onCancelar={() => navigateTo('rebanho_detalhe', selectedAnimalId)}
          />
        );
      case 'rebanho_detalhe':
        return (
          <AnimalDetalhe
            animalId={selectedAnimalId}
            onVoltar={() => navigateTo('rebanho')}
            onEditar={(id) => navigateTo('rebanho_editar', id)}
            onRegistrarPesagem={(id) => navigateTo('pesagem_nova', id)}
            onRegistrarAplicacao={(id) => navigateTo('saude_aplicar', id)}
          />
        );
      case 'rebanho_lotes':
        return (
          <LotesList
            onVoltar={() => navigateTo('rebanho')}
            onNovoLote={(esp) => navigateTo('rebanho_lote_novo', esp)}
            onEditarLote={(id) => navigateTo('rebanho_lote_editar', id)}
          />
        );
      case 'rebanho_lote_novo':
        return (
          <LoteForm
            loteId={null}
            especieInicial={selectedLoteId}
            onSalvo={() => navigateTo('rebanho_lotes')}
            onCancelar={() => navigateTo('rebanho_lotes')}
          />
        );
      case 'rebanho_lote_editar':
        return (
          <LoteForm
            loteId={selectedLoteId}
            onSalvo={() => navigateTo('rebanho_lotes')}
            onCancelar={() => navigateTo('rebanho_lotes')}
          />
        );

      // Saúde
      case 'saude':
        return (
          <SaudeDashboard
            onNovaAplicacao={(id) => navigateTo('saude_aplicar', id)}
            onNovaOcorrencia={() => navigateTo('saude_ocorrencia')}
            onVerAnimal={(id) => navigateTo('rebanho_detalhe', id)}
          />
        );
      case 'saude_aplicar':
        return (
          <AplicacaoForm
            animalIdInicial={selectedAnimalId}
            onSalvo={() => navigateTo('saude')}
            onCancelar={() => navigateTo('saude')}
          />
        );
      case 'saude_ocorrencia':
        return (
          <OcorrenciaForm
            onSalvo={() => navigateTo('saude')}
            onCancelar={() => navigateTo('saude')}
          />
        );

      // Nutrição
      case 'nutricao':
        return (
          <NutricaoList
            onNovaDieta={() => navigateTo('nutricao_dieta_nova')}
            onNovoFornecimento={() => navigateTo('nutricao_fornecer')}
          />
        );
      case 'nutricao_dieta_nova':
        return (
          <DietaForm
            onSalvo={() => navigateTo('nutricao')}
            onCancelar={() => navigateTo('nutricao')}
          />
        );
      case 'nutricao_fornecer':
        return (
          <FornecimentoForm
            onSalvo={() => navigateTo('nutricao')}
            onCancelar={() => navigateTo('nutricao')}
          />
        );

      // Pesagem
      case 'pesagem':
        return (
          <PesagemList
            onNovaPesagem={() => navigateTo('pesagem_nova')}
            onVerAnimal={(id) => navigateTo('rebanho_detalhe', id)}
          />
        );
      case 'pesagem_nova':
        return (
          <RegistroPesagem
            animalIdInicial={selectedAnimalId}
            onSalvo={() => navigateTo('pesagem')}
            onCancelar={() => navigateTo('pesagem')}
          />
        );

      // Estoque
      case 'estoque':
        return <EstoqueList onNovaEntrada={() => navigateTo('estoque_entrada')} />;
      case 'estoque_entrada':
        return (
          <MovimentoForm
            onSalvo={() => navigateTo('estoque')}
            onCancelar={() => navigateTo('estoque')}
          />
        );

      // Financeiro
      case 'financeiro':
        return <FinanceiroList onNovoLancamento={() => navigateTo('financeiro_novo')} />;
      case 'financeiro_novo':
        return (
          <LancamentoForm
            onSalvo={() => navigateTo('financeiro')}
            onCancelar={() => navigateTo('financeiro')}
          />
        );

      // Relatórios & GTA
      case 'relatorios':
        return <RelatoriosDashboard onVerFichaAnimal={(id) => navigateTo('rebanho_detalhe', id)} />;

      // Equipe
      case 'equipe':
        return <EquipeList />;

      // Sync
      case 'sync':
        return <SyncStatus />;

      default:
        return <Dashboard onNavigate={navigateTo} />;
    }
  };

  return (
    <>
      <OnboardingModal />
      <Layout activePage={activePage} setActivePage={setActivePage}>
        {renderContent()}
      </Layout>
    </>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <SyncProvider>
        <MainApp />
      </SyncProvider>
    </AuthProvider>
  );
}
