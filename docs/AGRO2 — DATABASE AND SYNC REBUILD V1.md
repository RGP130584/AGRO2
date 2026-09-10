# AGRO2 — DATABASE AND SYNC REBUILD V1

## Auditoria completa, reconstrução controlada do banco e sincronização

**Projeto:** AGRO2  
**Versão:** V1  
**Executor:** Antigravity  
**Prioridade:** CRÍTICA  
**Objetivo:** Encontrar e corrigir definitivamente as divergências entre o AGRO2, Supabase, IndexedDB/Dexie e Supabase Realtime.

---

# 0. PRINCÍPIO FUNDAMENTAL

O problema atual de sincronização NÃO será tratado como um simples problema de código.

O Antigravity deve assumir inicialmente que a falha pode estar em qualquer camada:

```text
FRONTEND
   ↓
MODELO DE DADOS
   ↓
INDEXEDDB / DEXIE
   ↓
OUTBOX
   ↓
SYNC ENGINE
   ↓
SUPABASE CLIENT
   ↓
POSTGRESQL
   ↓
RLS
   ↓
REALTIME
   ↓
SYNC ENGINE
   ↓
INDEXEDDB
   ↓
INTERFACE
```

Portanto:

> **AUDITAR TODA A CADEIA ANTES DE CORRIGIR.**

---

# 1. REGRA ABSOLUTA DE EXECUÇÃO

## NÃO começar alterando código.

## NÃO começar alterando tabelas.

## NÃO apagar dados.

## NÃO apagar tabelas.

## NÃO recriar o banco.

## NÃO desabilitar RLS.

## NÃO criar policies públicas como solução definitiva.

## NÃO substituir Supabase.

## NÃO substituir IndexedDB/Dexie.

## NÃO criar Firebase ou outro backend.

Primeiro:

```text
BACKUP
↓
INVENTÁRIO
↓
COMPARAÇÃO
↓
DIAGNÓSTICO
↓
PLANO DE CORREÇÃO
↓
APROVAÇÃO INTERNA DO PLANO
↓
EXECUÇÃO
↓
TESTES
```

---

# 2. OBJETIVO FINAL

O AGRO2 deve possuir um único estado de dados consistente entre:

```text
COMPUTADOR
CELULAR
SUPABASE
```

com suporte a:

```text
CREATE
UPDATE
DELETE
PULL
REALTIME
OFFLINE
RECONNECT
RETRY
IDEMPOTÊNCIA
```

---

# 3. EVIDÊNCIA ATUAL

Já foi confirmado em teste real:

```text
CREATE PC → CELULAR = PASS
CREATE CELULAR → PC = PASS
```

Porém:

```text
UPDATE CELULAR → PC = FAIL
```

Caso concreto:

```text
Animal:
Sucuri

Alteração:
colocada em carência

Resultado:
CELULAR = atualizado
COMPUTADOR = não atualizado
```

Portanto, não assumir que o CREATE e o UPDATE utilizam exatamente o mesmo caminho.

---

# 4. FASE 0 — BACKUP

Antes de qualquer alteração:

## 4.1 Código

Criar checkpoint Git:

```bash
git status
git add .
git commit -m "checkpoint-before-database-sync-rebuild"
```

Registrar commit.

---

## 4.2 Supabase

Realizar backup completo do estado atual.

Preservar:

- schema;
- tabelas;
- dados;
- constraints;
- foreign keys;
- índices;
- policies;
- triggers;
- funções;
- publications;
- configurações relevantes.

Criar documentação:

```text
SUPABASE_BACKUP_INFO.md
```

Registrar:

```text
data
projeto
schema
quantidade de tabelas
método utilizado
local/referência do backup
```

### CRITÉRIO

Não prosseguir se não houver evidência de backup.

---

# 5. FASE 1 — INVENTÁRIO COMPLETO DO CÓDIGO

Pesquisar todo o projeto.

Executar buscas equivalentes a:

```bash
grep -R "supabase" src
grep -R "from(" src
grep -R "insert(" src
grep -R "update(" src
grep -R "upsert(" src
grep -R "delete(" src
grep -R "select(" src
grep -R "Dexie" src
grep -R "indexedDB" src
grep -R "queueSyncEvent" src
grep -R "pushSyncToSupabase" src
grep -R "pullSyncFromSupabase" src
grep -R "subscribeToRealtimeSync" src
```

Também procurar:

```text
fazenda_id
user_id
created_at
updated_at
deleted_at
status
id
```

---

# 6. INVENTÁRIO DAS ENTIDADES

Identificar todas as entidades utilizadas pelo sistema.

Não assumir que existem somente 13 tabelas.

