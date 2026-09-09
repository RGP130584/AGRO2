# AGRO2 — RUNBOOK EXECUTÁVEL
## Correção e Validação da Sincronização Supabase

**Projeto:** AGRO2  
**Objetivo:** Restaurar sincronização bidirecional confiável entre dispositivos  
**Executor:** Antigravity  
**Prioridade:** CRÍTICA  
**Modo:** Executar sequencialmente  
**Arquitetura:** PRESERVAR  
**Banco remoto:** Supabase  
**Banco local:** IndexedDB/Dexie

---

# 0. CONTRATO DE EXECUÇÃO

Antes de iniciar, obedecer obrigatoriamente:

```text
NÃO criar nova arquitetura.
NÃO substituir Supabase.
NÃO substituir IndexedDB/Dexie.
NÃO remover Offline-First.
NÃO remover Outbox/Sync Queue.
NÃO desabilitar RLS para "resolver".
NÃO marcar eventos como synced sem confirmação do Supabase.
NÃO declarar sucesso sem executar os testes finais.
```

Se uma etapa falhar:

```text
STOP
↓
registrar erro
↓
diagnosticar
↓
corrigir
↓
reexecutar etapa
```

Não avançar ignorando uma falha.

---

# 1. PREPARAÇÃO

## 1.1 Abrir o projeto

Entrar no diretório:

```bash
cd agro2
```

Confirmar:

```bash
pwd
```

e:

```bash
git status
```

---

## 1.2 Criar checkpoint Git

Antes de qualquer alteração:

```bash
git add .
git commit -m "checkpoint-before-sync-fix"
```

Se não houver alterações:

```bash
git status
```

Registrar o estado.

---

# 2. INVENTÁRIO DA ARQUITETURA

Pesquisar:

```bash
grep -R "queueSyncEvent" src
grep -R "pushSyncToSupabase" src
grep -R "pullSyncFromSupabase" src
grep -R "subscribeToRealtimeSync" src
grep -R "agro2_sync_updated" src
```

Também localizar:

```bash
grep -R "supabase" src
grep -R "Dexie" src
grep -R "indexedDB" src
```

### CHECKPOINT

Gerar:

```text
SYNC_AUDIT.md
```

contendo:

- arquivos envolvidos;
- funções;
- tabelas;
- fluxo de push;
- fluxo de pull;
- realtime;
- outbox;
- fallback;
- autenticação.

Não modificar código nesta etapa.

---

# 3. IDENTIFICAR ENTIDADES SINCRONIZADAS

Localizar todas as entidades usadas pela sincronização.

Exemplo:

```text
animais
propriedades
...
```

Não assumir somente `animais`.

Criar:

```text
SYNC_ENTITIES.md
```

Formato:

```text
ENTIDADE
 ↓
IndexedDB
 ↓
Outbox
 ↓
Supabase
 ↓
Realtime
```

---

# 4. AUDITAR SUPABASE

Verificar configuração:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Confirmar que:

```text
development
production
Vercel
```

apontam para o mesmo projeto Supabase.

### PROIBIDO

Nunca utilizar:

```text
SUPABASE_SERVICE_ROLE_KEY
```

no frontend.

---

# 5. AUDITAR TABELA `animais`

No Supabase, verificar:

```text
Table Editor
→ animais
```

Confirmar:

```text
id
campos obrigatórios
tipos
constraints
primary key
```

Criar registro de teste somente se necessário.

---

# 6. AUDITAR RLS

Verificar policies da tabela `animais`.

Validar:

```text
SELECT
INSERT
UPDATE
DELETE
```

para o usuário autenticado.

### REGRA

Não executar:

```sql
ALTER TABLE animais DISABLE ROW LEVEL SECURITY;
```

como solução.

Se houver problema:

```text
identificar policy
corrigir policy
testar novamente
```

---

# 7. AUDITAR REALTIME

