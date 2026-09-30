# feedbacks_db — Banco de avaliações

## Visão geral

O banco armazena avaliações, perguntas e respostas de participantes e reúne scripts para processar essas respostas e calcular indicadores CSAT e NPS por avaliação, projeto, cliente e unidade de negócio (BU).

A arquitetura da solução prevê recebimento de webhooks do Typeform por uma integração Python em AWS Lambda, persistência no MySQL e integração com um banco de sistema externo. A ingestão é realizada por uma integração Python em AWS Lambda, mantida separadamente. Este repositório reúne o schema, as procedures e os testes do banco de dados.

Este portfólio contém o [schema](schema/create_schema.sql), os [scripts de procedures](procedures/) e um [teste local com dados fictícios](tests/test_projects_departments.sql). A validação local cobre o relacionamento projeto–BU e as três procedures de agregação por BU, projeto e cliente. Ela não demonstra o funcionamento de ponta a ponta da ingestão, do processamento ou da integração externa.

## Tabelas e principais campos

A referência completa de colunas, índices e constraints é [schema/create_schema.sql](schema/create_schema.sql). As listas abaixo apresentam os **principais campos**; não substituem o DDL. Todas as tabelas usam InnoDB e charset/collation `utf8mb4/utf8mb4_unicode_ci`.

Nas listas, “opcional” significa que a coluna aceita `NULL`. Quando não houver default explícito indicado para uma coluna obrigatória, o DDL não declara um valor padrão. PKs compostas identificam a combinação dos campos, não cada campo isoladamente.

### departments

Cadastro de BUs e suas métricas agregadas.

- `id_department`: `INT UNSIGNED NOT NULL AUTO_INCREMENT`, PK.
- `name_department`: `VARCHAR(45) DEFAULT NULL`, UNIQUE; sustenta também a FK de clientes pelo nome.
- `csat_department`, `nps_department`: `DECIMAL(5,2) DEFAULT NULL`.
- `percent_promoters`, `percent_neutrals`, `percent_detractors`: `DECIMAL(5,2) DEFAULT NULL`; não são atualizados pela procedure de agregação de BU.

### customers

Cadastro de clientes e suas métricas agregadas.

- `id_customer`: `INT NOT NULL AUTO_INCREMENT`, PK.
- `name_customer`: `VARCHAR(150) DEFAULT NULL`.
- `name_department`: `VARCHAR(255) DEFAULT NULL`, FK para `departments.name_department`.
- `csat_customer`, `nps_customer`: `DECIMAL(5,2) DEFAULT NULL`.
- `percent_promoters`, `percent_neutrals`, `percent_detractors`: `DECIMAL(5,2) DEFAULT NULL`; não são atualizados pela procedure de agregação de cliente.

### projects

Cadastro de projetos e suas métricas agregadas. As BUs são associadas por `projects_departments`; não há coluna `name_department` em `projects`.

- `id_project`: `VARCHAR(45) NOT NULL DEFAULT '0'`, PK, sem `AUTO_INCREMENT`.
- `name_project`: `VARCHAR(100) DEFAULT NULL`.
- `csat_project`, `nps_project`: `DECIMAL(5,2) DEFAULT NULL`.
- `percent_promoters`, `percent_neutrals`, `percent_detractors`: `DECIMAL(5,2) DEFAULT NULL`; não são atualizados pela procedure de agregação de projeto.

### projects_departments

Associação muitos-para-muitos entre projetos e BUs por identificadores.

- `id_project`: `VARCHAR(45) NOT NULL`, FK para `projects.id_project`.
- `id_department`: `INT UNSIGNED NOT NULL`, FK para `departments.id_department`.
- PK composta: `(id_project, id_department)`; impede repetir o mesmo par.
- Índice `idx_projects_departments_department` iniciado por `id_department`. FKs sem cascatas; tipo e collation dos identificadores compatíveis com as tabelas referenciadas.

### customers_projects

Associação muitos-para-muitos entre clientes e projetos.

- `id_customer`: `INT NOT NULL DEFAULT 0`, FK para `customers.id_customer`.
- `id_project`: `VARCHAR(45) NOT NULL DEFAULT '0'`, FK para `projects.id_project`.
- PK composta: `(id_customer, id_project)`; nenhum campo é `AUTO_INCREMENT`.

### tasklists

Checklists ou turmas aos quais as avaliações estão vinculadas.

