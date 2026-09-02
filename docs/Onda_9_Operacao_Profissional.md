# Onda 9 — Operação Profissional (Visitas, Ordens de Serviço, Laudos, Cobrança)

> Fase 5 do roadmap original. Este bloco é o mais distante do domínio atual do AGRO — é
> essencialmente um mini-ERP para a rotina do veterinário como profissional autônomo/clínica, não
> mais sobre o rebanho em si. Tratar como sub-produto dentro do bounded context `Veterinary`, sem
> tocar nas tabelas do Core em nenhum momento.

---

## [ ] Passo 1 — Visitas e Ordens de Serviço

1.1. Criar `vet_visitas` (`id, veterinarian_id, tenant_conta_id, data_hora, status:
   agendada/concluida/cancelada, observacoes`) e `vet_ordens_servico` (`id, visita_id, descricao,
   itens JSON, valor_total, status: aberta/faturada/paga`).
1.2. Vincular uma visita a intervenções registradas nela (`intervencoes_veterinarias.visita_id`,
   nullable) — permite depois gerar um laudo/relatório da visita agrupando o que foi feito.

> Prompt: "Crie as tabelas vet_visitas e vet_ordens_servico, vinculando intervenções registradas
> durante uma visita a ela."

---

## [ ] Passo 2 — Laudos e Documentos

2.1. Geração de laudo em PDF a partir de uma visita/prontuário (reaproveitar decisão de biblioteca
   de exportação já discutida no módulo de Relatórios do Core — `pdf`/`printing`).
2.2. Armazenamento de documentos anexos à visita (ex.: exame laboratorial) — decidir se fica em
   disco local do backend, S3-compatível, ou similar; **não** armazenar como blob dentro do SQLite.

> Prompt: "Implemente a geração de laudo em PDF a partir dos dados de uma visita, e defina um local
> de armazenamento de documentos anexos fora do banco relacional."

---

## [ ] Passo 3 — Cobrança (nível mínimo, sem gateway de pagamento ainda)

3.1. Marcar ordens de serviço como pagas/pendentes manualmente (reaproveitando o padrão já usado no
   módulo Financeiro do Core para "Contas em Atraso") — sem integrar gateway de pagamento nesta
   onda; é só controle, não cobrança automatizada.

> Prompt: "Adicione controle manual de status de pagamento às ordens de serviço, seguindo o mesmo
> padrão do módulo Financeiro do Core, sem integrar gateway de pagamento ainda."

---

**Pronto quando (onda inteira):** um veterinário consegue registrar uma visita completa (com
intervenções vinculadas), gerar um laudo em PDF, e controlar manualmente se a ordem de serviço
correspondente já foi paga.

> Observação: esta onda é a que mais se beneficiaria de validação de mercado antes de ser construída
> por completo — o roadmap original já a posiciona como fase avançada; vale confirmar com
> veterinários reais quais dessas três partes (visitas, laudos, cobrança) têm mais valor percebido
> antes de investir nas três ao mesmo tempo.