Verificar se `animais` está incluída em:

```text
supabase_realtime
```

Validar:

```text
INSERT
UPDATE
DELETE
```

---

# 8. TESTE DE CONECTIVIDADE

Criar/usar o mecanismo de diagnóstico existente.

Executar:

```text
Supabase connection test
```

Resultado obrigatório:

```text
SUPABASE = CONNECTED
```

Se:

```text
SUPABASE = ERROR
```

PARAR.

Corrigir antes de continuar.

---

# 9. AUDITAR PUSH

Abrir:

```text
src/lib/supabaseSync.js
```

e:

```text
src/contexts/SyncContext.jsx
```

Localizar:

```text
pushSyncToSupabase()
```

Confirmar fluxo:

```text
Outbox
 ↓
Payload
 ↓
Supabase upsert
 ↓
response
 ↓
error check
 ↓
synced
```

---

# 10. CORREÇÃO CRÍTICA — STATUS SYNCED

Pesquisar todo o projeto:

```bash
grep -R "status.*synced" src
grep -R "'synced'" src
grep -R "\"synced\"" src
```

Encontrar qualquer trecho que faça:

```text
evento → synced
```

sem confirmação real do Supabase.

Corrigir.

### REGRA

Somente:

```text
Supabase confirmou sucesso
        ↓
status = synced
```

Erro:

```text
Supabase error
        ↓
status = error/pending
```

---

# 11. CORREÇÃO CRÍTICA — FALLBACK

Localizar qualquer fallback semelhante a:

```text
Consolida a outbox localmente
```

Verificar se ele está marcando eventos como sincronizados sem envio remoto.

Se estiver:

```text
REMOVER COMPORTAMENTO INCORRETO
```

Não remover o fallback offline.

O comportamento correto é:

```text
offline
 ↓
salva localmente
 ↓
pending
 ↓
internet retorna
 ↓
push
 ↓
Supabase
 ↓
synced
```

---

# 12. CORREÇÃO DO PUSH

Garantir que:

```text
pushSyncToSupabase()
```

capture:

```text
network error
RLS error
constraint error
validation error
authentication error
Supabase error
```

Nenhum erro pode ser silenciosamente ignorado.

Registrar:

```text
entity
record id
operation
error
timestamp
attempt
```

---

# 13. RETRY

Implementar/ajustar retry utilizando a outbox existente.

Fluxo:

```text
pending
 ↓
processing
 ↓
SUCCESS
 ↓
synced
```

Erro:

```text
processing
 ↓
error
 ↓
pending
 ↓
retry
```

Utilizar backoff.

Evitar loop agressivo.

---

# 14. IDEMPOTÊNCIA

Confirmar que:

```text
upsert
+
id estável
```

não gera duplicação.

Teste:

```text
mesmo evento enviado 3 vezes
```

Resultado:

```text
1 registro
```

---

# 15. AUDITAR IDs

Pesquisar geração de IDs:

```bash
grep -R "uuid" src
grep -R "crypto.randomUUID" src
grep -R "randomUUID" src
```

Confirmar:

```text
ID local
=
ID enviado ao Supabase
=
ID recebido pelo outro dispositivo
```

Nunca gerar novo ID durante sincronização.

---

# 16. AUDITAR PULL

Localizar:

```text
pullSyncFromSupabase()
```

Confirmar:

```text
Supabase SELECT
 ↓
dados remotos
 ↓
IndexedDB
 ↓
evento de atualização
```

O pull não pode apagar registros locais pendentes.

---

# 17. AUDITAR REALTIME

Localizar:

```text
subscribeToRealtimeSync()
```

Confirmar:

```text
INSERT
UPDATE
DELETE
```

e:

```text
reconnect
unsubscribe
resubscribe
```

Não criar subscriptions duplicadas.

---

# 18. TESTE REALTIME

Abrir:

```text
PC
+
CELULAR
```