- `id_tasklist`: `VARCHAR(45) NOT NULL`, PK.
- `name_tasklist`: `VARCHAR(45) DEFAULT NULL`.
- `id_project`: `VARCHAR(45) DEFAULT NULL`, FK opcional para `projects.id_project`.
- `csat_tasklist`: `DECIMAL(5,2) DEFAULT NULL`.
- `total_items`: `INT DEFAULT 0`, aceita `NULL`.
- `percent_promoters`, `percent_neutrals`, `percent_detractors`: `DECIMAL(5,2) DEFAULT NULL`.

### feedbacks

Avaliações vinculadas a uma tasklist, com métricas e contadores.

- `id_feedback`: `VARCHAR(45) NOT NULL`, PK.
- `id_tasklist`: `VARCHAR(45) NOT NULL`, FK para `tasklists.id_tasklist`.
- `date_feedback`: `TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP`.
- `type_feedback`: `VARCHAR(45) DEFAULT NULL`.
- `status`: `ENUM('Pending','In Progress','Completed') DEFAULT 'Pending'`, aceita `NULL`.
- `total_items`, `total_participants`: `INT DEFAULT 0`, aceitam `NULL`. A importação externa contém atualização de `total_participants` a partir de `participant_count`.
- `csat_feedback`, `csat_content`, `csat_consultant`, `csat_event`, `nps_feedback`: `DECIMAL(5,2) DEFAULT NULL`.
- `percent_promoters`, `percent_neutrals`, `percent_detractors`: `DECIMAL(5,2) DEFAULT NULL`.
- `response_a`, `response_b`, `response_c`, `response_d`, `response_avg`, `response_yes`, `response_no` e `response_a_online`, `response_b_online`, `response_c_online`, `response_d_online`, `response_avg_online`: `INT DEFAULT 0`, aceitam `NULL`.

### deliverables

Formulários respondidos, vinculados a uma avaliação.

- `id_deliverable`: `VARCHAR(255) NOT NULL`, PK.
- `id_feedback`: `VARCHAR(45) NOT NULL`, FK para `feedbacks.id_feedback`.
- `id_project`: `VARCHAR(45) DEFAULT NULL`, FK opcional para `projects.id_project`.
- `id_tasklist`: `VARCHAR(45) NOT NULL`, sem FK declarada para `tasklists`.
- `received_date`: `TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP`.
- `respondent_name`: `VARCHAR(100) DEFAULT NULL`, nome do respondente.
- `csat_deliverable`, `csat_content`, `csat_consultant`, `csat_event`, `average_csat`, `nps`: `DECIMAL(5,2) DEFAULT NULL`.
- `nps_status`: `ENUM('Promoter','Neutral','Detractor') DEFAULT NULL`.
- `mandatory_comment`, `optional_comment`: `TEXT`, aceitam `NULL`; o nome do primeiro não implica obrigatoriedade no schema.
- `status`: `ENUM('PENDING','PROCESSED') DEFAULT 'PENDING'`, aceita `NULL`.
- `processing_date`: `DATETIME DEFAULT NULL`.
- `csat_content_option`, `csat_content_online_option`, `type_feedback`: `VARCHAR(20) DEFAULT NULL`.
- `platform_accessible`: `VARCHAR(3) DEFAULT NULL`.

### questions

Perguntas identificadas no contexto de uma avaliação.

- `id_question`: `VARCHAR(50) NOT NULL`, sem `AUTO_INCREMENT`.
- `id_feedback`: `VARCHAR(45) NOT NULL`; referência lógica à avaliação, sem FK para `feedbacks`.
- PK composta: `(id_question, id_feedback)`.
- `question_text`: `VARCHAR(255) NOT NULL`.
- `question_type`: `VARCHAR(50) NOT NULL`.
- `order`: `INT NOT NULL`.
- `ref`: `VARCHAR(50) DEFAULT NULL`.

### answers

Respostas de um entregável, associadas à chave composta de uma pergunta.

- `id_answer`: `INT NOT NULL AUTO_INCREMENT`, PK. O DDL contém a opção de tabela `AUTO_INCREMENT=17`.
- `id_deliverable`: `VARCHAR(255) NOT NULL`, FK para `deliverables.id_deliverable`.
- `id_question`: `VARCHAR(50) NOT NULL`; `id_feedback`: `VARCHAR(45) NOT NULL`. Juntos formam a FK para `questions(id_question, id_feedback)`.
- `answer_value`, `csat_content`: `DECIMAL(5,2) DEFAULT NULL`.
- `answer_text`: `TEXT`, aceita `NULL`.
- `answer_type`: `VARCHAR(50) NOT NULL`.
- `answer_json`: `JSON DEFAULT NULL`.
- `ref`: `VARCHAR(50) DEFAULT NULL`.

### questions_deliverables

Associação entre identificadores de perguntas e entregáveis.

