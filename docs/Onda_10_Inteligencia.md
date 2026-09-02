# Onda 10 — Inteligência (Alertas Preditivos e Apoio à Decisão)

> Fase 6 do roadmap original — a última e a que exige mais maturidade de dados prévia. Só deve
> começar depois que as Ondas 1, 5 e 7 estiverem em produção há tempo suficiente para gerar volume
> real de dados relacionais (não faz sentido "prever" nada sobre uma tabela vazia).

---

## [ ] Passo 0 — Critério de entrada (antes de escrever qualquer código desta onda)

0.1. Confirmar que existe volume mínimo de dados reais nas tabelas projetadas (`proj_animais`,
   `proj_aplicacoes_sanitarias`, `intervencoes_veterinarias`) — sem isso, qualquer modelo/alerta
   "preditivo" é só regra arbitrária disfarçada de IA. Definir esse limiar com o time de produto
   antes de iniciar (ex.: X fazendas ativas por Y meses).

---

## [ ] Passo 1 — Alertas Baseados em Regra (antes de qualquer modelo estatístico/ML)

1.1. Começar pelo mais simples e já com valor imediato: alertas de limiar sobre as tabelas
   projetadas que já existem — ex.: "lote com GMD abaixo da média histórica do próprio lote nos
   últimos 30 dias", "animal com 3+ ocorrências sanitárias em 60 dias" — tudo isso é SQL sobre as
   tabelas da Onda 1, sem exigir nenhum modelo de machine learning.
1.2. Expor esses alertas no dashboard do Portal (Onda 6) e no app do produtor.

> Prompt: "Implemente alertas baseados em regra (sem ML) sobre as tabelas projetadas: GMD do lote
> abaixo da média histórica do próprio lote, e animais com múltiplas ocorrências sanitárias em curto
> período. Exponha no dashboard do Portal e no app do produtor."

**Pronto quando:** existem pelo menos 2 alertas de regra simples funcionando com dados reais, antes
de qualquer investimento em modelo estatístico.

---

## [ ] Passo 2 — Análise de Tendência (opcional, avaliar necessidade real antes)

2.1. Só avançar para modelos de série temporal (ex.: previsão de GMD futuro por lote) se os alertas
   de regra do Passo 1 já estiverem em uso real e o time identificar limitação clara neles.
2.2. Qualquer modelo aqui deve consumir exclusivamente as tabelas relacionais da Onda 1 — nunca os
   blobs JSON da tabela `entities`.

> Prompt: "Avalie com o time de produto se os alertas de regra do Passo 1 são insuficientes antes de
> implementar qualquer modelo de previsão de série temporal. Se avançar, consuma apenas as tabelas
> projetadas relacionais, nunca o payload JSON bruto."

---

## Princípio orientador desta onda

> A IA deve apoiar o veterinário, **não substituir a responsabilidade técnica** — citação direta do
> documento original (`AGRO_Modulo_Veterinario_Roadmap.md`, seção 13). Na prática, isso significa:
> todo alerta desta onda deve ser explicável em uma frase simples ("por que este alerta apareceu"),
> nunca uma decisão de "caixa-preta" sem justificativa visível para quem vai agir sobre ela.

**Pronto quando (onda inteira):** os alertas de regra (Passo 1) estão em produção e sendo usados de
fato pelos veterinários beta antes de qualquer decisão de investir em modelos mais sofisticados.
