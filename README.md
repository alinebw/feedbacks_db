# feedbacks_db - Documentação do Banco de Dados

## Visão Geral

Este banco de dados foi projetado para se conectar com sistemas externos, permitindo a sincronização de dados essenciais, como informações de clientes e projetos. A integração utiliza webhooks para receber dados em tempo real de formulários e procedures (já implementadas ou a serem desenvolvidas) para atualizar e enviar métricas de avaliação a outros sistemas, garantindo consistência, eficiência e automação no fluxo de dados.

## Estrutura do Banco de Dados

### Tabelas e Relacionamentos
#### 1. departaments
- **Descrição:** Armazena os departamentos da empresa
- **Campos:** 
    - id_department (PK, INT): Identificador único do departamento. Referenciado do sistema_db via procedure.
    - name_department (UNIQUE, VARCHAR(100), DEFAULT NULL): Nome do departamento. Referenciado do sistema_db via procedure.
    - csat_department (DECIMAL(5,2), DEFAULT NULL): Média CSAT do departamento.
    - percent_promoters (DECIMAL(5,2)): Porcentagem de promotores.
    - percent_neutrals (DECIMAL(5,2)): Porcentagem de neutros.
    - percent_detractors (DECIMAL(5,2)): Porcentagem de detratores.
      
#### 2. clientes

- **Descrição:** Armazena informações dos clientes.
- **Campos:**
    - id_cliente (INT, PK): Identificador único do cliente. Referenciado do sistema_db via procedure
    - name_customer (VARCHAR(100), DEFAULT NULL): Nome do cliente. Referenciado do sistema_db via procedure
    - name_department (VARCHAR(255), FK, DEFAULT NULL): Chave estrangeira referenciando business_unities(nome_bu)
    - csat_customer (DECIMAL(5,2), DEFAULT NULL): Média CSAT do cliente
    - percent_promoters (DECIMAL(5,2)): Porcentagem de promotores
    - perc_neutrals (DECIMAL(5,2)): Porcentagem de neutros
    - perc_detractors (DECIMAL(5,2)): Porcentagem de detratores
      
#### 3. projetos

- **Descrição:** Contém dados dos projetos.
- **Campos:**
    - id_project (VARCHAR(45), PK): Identificador único do projeto. Referenciado do sistema_db via procedure
    - name_project (VARCHAR(100), DEFAULT NULL): Nome do projeto. Referenciado do sistema_db via procedure
    - name_department (VARCHAR(255), FK): Referência a business_unities(nome_bu)
    - csat_project (DECIMAL(5,2), DEFAULT NULL): Média CSAT do projeto
    - percent_promoters (DECIMAL(5,2)): Porcentagem de promotores
    - perc_neutrals (DECIMAL(5,2)): Porcentagem de neutros
    - perc_detractors (DECIMAL(5,2)): Porcentagem de detratores
      
#### 4. clientes_projetos

- **Descrição:** Tabela associativa para o relacionamento muitos-para-muitos entre clientes e projetos.
- **Campos:**
    - id_customer (INT, PK, FK): Chave estrangeira referenciando clientes(id_customer)
    - id_project (INT, PK, FK): Chave estrangeira referenciando projetos(id_project)

#### 5. tasklists

- **Descrição:** Armazena informações de checklists (turmas)
- **Campos:**
    - id_tasklist (INT, PK): Identificador único do checklist. Recebe campo oculto do payload webhook
    - name_tasklist (VARCHAR(100), DEFAULT NULL): Nome do checklist. Referenciado do sistema_db via procedure
    - id_project (INT, FK, DEFAULT NULL): Chave estrangeira referenciando projetos(id_projeto)
    - csat_tasklist (DECIMAL(5,2), DEFAULT NULL): Média CSAT do checklist
    - total_items (INT, DEFAULT 0): Total de entregáveis recebidos
    - percent_promoters (DECIMAL(5,2)): Porcentagem de promotores
    - perc_neutrals (DECIMAL(5,2)): Porcentagem de neutros
    - perc_detractors (DECIMAL(5,2)): Porcentagem de detratores
      