- `id_question`: `VARCHAR(50) NOT NULL`, FK declarada para `questions.id_question`.
- `id_deliverable`: `VARCHAR(255) NOT NULL`, FK para `deliverables.id_deliverable`.
- PK composta: `(id_question, id_deliverable)`. Não há `AUTO_INCREMENT`, `text_question` ou `id_feedback` nesta tabela.
- A FK de pergunta usa apenas `id_question`, não a PK completa de `questions`; a associação não identifica isoladamente a avaliação da pergunta.

### processing_logs

Registros de processamento, sem FKs para as entidades mencionadas nos logs.

- `id_log`: `INT NOT NULL AUTO_INCREMENT`, PK.
- `id_deliverable`: `VARCHAR(255) DEFAULT NULL`.
- `id_feedback`: `VARCHAR(45) DEFAULT NULL`.
- `processing_date`: `DATETIME NOT NULL`, sem default declarado.
- `status`: `VARCHAR(45) DEFAULT NULL`.
- `message`: `TEXT`, aceita `NULL`.

Não há definição de tabela ou view `questions_answers` neste repositório. A procedure `sp_cast_answers` consulta `vw_questions_answers`, cuja definição também não está incluída; essa dependência não integra a estrutura implementada documentada acima.

## Relacionamentos

Na tabela, `1:N` permite zero ou vários registros filhos. A obrigatoriedade do vínculo no filho depende de `NOT NULL` e da existência de FK.

| Entidades | Cardinalidade | Colunas | Observações |
|---|---|---|---|
| `departments` ↔ `projects` | N:N | `projects_departments(id_project, id_department)` | Duas FKs obrigatórias por associação e PK composta; cada entidade pode não ter associações. |
| `departments` → `customers` | 1:N | `customers.name_department → departments.name_department` | FK opcional pelo nome; não deriva das BUs dos projetos. |
| `customers` ↔ `projects` | N:N | `customers_projects(id_customer, id_project)` | Duas FKs obrigatórias por associação e PK composta. |
| `projects` → `tasklists` | 1:N | `tasklists.id_project → projects.id_project` | FK opcional. |
| `tasklists` → `feedbacks` | 1:N | `feedbacks.id_tasklist → tasklists.id_tasklist` | FK obrigatória. |
| `feedbacks` → `deliverables` | 1:N | `deliverables.id_feedback → feedbacks.id_feedback` | FK obrigatória. |
| `tasklists` → `deliverables` | 1:N lógico | `deliverables.id_tasklist` | Coluna obrigatória, mas sem FK; a existência da tasklist não é garantida por esse campo. |
| `projects` → `deliverables` | 1:N | `deliverables.id_project → projects.id_project` | FK opcional. |
| `deliverables` → `answers` | 1:N | `answers.id_deliverable → deliverables.id_deliverable` | FK obrigatória. |
| `questions` → `answers` | 1:N | `answers(id_question, id_feedback) → questions(id_question, id_feedback)` | FK composta obrigatória; não é apenas por `id_question`. |
| `questions` ↔ `deliverables` | N:N por identificador de pergunta | `questions_deliverables(id_question, id_deliverable)` | FKs declaradas; `id_question` sozinho não é único em `questions`. |

As FKs não garantem que `deliverables.id_project` e `deliverables.id_tasklist` coincidam com os vínculos derivados de `deliverables.id_feedback`. Tampouco comparam a avaliação em `answers.id_feedback` com a do entregável. A consistência entre essas referências redundantes não deve ser presumida.

### Regras de agregação por BU, projeto e cliente

O caminho canônico para BU é:

`feedbacks → tasklists → projects → projects_departments → departments`

- Uma avaliação herda todas as BUs associadas ao seu projeto e contribui uma vez em cada BU. A PK de `projects_departments` impede duplicar o mesmo par projeto–BU.
- Nas métricas de projeto e cliente, cada avaliação contribui uma vez por projeto/cliente, independentemente da quantidade de BUs. Essas consultas não juntam `projects_departments`; a agregação de cliente usa `customers_projects`.
- As médias têm peso igual por avaliação. `AVG` ignora `NULL` separadamente em cada métrica; não se usa `AVG(DISTINCT)`.
- O NPS agregado é a média de `feedbacks.nps_feedback`, sem ponderação pela quantidade de respondentes.
- BUs sem avaliações ou sem valores válidos recebem `NULL`, substituindo métricas antigas.

Essas regras se aplicam às colunas CSAT/NPS atualizadas pelas três procedures de agregação. Não descrevem o cálculo de `percent_promoters`, `percent_neutrals` ou `percent_detractors` dessas entidades, que não são atualizadas por essas procedures.