Criar:

```text
AGRO2_DATA_MODEL_CODE.md
```

Formato:

```text
ENTIDADE

Nome:
Tabela esperada:
IndexedDB:
Campos:
Primary Key:
Foreign Keys:
CREATE:
UPDATE:
DELETE:
SELECT:
Realtime:
Outbox:
```

---

# 7. INVENTÁRIO DOS CAMPOS

Para cada entidade, listar todos os campos utilizados pelo frontend.

Exemplo:

```text
ANIMAIS

id
nome
brinco
sexo
raca
data_nascimento
fazenda_id
status
carencia
...
```

Não confiar somente nos formulários.

Pesquisar:

- forms;
- dashboards;
- listas;
- filtros;
- hooks;
- services;
- contexts;
- queries;
- relatórios;
- componentes.

---

# 8. ESPECIAL ATENÇÃO AO CAMPO DE CARÊNCIA

Descobrir exatamente como o AGRO2 representa:

```text
CARÊNCIA
```

Pode ser:

```text
carencia
em_carencia
data_fim_carencia
dias_carencia
status_carencia
```

ou combinação desses campos.

Documentar:

```text
Frontend:
?

IndexedDB:
?

Outbox:
?

Supabase:
?

Realtime:
?
```

Esse ponto é obrigatório porque o caso real que falhou envolve carência.

---

# 9. INVENTÁRIO DO INDEXEDDB / DEXIE

Localizar a definição do banco local.

Documentar:

```text
tabelas/stores
primary keys
índices
campos
relacionamentos
versionamento
migrações
```

Criar:

```text
AGRO2_INDEXEDDB_SCHEMA.md
```

---

# 10. INVENTÁRIO DO SUPABASE

Obter o schema REAL do banco.

Não confiar no que o código diz que existe.

Para cada tabela:

```text
nome
colunas
tipo
nullable
default
primary key
foreign key
unique
check constraints
indexes
```

Criar:

```text
AGRO2_SUPABASE_SCHEMA.md
```

---

# 11. COMPARAÇÃO CÓDIGO × SUPABASE

Criar matriz:

| Entidade | Código | Supabase | Resultado |
|---|---|---|---|
| animais | existe | existe | ? |
| propriedades | existe | existe | ? |
| lotes | existe | existe | ? |
| pesagens | existe | existe | ? |
| dietas | existe | existe | ? |

Depois detalhar colunas:

| Tabela | Campo | Código | Supabase | Resultado |
|---|---|---|---|---|
| animais | id | UUID | UUID | OK |
| animais | nome | TEXT | TEXT | OK |
| animais | carencia | ? | ? | ? |

---

# 12. CLASSIFICAÇÃO DE DIVERGÊNCIAS

Toda diferença deve ser classificada como:

```text
CRITICAL
HIGH
MEDIUM
LOW
```

### CRITICAL

- tabela inexistente;
- coluna inexistente usada pelo sistema;
- primary key incorreta;
- foreign key incorreta;
- tipo incompatível;
- UPDATE impossível;
- RLS impedindo operação;
- Realtime incompatível.

### HIGH

- índice ausente;
- nullable divergente;
- default divergente;
- campo utilizado em filtro inconsistente.

---

# 13. INVENTÁRIO DE RELACIONAMENTOS

Mapear:

```text
fazenda
 ↓
propriedade
 ↓
lote
 ↓
animal
```

e todos os demais relacionamentos.

Verificar se as foreign keys realmente representam o relacionamento esperado pelo AGRO2.

Especial atenção:

```text
fazenda_id
user_id
propriedade_id
animal_id
lote_id
```

---

# 14. AUDITORIA DE `fazenda_id`

Pesquisar TODO o código por:

```text
faz-1
```

e:

```text
fazenda_id
```

Não aceitar nenhum ID de fazenda hardcoded.

Toda vinculação deve utilizar o contexto correto do usuário:

```text
getActiveFazendaId()
```

ou mecanismo equivalente existente.

Depois verificar:

```text
PC fazenda_id
CELULAR fazenda_id
SUPABASE fazenda_id
```

---

# 15. AUDITORIA DE RLS

Listar todas as policies existentes.

Para cada tabela:

```text
SELECT
INSERT
UPDATE
DELETE
```

documentar:

```text
policy
USING
WITH CHECK
role
```

---

# 16. IMPORTANTE — POLICIES PÚBLICAS

As policies atuais:

```sql
USING (true)
WITH CHECK (true)
```

foram aceitas somente como diagnóstico temporário.

NÃO considerar isso arquitetura de segurança definitiva.