#### 6. feedbacks

- **Descrição:** Contém os diferentes tipos de feedbacks.
- **Campos:**
    - id_feedback (INT, PK): Identificador único da avaliação. Gerado antes da aplicação do formulário. Recebe campo oculto do payload webhook
    - id_tasklist (INT, FK, NOT NULL): Chave estrangeira referenciando checklists(id_checklists)
    - date_feedback (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP): Data da avaliação
    - type_feedback (VARCHAR(50), NOT NULL): Tipo de avaliação (e.g., 'CSAT', 'NPS')
    - total_items (INT, DEFAULT 0): Total de entregáveis recebidos
    - total_participants (INT, DEFAULT 0): Total de participantes (preenchido manualmente)
    - status ENUM('Backlog', 'In Progress', 'Completed') DEFAULT 'Backlog'
    - csat_feedback (DECIMAL(5,2), DEFAULT NULL): Média CSAT da avaliação
    - csat_content (DECIMAL(5,2)): CSAT médio do conteúdo
    - csat_consultant (DECIMAL(5,2)): CSAT médio do consultor
    - csat_event (DECIMAL(5,2)): CSAT médio do evento
    - nps_feedback (DECIMAL(5,2)): NPS calculado para a avaliação
    - perc_promoters (DECIMAL(5,2)): Porcentagem de promotores
    - perc_neutrals (DECIMAL(5,2)): Porcentagem de neutros
    - perc_detractors (DECIMAL(5,2)): Porcentagem de detratores


#### 7. deliverables