simultaneamente.

No PC:

```text
ANIMAL-SYNC-REALTIME-001
```

Cadastrar.

Resultado esperado:

```text
PC
 ↓
Supabase
 ↓
Realtime
 ↓
CELULAR
```

Sem reload manual.

---

# 19. TESTE PUSH PC

Criar:

```text
ANIMAL-SYNC-PC-001
```

No PC confirmar:

```text
IndexedDB = OK
Outbox = synced
Supabase = OK
```

Depois verificar no celular.

Resultado:

```text
CELULAR = OK
```

---

# 20. TESTE PUSH CELULAR

Criar:

```text
ANIMAL-SYNC-MOBILE-001
```

No celular:

```text
IndexedDB = OK
Outbox = synced
Supabase = OK
```

No PC:

```text
ANIMAL-SYNC-MOBILE-001 = PRESENTE
```

---

# 21. TESTE UPDATE

PC:

```text
ANIMAL-SYNC-PC-001
```

alterar um campo.

Verificar:

```text
Supabase
 ↓
Realtime
 ↓
celular
```

Resultado:

```text
UPDATE = OK
```

---

# 22. TESTE DELETE

Excluir o mesmo animal.

Verificar:

```text
PC
 ↓
Supabase DELETE
 ↓
Realtime DELETE
 ↓
CELULAR
```

Resultado:

```text
registro removido
```

Não permitir que o pull faça o registro reaparecer.

---

# 23. TESTE OFFLINE — PC

Desconectar internet.

Cadastrar:

```text
ANIMAL-OFFLINE-PC-001
```

Resultado:

```text
IndexedDB = PRESENTE
Outbox = PENDING
Supabase = NÃO ENVIADO
```

Reconectar internet.

Resultado:

```text
Outbox = SYNCED
Supabase = PRESENTE
```

---

# 24. TESTE OFFLINE — CELULAR

Repetir:

```text
offline
 ↓
cadastro
 ↓
IndexedDB
 ↓
pending
 ↓
online
 ↓
push
 ↓
Supabase
 ↓
synced
```

---

# 25. TESTE RELOAD

Para cada dispositivo:

```text
F5
```

depois:

```text
fechar navegador
abrir novamente
```

Confirmar persistência.

---

# 26. TESTE DE PERDA DE CONEXÃO

Durante sincronização:

```text
online
 ↓
iniciar push
 ↓
desconectar internet
```

O sistema deve:

```text
não perder evento
não marcar synced incorretamente
manter retry
```

---

# 27. TESTE DE ERRO RLS

Provocar/identificar erro de autorização.

Resultado obrigatório:

```text
status != synced
```

e log:

```text
[SYNC:ERROR]
```

---

# 28. TESTE DE DUPLICAÇÃO

Enviar o mesmo registro/evento repetidamente.

Resultado:

```text
1 registro remoto
1 registro local
```

Nunca:

```text
2+
```

---

# 29. TESTE DE CONCORRÊNCIA

Abrir PC e celular.

Alterar registros.

Testar:

```text
PC → alteração
CELULAR → alteração
```

Garantir que não ocorra corrupção silenciosa.

Se conflito existir:

```text
registrar
```

e aplicar a estratégia de resolução já compatível com o projeto.

---

# 30. DIAGNÓSTICO FINAL

O sistema deve conseguir informar:

```text
SUPABASE: CONNECTED
REALTIME: CONNECTED
OUTBOX: 0 PENDING
LAST PUSH: OK
LAST PULL: OK
LAST REALTIME: OK
```

Se houver pendência:

```text
OUTBOX: 1 PENDING
```

deve ser verdadeira.

Nunca mascarar.

---

# 31. BUILD

Executar:

```bash
npm install
npm run build
```

Se o projeto possuir lint:

```bash
npm run lint
```

Corrigir todos os erros introduzidos.

---

# 32. TESTE DE PRODUÇÃO