Depois de confirmar o funcionamento da sincronização, substituir por políticas baseadas no contexto real de:

```text
usuário
fazenda
permissão
```

sem quebrar a sincronização.

---

# 17. AUDITORIA DE REALTIME

Verificar:

```text
supabase_realtime
```

para todas as tabelas relevantes.

Documentar:

```text
tabela
INSERT
UPDATE
DELETE
publication
```

Especialmente:

```text
animais
```

---

# 18. AUDITORIA DO SYNC ENGINE

Localizar:

```text
SyncContext
supabaseSync
outbox
Realtime
```

Mapear:

```text
CREATE
UPDATE
DELETE
PULL
REALTIME
RETRY
RECONNECT
```

Criar:

```text
AGRO2_SYNC_CURRENT_ARCHITECTURE.md
```

---

# 19. REGRA PARA CREATE / UPDATE / DELETE

Os três devem utilizar o mesmo contrato:

```text
Local Mutation
 ↓
Outbox Event
 ↓
Sync Engine
 ↓
Supabase
 ↓
Confirmation
 ↓
Synced
```

Não pode existir:

```text
CREATE → caminho A

UPDATE → caminho B

DELETE → caminho C
```

sem justificativa explícita.

---

# 20. AUDITORIA DO PAYLOAD

Para cada operação registrar:

```text
entity
operation
id
payload
```

Comparar:

```text
CREATE
UPDATE
DELETE
```

Descobrir se algum campo existe no CREATE mas não no UPDATE.

---

# 21. TESTE ESPECÍFICO DA SUCURI

Usar o animal existente ou criar um registro de teste.

Executar:

```text
Sucuri
```

alterar:

```text
carência
```

Registrar:

```text
valor antes
valor depois
```

---

# 22. RASTREAMENTO DO UPDATE

Acompanhar:

```text
CELULAR
 ↓
React
 ↓
AnimalForm
 ↓
IndexedDB
 ↓
Outbox
 ↓
pushSyncToSupabase
 ↓
Supabase
 ↓
Realtime
 ↓
PC
 ↓
IndexedDB
 ↓
RebanhoList
```

Em cada ponto registrar:

```text
PASS / FAIL
valor
id
timestamp
```

---

# 23. TESTE DO SUPABASE DIRETO

Após o UPDATE da Sucuri:

consultar diretamente:

```text
animais
```

pelo ID.

Registrar:

```text
id
carência
fazenda_id
updated_at
```

Se Supabase estiver correto:

```text
PUSH = PASS
```

Se estiver incorreto:

```text
PUSH = FAIL
```

---

# 24. TESTE DO REALTIME

Se Supabase estiver atualizado:

verificar se o PC recebe:

```text
event = UPDATE
```

com:

```text
table = animais
record = registro atualizado
```

Se não receber:

```text
REALTIME = FAIL
```

---

# 25. TESTE DO INDEXEDDB DO PC

Se Realtime recebeu o evento:

verificar se:

```text
IndexedDB PC
```

foi atualizado.

Se não:

```text
REALTIME → INDEXEDDB = FAIL
```

---

# 26. TESTE DA INTERFACE

Se IndexedDB estiver correto:

verificar:

```text
RebanhoList
```

e todos os filtros.

Se IndexedDB estiver correto mas a tela estiver errada:

```text
UI/FILTER = FAIL
```

---

# 27. DIAGNÓSTICO DO PONTO DE FALHA

Classificar exatamente:

```text
A — FRONTEND
B — INDEXEDDB
C — OUTBOX
D — PUSH
E — SUPABASE
F — RLS
G — REALTIME
H — PULL
I — INDEXEDDB DESTINO
J — UI/FILTER
```

Não aceitar:

```text
"problema de sincronização"
```

como causa raiz.

A causa deve apontar para uma camada específica.

---

# 28. DECISÃO DE RECONSTRUÇÃO

Depois da auditoria:

## Caso A

Banco correto + Sync incorreto:

```text
corrigir/reconstruir Sync Engine
```

## Caso B

Banco incorreto + Sync correto:

```text
corrigir schema
```

## Caso C

Banco incorreto + Sync incorreto:

```text
corrigir banco
+
reconstruir Sync Engine
```

## Caso D

Banco muito inconsistente:

```text
propor reconstrução controlada do schema
```

preservando os dados válidos.

---

# 29. RECONSTRUÇÃO DO BANCO — SOMENTE SE NECESSÁRIO

Se for necessária reconstrução:

```text
BACKUP
 ↓
NOVO SCHEMA CORRETO
 ↓
VALIDAÇÃO
 ↓
MIGRAÇÃO DOS DADOS VÁLIDOS
 ↓
VALIDAÇÃO
 ↓
APLICAÇÃO
```