- **Descrição:** Registra os formulários preenchidos (deliverables).
- **Campos:**
    - id_deliverable (PK, VARCHAR): Identificador único do entregável
    - id_feedback (FK, VARCHAR): Referência à avaliação
    - id_tasklist (FK, VARCHAR): Referência ao checklist correspondente
    - id_project (VARCHAR(45)): Referência ao projeto correspondente
    - received_date (DATETIME): Data de recebimento do entregável
    - csat_consultant (DECIMAL(5,2)): CSAT do consultor para o entregável
    - csat_content (DECIMAL(5,2)): CSAT do conteúdo para o entregável
    - csat_content_option (VARCHAR(10): CSAT do conteúdo para o entregável (avaliação presencial)
    - csat_content_online_option (VARCHAR(10)): CSAT do conteúdo para o entregável (avaliação online)
    - platform_acessible (VARCHAR(3)): Indica se a plataforma foi considerada acessível pelo respondente (avaliação online)
    - mandatory_comment (VARCHAR): Comentário obrigatório do formulário enviado
    - optional_comment (VARCHAR): Comentário opcional do formulário enviado
    - respondent_name (VARCHAR): Comentário opcional do formulário enviado
    - nps_status (ENUM): Opção promotor, neutro e detrator
    - nps (DECIMAL(5,2)): nps relacionado ao formulário
    - status (ENUM): Status do entregável ('PENDENTE', 'PROCESSADO')
    - processing_date (DATETIME): Data de processamento do entregável

    Índices:
    idx_deliverables_feedback em id_feedback.
    idx_deliverables_received_date em received_date.

#### 8. questions

- **Descrição:** Armazena as perguntas dos formulários.
- **Campos:**
    - id_question (INT, PK, AUTO_INCREMENT): Identificador único da pergunta. Recebe do webhook objeto definition/fields.
    - id_feedback (INT, FK, NOT NULL): Chave estrangeira referenciando avaliacoes(id_avaliacao)
    - text_question (VARCHAR(255), NOT NULL): Texto da pergunta
    - type_question (VARCHAR(50), NOT NULL): Tipo da pergunta. Recebe do webhook objeto definition.
    - ref (VARCHAR(50)): Referência da pergunta no Typeform
    - order (INT, NOT NULL): Ordem da pergunta no formulário

#### 9. answers

- **Descrição:** Contém as respostas dadas pelos participantes.
- **Campos:**
    - id_answer (PK, INT, AI): Identificador único da resposta
    - id_deliverable (VARCHAR(255)): Referência ao entregável correspondente
    - id_question (VARCHAR(50)): Identificador da pergunta correspondente
    - id_feedback (INT): Identificador da avaliação à qual a resposta pertence
    - answer_value (DECIMAL(5,2)): Valor numérico da resposta
    - answer_text (TEXT): Texto da resposta
    - answer_type (VARCHAR(50)): Tipo da resposta
    - csat_content (DECIMAL(5,2)): Valor de CSAT para o conteúdo
    - ref (VARCHAR(50)): Referência da pergunta no Typeform

#### 10. questions_deliverables

- **Descrição:** Relaciona perguntas a seus respectivos formulários (entregáveis)
- **Campos:**
    - id_question (INT, PK, AUTO_INCREMENT): Identificador único da pergunta. Recebe do webhook objeto definition/fields.
    - id_deliverable (INT, FK, NOT NULL): Chave estrangeira referenciando deliverables (id_deliverable)
    - text_question (VARCHAR(255), NOT NULL): Texto da pergunta
 
#### 11. questions_answers

- **Descrição:** Combina dados das tabelas perguntas e respostas para facilitar análises e cálculos.
- **Campos:**
    - id_question (FK, INT): Referência à pergunta
    - id_answer (FK, INT): Referência à resposta

#### 12. processing_logs

- **Descrição:** Registra o status e os detalhes dos processamentos no banco.
- **Campos:**
    - `id_log` (PK, INT, AUTO_INCREMENT): Identificador único do log.
    - `id_deliverable` (VARCHAR(255), permite NULL): Identificador do entregável associado ao log; pode ser NULL em execuções sem entregável específico.
    - `id_feedback` (VARCHAR(45), permite NULL): Identificador da avaliação relacionada ao processamento, quando disponível.
    - `processing_date` (DATETIME, obrigatório): Data e hora do registro.
    - `status` (VARCHAR(45), permite NULL): Status informado pela rotina de processamento.
    - `message` (TEXT, permite NULL): Mensagem de erro ou detalhe do processamento.

## Relacionamentos Chave

**Departaments e Customers:** Cada cliente está associado a um único departamento por meio da chave estrangeira id_department na tabela customers. Um departamento, por sua vez, pode ter múltiplos clientes. Isso estabelece um relacionamento de um-para-muitos entre departamentos e clientes, onde um departamento pode ter vários clientes, mas cada cliente está relacionado a um único departamento.

**Customers e Projects:** A relação entre clientes e projetos é estabelecida através da tabela associativa customers_projects, que contém as chaves estrangeiras id_customer e id_project. Isso permite que um cliente esteja associado a múltiplos projetos e que um projeto esteja associado a múltiplos clientes. Esse arranjo configura um relacionamento de muitos-para-muitos entre clientes e projetos.

**Projects e Tasklists:** Cada tasklist está associado a um único projeto por meio da chave estrangeira id_project na tabela tasklists. Um projeto, por sua vez, pode ter múltiplos tasklists. Isso estabelece um relacionamento de um-para-muitos entre projetos e tasklists, onde um projeto pode ter vários tasklists, mas cada tasklist está relacionado a um único projeto.

**Tasklists e Feedbacks:** Cada feedback está associado a um único tasklist por meio da chave estrangeira id_tasklist na tabela feedbacks. Um tasklist, por sua vez, pode ter múltiplos feedbacks. Isso estabelece um relacionamento de um-para-muitos entre tasklists e feedbacks, onde um tasklist pode ter vários feedbacks, mas cada feedback está relacionado a um único tasklist.

**Feedbacks e Deliverables:** Cada deliverable está associado a um único feedback por meio da chave estrangeira id_feedback na tabela deliverables. Um feedback, por sua vez, pode ter múltiplos deliverables (formulários preenchidos). Isso estabelece um relacionamento de um-para-muitos entre feedbacks e deliverables, onde um feedback pode ter vários deliverables, mas cada deliverable está relacionado a um único feedback.

**Deliverables e Answers:** Cada resposta está associada a um único formulário por meio da chave estrangeira id_deliverable na tabela answers. Um formulário, por sua vez, pode conter múltiplas respostas. Isso estabelece um relacionamento de um-para-muitos entre formulários e respostas, onde um formulário pode ter várias respostas, mas cada resposta está relacionada a um único formulário.

**Answers e Questions:** Cada resposta está associada a uma única pergunta por meio da chave estrangeira id_question na tabela answers. Uma pergunta, por sua vez, pode estar vinculada a múltiplas respostas provenientes de diferentes formulários preenchidos. Isso estabelece um relacionamento de um-para-muitos entre perguntas e respostas, onde uma pergunta pode ter várias respostas, mas cada resposta está relacionada a uma única pergunta.

**Deliverables e Tasklists:** Cada formulário está associado a uma única tasklist por meio da chave estrangeira id_tasklist na tabela deliverables. Uma tasklist, por sua vez, pode ter múltiplos formulários associados. Isso estabelece um relacionamento de um-para-muitos entre tasklists e formulários, onde uma tasklist pode ter vários formulários, mas cada formulário está relacionado a uma única tasklist.

**Deliverables e Projects:** Cada formulário pode estar associado a um único projeto por meio da chave estrangeira id_project na tabela deliverables. Um projeto, por sua vez, pode ter múltiplos formulários. Isso estabelece um relacionamento de um-para-muitos entre projetos e formulários, onde um projeto pode ter vários formulários, mas cada formulário está relacionado a um único projeto.

## Fluxo de Dados e Integração

**Recebimento de Dados:** Quando um formulário é enviado, uma função Lambda recebe o payload do webhook do Typeform e envia os dados para as devidas tabelas.<br>
**Atualização de Dados:** Duas a trêz vezes ao dia, uma trigger é acionada e chama uma procedure que sincroniza o feedbacks_db com o sistema_db.<br>
**Cálculo de Métricas:** Após a sincronização, são calculados os valores de CSAT e NPS.<br>
**Envio de Métricas:** As métricas calculadas são enviadas de volta ao sistema_db através de procedures.<br>

## Procedures e Events Implementados

1. **sp_process_deliverable** 
**Descrição:** Marca um entregável como "PROCESSADO", calculando as métricas (CSAT e NPS) a partir das respostas recebidas. Atualiza os campos correspondentes nas tabelas relacionadas e registra a data de processamento.
**Disparo:** Chamada manualmente ou por um event agendado

2. **sp_cast_answers** 
**Descrição:** Converte as respostas recebidas do formulário em valores processáveis, como a transformação de respostas opcionais (A, B, C, D) em percentuais e atualiza os campos na tabela entregaveis.
**Disparo:** Chamada manualmente ou por um event agendado

3. **sp_update_feedbacks** 
**Descrição:** Calcula e atualiza os valores agregados de CSAT e NPS nas tabelas avaliacoes, checklists, clientes, projetos e business_unities, considerando os dados processados nos entregáveis.
**Disparo:** Chamada manualmente ou por um event agendado.

4. **sp_relate_questions_and_deliverables** 
**Descrição:** Associa as perguntas às respostas correspondentes com base no id_entregavel e atualiza a tabela intermediária perguntas_entregaveis.
**Disparo:** Chamada manualmente ou por um event agendado.

5. **sp_update_data_from_prod** 
**Descrição:** Sincroniza dados do banco do sistema para o banco feedbacks, atualizando informações de clientes, projetos e checklists.
**Disparo:** Event agendado para execução em batch (2-3 vezes ao dia).

## Boas Práticas Adotadas

- **Normalização:** O banco de dados foi projetado seguindo as regras de normalização para evitar redundâncias e inconsistências.
- **Chaves Primárias e Estrangeiras:** Uso adequado de PKs e FKs para manter a integridade referencial.
- **Procedures e Triggers:** Automação de processos repetitivos e críticos, garantindo a sincronização de dados entre bancos.
- **Comentários e Documentação:** Scripts comentados para facilitar a manutenção e compreensão do código.
- **Integração com Sistemas Externos:** Uso de webhooks e integração com o database do sistema para um fluxo de dados eficiente.
