# Onda 6 — Portal Veterinário

> Fase 2 do roadmap original. Consome diretamente as tabelas projetadas da Onda 1 e os grants da
> Onda 5 — é a primeira tela que realmente exige consulta cross-tenant (várias fazendas de uma vez).

---

## [ ] Passo 1 — Decisão de produto: web ou dentro do app Flutter?

1.1. Recomendação: **portal web separado**, não uma tela a mais dentro do app Flutter do produtor.
   Justificativa: o caso de uso ("veterinário no escritório revisando 12 fazendas") é
   fundamentalmente uma sessão de trabalho de mesa, não de campo/offline — o valor do offline-first
   é menor aqui, e um web app dá mais espaço de tela para dashboards com múltiplas fazendas.
1.2. Se a decisão for por um app à parte, ele pode reaproveitar 100% do backend já modularizado
   (`routes/`, `middlewares/authorizeGrant`) — só o front-end muda.

> Esta decisão deve ser validada com o time de produto antes de iniciar os Passos 2-4; o resto da
> onda assume "portal web", mas a API por trás serve os dois formatos igualmente.

---

## [ ] Passo 2 — Endpoint consolidado de dashboard

2.1. Criar `GET /v1/vet/dashboard` (autenticado como veterinário) — para cada fazenda com grant
   ativo, agregando das tabelas projetadas (Onda 1):
   - contagem de animais em carência (`proj_aplicacoes_sanitarias` com carência futura)
   - divergências nutricionais recentes (reaproveitando a lógica já usada no relatório do Core)
   - alertas de estoque (produtos abaixo do mínimo / próximos do vencimento)
2.2. Este endpoint só deve considerar fazendas cujo grant tenha pelo menos permissão `consulta` —
   reaproveitar `authorizeGrant`, mas numa variante que filtra a lista em vez de bloquear uma única
   requisição (`listAuthorizedTenants(veterinarianId)`).

> Prompt: "Crie o endpoint GET /v1/vet/dashboard que agrega, para todas as fazendas com grant ativo
> do veterinário logado, animais em carência, divergências nutricionais e alertas de estoque,
> usando as tabelas projetadas da Onda 1."

**Pronto quando:** uma única chamada de API retorna o resumo de todas as fazendas autorizadas, sem
o cliente precisar fazer uma chamada por fazenda.

---

## [ ] Passo 3 — Interface do Portal (dashboard consolidado)

3.1. Tela inicial: cards por fazenda (nome, indicadores-chave, badge de nível de permissão) — ao
   clicar, abre a visão detalhada daquela fazenda especificamente (reaproveitando os relatórios já
   existentes no Core: GMD por lote, Kardex de estoque, etc., agora servidos via API em vez de
   lidos do SQLite local).
3.2. Indicador visual de "grant expira em X dias" quando aplicável — não deixar o veterinário ser
   surpreendido pela expiração.

> Prompt: "Construa a tela inicial do Portal Veterinário: cards por fazenda com indicadores-chave e
> nível de permissão, abrindo o detalhamento da fazenda ao clicar."

---

## [ ] Passo 4 — Agenda e Alertas Básicos

4.1. Tabela simples `vet_agenda` (`veterinarian_id, tenant_conta_id, titulo, data_hora, tipo:
   visita/retorno, status`).
4.2. Tela de agenda cronológica, cruzando com os grants ativos (não permitir agendar para uma
   fazenda sem grant ativo).

> Prompt: "Crie a tabela vet_agenda e uma tela de agenda cronológica para o veterinário, restrita a
> fazendas com grant ativo."

**Pronto quando:** o veterinário loga uma vez e vê um resumo priorizado (não uma lista neutra) de
todas as fazendas sob sua responsabilidade, incluindo o que precisa de atenção mais urgente
(carência, divergência, estoque).

---

**Pronto quando (onda inteira):** o Portal está no ar, consumindo dados reais das tabelas
projetadas, respeitando os grants ativos e seus níveis de permissão — testável com o mesmo cenário
de duas fazendas/dois grants usado na validação da Onda 5.