Nunca:

```text
DROP DATABASE
```

sem backup e sem plano de recuperação.

---

# 30. CONTRATO FINAL DE DADOS

Criar:

```text
AGRO2_DATA_CONTRACT_V1.md
```

Definir:

```text
entidade
campo
tipo
obrigatório
default
PK
FK
semântica
CREATE
UPDATE
DELETE
Realtime
```

Esse documento passa a ser a referência oficial para o frontend e Supabase.

---

# 31. NOVO CONTRATO DE OUTBOX

Cada evento deve possuir, no mínimo:

```text
event_id
entity
record_id
operation
payload
status
attempts
created_at
updated_at
last_error
```

Se já existirem campos equivalentes, reutilizar.

Não duplicar mecanismos.

---

# 32. ESTADOS

Utilizar:

```text
pending
processing
synced
error
```

Fluxo:

```text
pending
 ↓
processing
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
```

---

# 33. REGRA DE `synced`

Só:

```text
Supabase confirmou
+
error == null
+
operação aceita
```

pode produzir:

```text
synced
```

---

# 34. RETRY

Implementar:

```text
retry
backoff
reconnect
```

Sem loops infinitos.

Eventos com erro devem permanecer recuperáveis.

---

# 35. REALTIME

Realtime deve:

```text
receber evento
 ↓
validar entidade
 ↓
validar record_id
 ↓
aplicar no IndexedDB
 ↓
disparar atualização
```

Não gravar cegamente payload inválido.

---

# 36. PULL

No início da aplicação:

```text
Supabase
 ↓
Pull
 ↓
Merge
 ↓
IndexedDB
```

O Pull não pode apagar mudanças locais pendentes.

---

# 37. CONFLITOS

Documentar estratégia.

No mínimo:

```text
record_id
updated_at
origem
```

Devem permitir detectar conflito.

Não perder silenciosamente uma alteração.

---

# 38. CACHE / PWA

Auditar:

```text
Service Worker
Cache Storage
localStorage
IndexedDB
```

Confirmar que dados antigos não estejam sendo apresentados pela interface.

---

# 39. AUTENTICAÇÃO

Confirmar:

```text
PC
CELULAR
```

utilizam o mesmo projeto Supabase.

Confirmar:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Não expor service role key.

---

# 40. IMPLEMENTAÇÃO

Somente depois de concluir:

```text
AGRO2_DATABASE_AUDIT.md
AGRO2_DATA_MODEL_CODE.md
AGRO2_SUPABASE_SCHEMA.md
AGRO2_INDEXEDDB_SCHEMA.md
AGRO2_DATA_CONTRACT_V1.md
AGRO2_SYNC_CURRENT_ARCHITECTURE.md
```

implementar as correções.

---

# 41. TESTES UNITÁRIOS

Testar:

```text
CREATE
UPDATE
DELETE
PUSH
PULL
OUTBOX
RETRY
REALTIME
```

---

# 42. TESTE E2E — CREATE

```text
PC
 ↓
Supabase
 ↓
CELULAR
```

PASS obrigatório.

Depois:

```text
CELULAR
 ↓
Supabase
 ↓
PC
```

PASS obrigatório.

---

# 43. TESTE E2E — UPDATE

```text
PC
 ↓
UPDATE
 ↓
Supabase
 ↓
CELULAR
```

PASS.

Depois:

```text
CELULAR
 ↓
UPDATE
 ↓
Supabase
 ↓
PC
```

PASS.

---

# 44. TESTE E2E — DELETE

Executar nos dois sentidos.

---

# 45. TESTE ESPECÍFICO — CARÊNCIA

Obrigatório.

```text
CELULAR
 ↓
Sucuri
 ↓
Carência
 ↓
Supabase
 ↓
Realtime
 ↓
PC
```

O PC deve apresentar exatamente o novo estado.

Depois fazer o inverso.

---

# 46. TESTE OFFLINE

PC offline:

```text
cadastro
 ↓
IndexedDB
 ↓
pending
```

Reconectar:

```text
pending
 ↓
push
 ↓
Supabase
 ↓
synced
```

Repetir no celular.

---

# 47. TESTE REALTIME

Dois dispositivos abertos.

Criar:

```text
SYNC-REALTIME-001
```

Sem reload.

Depois:

```text
UPDATE
```

Sem reload.

Depois:

```text
DELETE
```

Sem reload.

---

# 48. TESTE DE DUPLICAÇÃO

Enviar o mesmo evento repetidamente.

Resultado:

```text
1 registro
```

---

# 49. TESTE DE RELOAD

