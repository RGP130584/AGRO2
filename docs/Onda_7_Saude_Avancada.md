# Onda 7 — Saúde Avançada: Prontuário e Protocolos Versionados

> Fase 3 do roadmap original. Introduz o registro de intervenções veterinárias como eventos
> append-only (nunca sobrescritos), vinculados ao módulo de Saúde já existente no Core.

---

## [ ] Passo 1 — Tabela de Intervenções Versionadas

1.1. Criar `intervencoes_veterinarias` (append-only — sem `UPDATE`, só `INSERT`):
   ```sql
   CREATE TABLE IF NOT EXISTS intervencoes_veterinarias (
     id TEXT PRIMARY KEY,
     animal_id TEXT NOT NULL,
     tenant_conta_id TEXT NOT NULL,
     veterinarian_id TEXT NOT NULL,
     grant_id TEXT NOT NULL,          -- qual grant autorizou esta ação
     tipo TEXT NOT NULL,              -- avaliacao | prescricao | aplicacao | retorno | encerramento
     payload TEXT NOT NULL,           -- detalhes específicos do tipo (JSON)
     intervencao_anterior_id TEXT,    -- referencia opcional, para formar uma "cadeia" (ex: retorno -> tratamento)
     created_at TEXT NOT NULL
   );
   CREATE INDEX IF NOT EXISTS idx_intervencoes_animal ON intervencoes_veterinarias (animal_id, created_at);
   ```
1.2. Middleware que grava toda gravação nesta tabela através de `authorizeGrant('intervencao')` —
   só grants com permissão "Intervenção" (ou "Técnico", para avaliação/recomendação, sem prescrição)
   podem escrever aqui.

> Prompt: "Crie a tabela append-only intervencoes_veterinarias e valide toda escrita através do
> middleware authorizeGrant, exigindo permissão 'intervencao' para tipos como prescrição/aplicação,
> e 'tecnico' para avaliação/observação."

**Pronto quando:** não existe nenhuma rota que faça `UPDATE` ou `DELETE` nesta tabela — só `INSERT`.

---

## [ ] Passo 2 — Ponte com o módulo de Saúde do Core

2.1. Quando uma intervenção do tipo `aplicacao` for registrada pelo veterinário, gerar também um
   registro correspondente em `proj_aplicacoes_sanitarias` (e replicar, via canal de sync, para o
   app do produtor) — o produtor deve continuar vendo essa aplicação na sua tela normal de Saúde,
   como sempre viu, só que agora com `autor: veterinario_id` e um link para a intervenção de origem
   (`intervencao_id`).
2.2. Adicionar campo opcional `intervencaoOrigemId` em `AplicacoesSanitarias` (schema Drift do app)
   e `proj_aplicacoes_sanitarias` (schema backend), nullable — preenchido só quando a aplicação
   nasceu de uma intervenção veterinária.

> Prompt: "Ao registrar uma intervenção do tipo aplicação, replique automaticamente um registro
> equivalente em proj_aplicacoes_sanitarias e sincronize de volta para o app do produtor via o canal
> de sync já existente, incluindo o vínculo com a intervenção de origem."

**Pronto quando:** o produtor abre a ficha de um animal no próprio app e vê uma aplicação feita pelo
veterinário, indistinguível na lista das que ele mesmo registra, exceto pelo autor.

---

## [ ] Passo 3 — Regra de Conflito entre Profissionais

**Objetivo:** gap de requisito identificado na análise dos documentos originais — o que acontece
quando dois veterinários com grant ativo registram intervenções conflitantes no mesmo animal?

3.1. Decisão adotada (mínima e segura): **nenhuma intervenção é bloqueada** — ambas ficam
   registradas, já que a tabela é histórico, não estado mutável.
3.2. Adicionar um indicador visual (no Portal e no app do produtor) quando um animal tiver
   intervenções de mais de um veterinário diferente nos últimos N dias (configurável) — um aviso
   informativo, não um bloqueio: "Este animal também foi atendido por [Dr. X] em [data]".

> Prompt: "Implemente um alerta visual (sem bloquear) quando um animal tiver intervenções
> registradas por mais de um veterinário nos últimos 30 dias, tanto no Portal quanto na ficha do
> animal no app do produtor."

**Pronto quando:** dois veterinários distintos conseguem registrar intervenções no mesmo animal sem
erro, e ambos (e o produtor) veem um aviso de que há mais de um profissional envolvido.

---

## [ ] Passo 4 — Prontuário Consolidado (timeline)

4.1. Endpoint `GET /v1/vet/animals/:id/prontuario` — retorna, em ordem cronológica, todas as
   intervenções + aplicações + ocorrências + pesagens do animal (reaproveita a mesma lógica do
   relatório "Ficha/Rastreabilidade Individual" já existente no Core, só que agora também acessível
   pelo veterinário via grant).
4.2. Tela de prontuário no Portal, timeline única.

> Prompt: "Crie o endpoint de prontuário consolidado do animal, unindo intervenções veterinárias,
> aplicações, ocorrências e pesagens em uma única timeline cronológica, acessível ao veterinário
> apenas com grant de ao menos 'consulta' sobre o animal/fazenda."

---

**Pronto quando (onda inteira):** um veterinário com grant "Intervenção" registra uma avaliação,
uma prescrição e um retorno para o mesmo animal; o produtor vê tudo isso refletido na ficha do
animal no seu próprio app, sem editar retroativamente nada.