## Fluxo de dados e integração

As etapas abaixo descrevem as responsabilidades da arquitetura e dos scripts. Não representam um agendamento ou uma sequência automática implementada.

1. **Ingestão pelo webhook:** a integração Python/AWS Lambda recebe dados do Typeform e constitui a fronteira de entrada da solução. Seu código não está disponível aqui; este repositório descreve as estruturas de armazenamento, sem verificar o mapeamento de campos ou a ordem de gravação.
2. **Enriquecimento externo:** `sp_update_data_from_prod` usa `prod.checklist_feedback` para atualizar participantes das avaliações, inserir projetos e preencher `deliverables.id_project`; usa `prod.projects` e `prod.clients` para cadastrar/atualizar clientes e inserir vínculos em `customers_projects`. Obtém o nome do projeto de `prod.TBL_project_full.title`. Não preenche `tasklists.id_project` nem sincroniza tasklists. Esse vínculo precisa estar preenchido para que uma avaliação participe das agregações de projeto, cliente e BU; os testes o preenchem com dados fictícios.
3. **Processamento e agregação:** os scripts oferecem rotinas de associação de perguntas, conversão de respostas, atualização de avaliações, cálculo de CSAT e agregação. Não há chamadas entre as procedures de negócio nos arquivos locais. `sp_process_new_deliverable` verifica o entregável, atualiza seu status/data e registra logs; não chama as rotinas de cálculo. O teste local chama explicitamente as três procedures de agregação sobre métricas fictícias já preenchidas em `feedbacks`.
4. **Envio externo:** `sp_send_data_to_prod` contém atualização de `prod.checklist_feedback` com NPS e indicadores de resposta de `feedbacks_db.feedbacks`, além de registro em log. Esse envio não é exercitado pelo teste local.

Não há definições de `CREATE EVENT` ou `CREATE TRIGGER` no repositório. Frequência, disparo e orquestração externos não estão documentados por código local; não se presume execução automática.

## Procedures disponíveis

Cada nome abaixo corresponde ao `CREATE PROCEDURE` no arquivo de mesmo nome em [procedures/](procedures/). O escopo é uma descrição dos scripts, não uma declaração de validação de todas as rotinas.

| Procedure | Escopo do script |
|---|---|
| `sp_process_new_deliverable` | Verifica existência/status e dados do entregável; atualiza `deliverables.status` para `PROCESSED`, registra `processing_date` e logs. Não calcula CSAT/NPS. |
| `sp_relate_questions_deliverables` | Insere pares em `questions_deliverables` para um entregável, juntando perguntas e entregável por `id_feedback`. |
| `sp_cast_answers` | Lê `vw_questions_answers`, converte/classifica respostas e contém atualização de métricas, opções, comentários e nome do respondente em `deliverables`. A view não está definida aqui. |
| `sp_update_feedbacks` | Contém cálculos por avaliação a partir de `deliverables`: contagem, CSAT do consultor, percentuais e NPS, além de indicadores de resposta. |
| `sp_calculate_response_avg` | Calcula `response_avg` e `response_avg_online` a partir das opções de resposta em `feedbacks`. |
| `sp_calculate_csat_feedback` | Converte médias de resposta em `csat_content` e calcula `csat_feedback` quando há conteúdo e consultor válidos. |
| `sp_calculate_csat_nps_department` | Atualiza `departments.csat_department` e `nps_department` pelo caminho N:N; restaura `sql_safe_updates` no sucesso e em erro, propagando o erro. |
| `sp_calculate_csat_nps_project` | Atualiza `projects.csat_project` e `nps_project` a partir das avaliações ligadas por tasklists. |
| `sp_calculate_csat_nps_customer` | Atualiza `customers.csat_customer` e `nps_customer` por `customers_projects`, projetos, tasklists e avaliações. |
| `sp_update_data_from_prod` | Enriquece os dados locais conforme o fluxo descrito acima; não sincroniza BUs nem suas associações. |
| `sp_send_data_to_prod` | Contém o envio de NPS e indicadores de resposta ao banco externo. |

A validação atual cobre as três procedures `sp_calculate_csat_nps_department`, `sp_calculate_csat_nps_project` e `sp_calculate_csat_nps_customer`. As demais não são declaradas validadas por esse teste. Há dependências e divergências de nomes ainda sujeitas à revisão: por exemplo, alguns scripts usam `feedback_type` e `response_yes_online/response_no_online`, enquanto o schema define `type_feedback` e `response_yes/response_no`.

## Dependência externa e limites da versão

O banco do sistema (PMO) é externo, gerenciado por outra equipe e está fora do escopo deste repositório.

