# Onda 8 — Nutrição Avançada (Recomendação Veterinária)

> Fase 4 do roadmap original. Menor em escopo que as Ondas 5-7 — reaproveita quase toda a
> infraestrutura já construída (grants, audit, projeção), aplicando-a ao domínio de Nutrição que já
> existe no Core desde a wave de funcionalidades de negócio.

---

## [ ] Passo 1 — Recomendação Nutricional Vinculada

1.1. Criar `recomendacoes_nutricionais` (mesmo padrão append-only da Onda 7):
   ```sql
   CREATE TABLE IF NOT EXISTS recomendacoes_nutricionais (
     id TEXT PRIMARY KEY,
     lote_id TEXT NOT NULL,
     tenant_conta_id TEXT NOT NULL,
     veterinarian_id TEXT NOT NULL,
     grant_id TEXT NOT NULL,
     dieta_sugerida TEXT NOT NULL, -- JSON: mesma estrutura de Dietas do Core
     justificativa TEXT,
     created_at TEXT NOT NULL
   );
   ```
1.2. Exigir `authorizeGrant('tecnico')` no mínimo para criar uma recomendação (não precisa de
   "intervenção", já que é uma sugestão, não uma ação direta sobre o animal).
1.3. O produtor decide se aplica a recomendação — ao aplicar, isso cria uma `Dieta` normal no Core
   (mesma tabela já existente), com `origemRecomendacaoId` apontando para a recomendação.

> Prompt: "Crie a tabela recomendacoes_nutricionais e o fluxo onde o veterinário sugere uma dieta
> (exigindo grant 'tecnico') e o produtor decide aplicá-la, criando uma Dieta normal no Core
> vinculada à recomendação de origem."

**Pronto quando:** uma recomendação nutricional aparece no app do produtor como uma sugestão
pendente, distinta de uma dieta já ativa, até que ele escolha aplicá-la.

---

## [ ] Passo 2 — Comparação de Resultado ao Longo do Tempo

2.1. Endpoint `GET /v1/vet/lotes/:id/evolucao-nutricional` — cruza `proj_fornecimentos_dieta` (o
   que foi realmente fornecido) com `proj_pesagens`/GMD do lote no mesmo período, permitindo ao
   veterinário avaliar se a recomendação teve efeito.
2.2. Gráfico simples no Portal: eixo X = tempo, duas linhas (GMD do lote e % de aderência à
   dieta recomendada).

> Prompt: "Crie o endpoint que cruza fornecimento de dieta com GMD do lote no mesmo período, para o
> veterinário avaliar o efeito de uma recomendação nutricional ao longo do tempo."

**Pronto quando:** o veterinário consegue ver, num único gráfico, se um lote que seguiu a dieta
recomendada teve GMD melhor que antes da recomendação.

---

**Pronto quando (onda inteira):** o ciclo completo — recomendação → decisão do produtor → aplicação
→ acompanhamento de resultado — funciona de ponta a ponta, sem exigir nenhuma tabela nova além das
listadas aqui (reaproveita tudo o que já existe de Nutrição no Core).
