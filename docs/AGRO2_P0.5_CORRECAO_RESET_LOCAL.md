# AGRO2 — CORREÇÃO P0.5 — RESET LOCAL APÓS LIMPEZA DO SUPABASE

## Objetivo

O Supabase foi zerado deliberadamente, preservando somente `usuarios`.

Entretanto, PC e celular continuam exibindo dados antigos porque o IndexedDB/Dexie local ainda contém registros operacionais.

A correção deve fazer o estado local convergir para o Supabase vazio **sem permitir que dados antigos da outbox sejam reenviados**.

## Regra fundamental

Neste ciclo, o Supabase é a fonte de verdade.

Estado desejado inicial:

- `usuarios`: preservar.
- Todas as demais entidades: vazias.
- `sync_queue`: vazia.
- IndexedDB operacional: vazio.
- Nenhum registro antigo pode ser republicado no Supabase.

## Problema encontrado no código atual

`pullSyncFromSupabase()` somente faz `put()` dos registros encontrados no Supabase. Ele não remove do IndexedDB registros que deixaram de existir no servidor.

Além disso, `pushSyncToSupabase()` processa `sync_queue` e também faz reconciliação de registros locais `pending/error`. Portanto, simplesmente fazer um pull não é suficiente: registros antigos locais podem voltar para o Supabase.

Arquivos principais:

- `agro2/src/contexts/SyncContext.jsx`
- `agro2/src/lib/supabaseSync.js`
- `agro2/src/db/database.js`

## Correção solicitada

### 1. Criar rotina explícita de reconciliação/reset local

Adicionar em `supabaseSync.js` uma função, por exemplo:

`resetLocalOperationalDataIfServerIsEmpty()`

Ela deve:

1. Consultar o Supabase para todas as tabelas operacionais:
   - `fazendas`
   - `piquetes`
   - `lotes`
   - `animais`
   - `produtos`
   - `aplicacoes_sanitarias`
   - `ocorrencias_sanitarias`
   - `dietas`
   - `fornecimentos_dieta`
   - `pesagens`
   - `estoque_movimentos`
   - `financeiro_lancamentos`

2. Confirmar que todas estão vazias.

3. SOMENTE se todas estiverem vazias:
   - limpar todas essas tabelas do IndexedDB;
   - limpar `sync_queue`;
   - NÃO limpar `usuarios`;
   - NÃO alterar schema;
   - NÃO alterar RLS.

4. Registrar logs claros:

`[LOCAL RESET] Supabase operacional vazio — iniciando limpeza do IndexedDB`

`[LOCAL RESET] entidade: animais registros removidos: N`

`[LOCAL RESET] entidade: financeiro_lancamentos registros removidos: N`

`[LOCAL RESET] sync_queue limpa`

`[LOCAL RESET] CONCLUÍDO`

### 2. Ordem obrigatória da sincronização

O reset deve ocorrer ANTES de qualquer:

- `pushSyncToSupabase()`
- processamento da `sync_queue`
- reconciliação local → nuvem.

Ordem:

1. verificar se Supabase está operacionalmente vazio;
2. se vazio, limpar IndexedDB operacional + `sync_queue`;
3. depois executar pull;
4. somente depois permitir push normal.

Isso é essencial para impedir a ressurreição dos dados antigos.

### 3. Não apagar usuários

`usuarios` deve permanecer intacta no IndexedDB e no Supabase.

Não executar:

`db.usuarios.clear()`

### 4. Evitar reset destrutivo durante operação normal

Não transformar a rotina em um mecanismo que apaga dados sempre que uma tabela específica estiver vazia.

A condição deve ser:

**TODAS as 12 tabelas operacionais estão vazias no Supabase.**

Se qualquer uma possuir registro, NÃO executar reset global.

### 5. Após o reset, o pull deve ficar correto

Além do reset inicial, corrigir `pullSyncFromSupabase()` para que a sincronização trate exclusões remotas corretamente.

Não basta fazer `put()` dos registros encontrados.

Para cada tabela operacional, quando o servidor retornar vazio, o estado local correspondente deve ficar vazio — desde que não existam alterações locais legítimas pendentes criadas depois do reset.

### 6. Outbox

Depois do reset:

`sync_queue.count()` deve ser `0`.

Nenhum ID antigo de teste deve permanecer.

Não recriar eventos de sincronização a partir dos registros antigos.

### 7. Cache do aplicativo

Não usar apenas `window.location.reload()` como solução.

O problema é persistência no IndexedDB, portanto a correção precisa atuar diretamente no Dexie.

### 8. Compatibilidade

Não alterar:

- arquitetura geral;
- Supabase;
- schema PostgreSQL;
- RLS;
- contratos `DB_COLUMNS`;
- fluxo normal de criação;
- mecanismo Realtime;
- módulos funcionais.

É uma correção do ciclo de reconciliação/reset local.

## Critérios de aceite

### PC

Após publicar a correção e abrir o sistema:

- Animais = 0
- Financeiro = 0
- Produtos = 0
- Fazendas = 0
- demais entidades operacionais = 0
- Usuários continuam disponíveis.

### Celular

Mesmo resultado:

- Animais = 0
- Financeiro = 0
- demais entidades operacionais = 0
- Usuários preservados.

### Supabase

Continuar:

- todas as tabelas operacionais = 0;
- `usuarios` = 2.

### Outbox

IndexedDB:

- `sync_queue` = 0.

### PROIBIDO

Não criar dados de teste.

Não criar lançamento financeiro fictício.

Não criar animal fictício.

Não executar testes que gravem dados permanentes no banco.

## Validação final

Depois da implementação:

1. build do projeto;
2. verificar que não há erro de compilação;
3. publicar;
4. abrir PC;
5. confirmar estado vazio;
6. abrir celular;
7. confirmar estado vazio;
8. confirmar Supabase ainda vazio;
9. somente então iniciar novos testes funcionais com dados reais criados durante a validação.

## Commit

`fix: p0.5 reset local cache after server purge`