Após sincronização:

```text
F5
```

Fechar navegador.

Reabrir.

Confirmar persistência.

---

# 50. TESTE DE RECONEXÃO

```text
ONLINE
 ↓
OFFLINE
 ↓
UPDATE
 ↓
ONLINE
```

Confirmar sincronização automática.

---

# 51. TESTE DE PRODUÇÃO

Testar no endereço publicado:

```text
https://agro-2-sable.vercel.app/
```

Não considerar apenas localhost.

---

# 52. SEGURANÇA FINAL

Depois de comprovar a sincronização:

substituir as policies públicas temporárias por RLS real.

Modelo conceitual:

```text
usuário autenticado
        ↓
fazenda autorizada
        ↓
registro autorizado
```

Nunca utilizar:

```text
USING (true)
WITH CHECK (true)
```

como configuração definitiva de produção.

---

# 53. LIMPEZA

Remover:

- dados fictícios;
- logs excessivos de debug;
- código morto;
- mecanismos duplicados;
- fallback incorreto;
- hardcodes;
- testes temporários.

Não remover logs de erro importantes.

---

# 54. BUILD

Executar:

```bash
npm install
npm run lint
npm run build
```

Todos devem passar.

---

# 55. DEPLOY

Publicar somente depois de:

```text
DATABASE = PASS
SYNC = PASS
REALTIME = PASS
E2E = PASS
BUILD = PASS
```

---

# 56. TESTE FINAL DE PRODUÇÃO

Executar:

```text
PC CREATE
CELULAR CREATE

PC UPDATE
CELULAR UPDATE

PC DELETE
CELULAR DELETE

PC OFFLINE
CELULAR OFFLINE

REALTIME
RECONNECT
RELOAD
```

---

# 57. CRITÉRIO ABSOLUTO DE SUCESSO

Somente declarar:

```text
AGRO2 DATABASE + SYNC = PASS
```

se TODOS forem PASS:

| Área | Resultado |
|---|---|
| Schema | PASS |
| Tabelas | PASS |
| Colunas | PASS |
| PK | PASS |
| FK | PASS |
| Índices | PASS |
| IndexedDB | PASS |
| Outbox | PASS |
| CREATE | PASS |
| UPDATE | PASS |
| DELETE | PASS |
| PUSH | PASS |
| PULL | PASS |
| Realtime | PASS |
| RLS | PASS |
| Retry | PASS |
| Offline | PASS |
| Reconnect | PASS |
| Idempotência | PASS |
| PC → Celular | PASS |
| Celular → PC | PASS |
| Carência | PASS |
| Produção | PASS |

---

# 58. RELATÓRIO FINAL

Criar:

```text
AGRO2_DATABASE_SYNC_FINAL_REPORT.md
```

Com:

## Causa raiz

Descrever o problema real.

## Banco

Informar:

- tabelas;
- colunas;
- alterações;
- relacionamentos;
- RLS;
- Realtime.

## Código

Listar arquivos alterados.

## Sync Engine

Descrever:

- Push;
- Pull;
- Outbox;
- Retry;
- Realtime.

## Testes

Tabela completa PASS/FAIL.

## Evidências

Informar IDs de testes e resultados.

## Segurança

Informar policies finais.

## Deploy

Informar versão/commit/deploy.

## Pendências

Nenhuma ou listar claramente.

---

# 59. REGRA FINAL

Não aceitar frases genéricas como:

```text
"sincronização corrigida"
```

ou:

```text
"Supabase conectado"
```

como evidência.

A prova precisa ser:

```text
REGISTRO
 ↓
DISPOSITIVO A
 ↓
SUPABASE
 ↓
DISPOSITIVO B
```

e:

```text
REGISTRO
 ↓
DISPOSITIVO B
 ↓
SUPABASE
 ↓
DISPOSITIVO A
```

para:

```text
CREATE
UPDATE
DELETE
```

incluindo especificamente:

```text
CARÊNCIA
```

---

# 60. DEFINIÇÃO FINAL DE PRONTO

O trabalho só estará concluído quando:

```text
                    SUPABASE
                       │
              ┌────────┴────────┐
              │                 │
              ▼                 ▼
          COMPUTADOR          CELULAR
              │                 │
           IndexedDB         IndexedDB
              │                 │
            Outbox            Outbox
              │                 │
              └──── Sync ───────┘
```

mantiver os três lados consistentes.

A sincronização deve ser:

**BIDIRECIONAL + PERSISTENTE + OFFLINE-FIRST + REALTIME + IDEMPOTENTE + RECUPERÁVEL + SEGURA.**

**FIM DO RUNBOOK**