A fonte observada na rotina de produção é `business_unit(project_id, name)`: `project_id` identifica o projeto e `name` fornece o nome da BU, ignorando nomes vazios após `TRIM`. Essa referência não estabelece um ID de BU, unicidade por projeto ou um contrato de reconciliação.

A versão atual de `sp_update_data_from_prod` não sincroniza `departments` nem `projects_departments`. Nessa rotina, `TBL_project_full` é usada apenas para obter o nome do projeto; `Area` não é interpretado como associação. A sincronização das associações projeto–BU não está implementada nesta versão. O modelo N:N é demonstrado com associações fictícias locais.

O repositório também não inclui a integração Python/Lambda, a view consumida por `sp_cast_answers` ou um agendamento das rotinas. Os testes locais não validam essas dependências nem a integração com o sistema externo.

## Testes e validação

O arquivo [tests/test_projects_departments.sql](tests/test_projects_departments.sql) é destinado exclusivamente ao banco local `feedbacks_portfolio_test`. Ele prepara as tabelas necessárias com as definições integrais do schema, em ordem de FKs, e orienta a instalação das três procedures reais de agregação.

**Validação local:** teste executado em **30/09/2026**, no **MySQL 8.4.10**, banco `feedbacks_portfolio_test`, com todos os resultados **PASS** e **zero falhas**. A integração externa não foi validada; a sincronização das associações projeto–BU não está implementada nesta versão.

### Execução manual no Workbench

Use uma conexão local dedicada, sem transação aberta, com `autocommit=1` e FKs ativas. Configure a execução para parar em erros. Execute o arquivo por seções, não inteiro de uma vez:

1. **A — Conferência inicial:** execute e confira banco, servidor, tabelas e procedures existentes.
2. **B — Preparação:** crie as sete tabelas necessárias. A preparação recusa tabelas já existentes antes de iniciar a criação. Se alguma existir, compare seu `SHOW CREATE TABLE` com B; interrompa em incompatibilidades. Se todas forem compatíveis, pule B; se apenas algumas existirem e forem compatíveis, execute somente os `CREATE TABLE` das ausentes, na ordem indicada. Não execute indiscriminadamente `schema/create_schema.sql`.
3. **C — Instalação:** abra `procedures/sp_calculate_csat_nps_department.sql`, `procedures/sp_calculate_csat_nps_project.sql` e `procedures/sp_calculate_csat_nps_customer.sql`. Em cada aba, execute `USE feedbacks_portfolio_test;` e `SELECT DATABASE();` antes do arquivo completo, incluindo seus delimitadores. Compare procedures já existentes; reutilize apenas definições idênticas ou faça a reinstalação explícita no banco de teste, fora da transação.
4. **D — Cenários:** execute após A/B/C e confira resultados esperados, obtidos e `PASS/FAIL`. A seção remove seus helpers ao concluir. Se houver erro, siga as instruções do arquivo antes da limpeza manual dos helpers.

Os cenários cobrem projetos com uma e várias BUs, avaliações com notas iguais e diferentes, `NULL` por métrica, BU sem avaliações, rejeição de pares duplicados e IDs inexistentes, preservação do vínculo cliente–BU e invariância das métricas de projeto/cliente ao acrescentar uma BU. Também verificam o estado de `sql_safe_updates` nas chamadas bem-sucedidas da agregação de BU.

DDL e instalação ficam fora da transação. Dados fictícios e cálculos terminam com `ROLLBACK`; erros inesperados no executor também acionam rollback e restauração de `sql_safe_updates`. As tabelas e as três procedures reais permanecem, e valores de `AUTO_INCREMENT` consumidos não são recuperados. O teste não altera `processing_logs` nem chama rotinas de importação ou envio.

## Mecanismos verificáveis

- PKs compostas impedem pares duplicados em `projects_departments`, `customers_projects` e `questions_deliverables`.
- FKs declaradas verificam a existência das referências cobertas por elas; referências lógicas e coerência entre vínculos redundantes têm os limites descritos acima.
- A agregação por BU preserva o estado da sessão para `sql_safe_updates` e propaga erros com `RESIGNAL`.
- O teste usa dados identificáveis, handlers restritos aos erros de integridade esperados e `ROLLBACK`.
- `processing_logs` dispõe de identificadores opcionais de avaliação/entregável, data obrigatória e mensagem para registros feitos pelas rotinas.

## Próximos passos

- Revisar as demais procedures e suas dependências.
- Verificar a compatibilidade entre o banco e a integração Python.
- Ampliar os testes conforme as rotinas forem revisadas.
- Atualizar a documentação após cada conjunto validado.