Executar build de produção.

Publicar somente depois de:

```text
BUILD = PASS
TESTES = PASS
```

---

# 33. TESTE FINAL DE PRODUÇÃO

No endereço real do AGRO2:

```text
PC
+
CELULAR
```

executar novamente:

```text
CREATE
UPDATE
DELETE
REALTIME
OFFLINE
RECONNECT
RELOAD
```

Não considerar os testes locais suficientes.

---

# 34. CRITÉRIO DE APROVAÇÃO

Todos devem estar:

```text
PASS
```

| Teste | Resultado |
|---|---|
| Supabase Connection | PASS |
| RLS SELECT | PASS |
| RLS INSERT | PASS |
| RLS UPDATE | PASS |
| RLS DELETE | PASS |
| Realtime | PASS |
| PC → Supabase | PASS |
| Supabase → PC | PASS |
| Celular → Supabase | PASS |
| Supabase → Celular | PASS |
| PC → Celular | PASS |
| Celular → PC | PASS |
| UPDATE | PASS |
| DELETE | PASS |
| Offline PC | PASS |
| Offline Celular | PASS |
| Reconnect | PASS |
| Retry | PASS |
| Idempotência | PASS |
| Duplicação | PASS |
| Reload | PASS |
| Build | PASS |
| Produção | PASS |

---

# 35. GIT COMMIT

Somente depois de todos os testes:

```bash
git status
```

Revisar alterações.

Depois:

```bash
git add .
git commit -m "fix: restore bidirectional Supabase synchronization"
```

---

# 36. RELATÓRIO FINAL

Criar:

```text
SYNC_FIX_REPORT.md
```

Conteúdo mínimo:

```markdown
# AGRO2 Sync Fix Report

## Causa raiz

[descrição]

## Problemas encontrados

- [problema]
- [problema]

## Correções

- [correção]
- [correção]

## Arquivos alterados

- arquivo
- arquivo

## Supabase

### RLS
[resultado]

### Realtime
[resultado]

## Testes

| Teste | Resultado |
|---|---|
| PC → Supabase | PASS |
| Supabase → PC | PASS |
| Celular → Supabase | PASS |
| Supabase → Celular | PASS |
| Realtime | PASS |
| Offline | PASS |
| Retry | PASS |
| DELETE | PASS |
| UPDATE | PASS |

## Resultado

PASS / FAIL

## Pendências

[nenhuma ou listar]
```

---

# 37. DEFINIÇÃO FINAL DE PRONTO

Somente declarar:

```text
SYNC FIX = COMPLETE
```

se:

```text
PC
 ↓
Supabase
 ↓
CELULAR
```

funcionar,

e:

```text
CELULAR
 ↓
Supabase
 ↓
PC
```

funcionar.

Além disso:

```text
OFFLINE
 ↓
OUTBOX
 ↓
RECONNECT
 ↓
SUPABASE
 ↓
OUTROS DISPOSITIVOS
```

deve funcionar.

---

# 38. REGRA DE SEGURANÇA

Se qualquer teste crítico resultar em:

```text
FAIL
```

não declarar conclusão.

Usar:

```text
SYNC FIX = BLOCKED
```

e informar:

1. etapa;
2. erro;
3. causa provável;
4. evidência;
5. arquivo envolvido;
6. ação necessária.

---

# 39. SAÍDA ESPERADA DO ANTIGRAVITY

Ao terminar, retornar somente um resumo operacional:

```text
STATUS: PASS / FAIL / BLOCKED

ROOT CAUSE:
...

FIXES:
...

FILES CHANGED:
...

SUPABASE:
...

RLS:
...

REALTIME:
...

TESTS:
...

BUILD:
...

PRODUCTION:
...

COMMIT:
...

PENDENCIES:
...
```

Não omitir falhas.

Não declarar PASS baseado em testes parciais.

**FIM DO RUNBOOK**