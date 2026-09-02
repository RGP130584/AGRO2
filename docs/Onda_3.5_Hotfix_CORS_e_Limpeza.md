# Onda 3.5 — Hotfix: Restaurar CORS Restrito + Limpeza de Repositório

> Correção pontual identificada na validação da Onda 2 (modularização do backend). Não é uma onda
> de produto — é dívida de segurança que regrediu silenciosamente durante um refactor "sem mudança
> de comportamento" e deve ser fechada antes da Onda 4.

---

## [ ] Passo 1 — Restaurar a whitelist de CORS

**Objetivo:** antes da modularização, o backend restringia CORS via `CORS_ORIGINS` (variável de
ambiente). Após a extração do `app.js` para `routes/*.js` + `middlewares/*.js`, o `app.js` novo
ficou com `app.use(cors())` **sem nenhuma opção** — ou seja, qualquer origem é aceita novamente. A
variável `CORS_ORIGINS` continua documentada em `.env.example`, mas não é mais lida em lugar nenhum.

1.1. Em `app.js`, substituir:
   ```js
   app.use(cors());
   ```
   por:
   ```js
   const allowedOrigins = (process.env.CORS_ORIGINS || '').split(',').map(o => o.trim()).filter(Boolean);
   app.use(cors({
     origin: (origin, callback) => {
       // Permite requisições sem origin (ex.: apps mobile, curl, Postman)
       if (!origin || allowedOrigins.includes('*') || allowedOrigins.includes(origin)) {
         return callback(null, true);
       }
       return callback(new Error('Origem não permitida por CORS'));
     }
   }));
   ```
1.2. Adicionar um teste de regressão simples (`tests/cors.test.js`) que faça uma requisição com um
   header `Origin` fora da whitelist e confirme que a resposta não inclui
   `Access-Control-Allow-Origin` para essa origem — assim, se isso regredir de novo em um futuro
   refactor, o `npm test` pega automaticamente.

> Prompt: "Restaure a whitelist de CORS no app.js modularizado, lendo CORS_ORIGINS do .env (mesmo
> comportamento que existia antes da modularização do backend). Adicione um teste de regressão que
> falhe se o CORS voltar a aceitar qualquer origem."

**Pronto quando:** uma requisição com `Origin` fora da lista de `CORS_ORIGINS` é rejeitada, e existe
um teste automatizado cobrindo isso.

---

## [ ] Passo 2 — Remover arquivo solto do repositório

**Objetivo:** `docs/apdf/CSO - Orçamento - Etiqueta_29112024.xlsx` não pertence a este projeto —
parece ter sido commitado sem querer junto com a leva anterior, e pode conter dado pessoal/financeiro
sem relação com o AGRO.

2.1. Remover o arquivo do controle de versão:
   ```bash
   git rm "docs/apdf/CSO - Orçamento - Etiqueta_29112024.xlsx"
   git commit -m "chore: remover arquivo pessoal commitado por engano"
   ```
2.2. Se o arquivo contiver dado sensível, avaliar se vale a pena também remover do **histórico**
   (mesmo procedimento já usado para o `backend.db`, com `git filter-repo`), não só do commit atual.

> Prompt: "Remova o arquivo 'docs/apdf/CSO - Orçamento - Etiqueta_29112024.xlsx' do repositório, ele
> não pertence a este projeto. Se contiver dado sensível, remova também do histórico do Git com
> git filter-repo."

**Pronto quando:** o arquivo não existe mais em `git ls-files`, e (se aplicável) não aparece mais em
nenhum commit do histórico.

---

**Pronto quando (onda inteira):** `npm test` passa com o novo teste de CORS incluso, e
`git log --all --full-history -- "docs/apdf/CSO - Orçamento - Etiqueta_29112024.xlsx"` não retorna
nada após a limpeza de histórico (se decidido fazê-la).
