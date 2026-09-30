-- TESTE MANUAL: somente MySQL local, banco feedbacks_portfolio_test.
-- Nao executar o arquivo inteiro de uma vez: executar A, B, instalar C, executar D.
-- Use conexao local dedicada, sem transacao aberta, com autocommit=1.
-- No Workbench, habilite interrupcao do script em erros; nao prossiga apos erro.
-- Nao execute schema/create_schema.sql: este teste extrai suas definicoes integrais
-- em ordem de FKs. processing_logs existente nao e usada nem alterada.
-- DDL fica fora da transacao; tabelas e procedures reais permanecem.
-- Dados e calculos terminam em ROLLBACK (inclusive se ocorrer erro inesperado).
-- Valores AUTO_INCREMENT consumidos nao sao recuperados pelo ROLLBACK.
-- Nao instalar/chamar procedures de importacao, envio ou processamento.
--
-- A. CONFERENCIA INICIAL (executar primeiro e inspecionar os resultados)
USE feedbacks_portfolio_test;
SELECT DATABASE() AS banco, @@hostname AS servidor, @@port AS porta,
       @@session.autocommit AS autocommit,
       @@session.foreign_key_checks AS foreign_key_checks;
SELECT table_name, table_type, engine
FROM information_schema.tables
WHERE table_schema = 'feedbacks_portfolio_test'
ORDER BY table_name;
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'feedbacks_portfolio_test'
ORDER BY routine_name;
-- Primeira execucao: as sete tabelas abaixo devem estar AUSENTES.
-- Se alguma existir, B recusa toda a preparacao antes de criar qualquer tabela.
-- Para cada existente, execute SHOW CREATE TABLE feedbacks_portfolio_test.<nome>
-- e compare com a definicao integral em B (colunas, tipos, NULL/defaults,
-- charset/collation, PKs, indices, FKs sem cascatas e ENGINE=InnoDB).
-- Incompatibilidade: PARE; nao sobrescreva nem use IF NOT EXISTS para esconde-la.
-- Prepare uma migracao local revisada separadamente. Este arquivo nao migra tabelas.
-- Se TODAS ja existirem e forem compativeis, pule B.
-- Se apenas algumas existirem e forem compativeis, execute SOMENTE os CREATE TABLE
-- das ausentes copiados de B, na ordem apresentada, sempre neste banco local.
-- Helpers test_pd_* ja existentes: inspecione SHOW CREATE PROCEDURE antes de
-- remove-los explicitamente; CREATE PROCEDURE nao substitui routines existentes.
--
-- B. PREPARACAO (selecionar de USE ate DROP PROCEDURE, inclusive)
USE feedbacks_portfolio_test;
DELIMITER //
CREATE PROCEDURE feedbacks_portfolio_test.test_pd_prepare_v1()
BEGIN
    IF DATABASE() <> 'feedbacks_portfolio_test'
       OR @@session.foreign_key_checks <> 1
       OR @@session.autocommit <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Use banco local de teste, autocommit=1 e FKs ativas.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'feedbacks_portfolio_test'
          AND table_name IN ('departments', 'projects', 'customers',
                             'projects_departments', 'customers_projects',
                             'tasklists', 'feedbacks')
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tabela ja existe: compare SHOW CREATE TABLE com B antes de continuar.';
    END IF;

-- Definicoes integrais de schema/create_schema.sql, em ordem de dependencias.

CREATE TABLE `departments` (
  `id_department` int unsigned NOT NULL AUTO_INCREMENT,
  `name_department` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `csat_department` decimal(5,2) DEFAULT NULL,
  `nps_department` decimal(5,2) DEFAULT NULL,
  `percent_promoters` decimal(5,2) DEFAULT NULL COMMENT 'Percent of promoters in the department',
  `percent_neutrals` decimal(5,2) DEFAULT NULL COMMENT 'Percent of neutrals in the department',
  `percent_detractors` decimal(5,2) DEFAULT NULL COMMENT 'Percent of detractors in the department',
  PRIMARY KEY (`id_department`),
  UNIQUE KEY `name_department` (`name_department`),
  KEY `idx_departments_csat_department` (`csat_department`),
  KEY `idx_departments_name_department` (`name_department`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `projects` (
  `id_project` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `name_project` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `csat_project` decimal(5,2) DEFAULT NULL,
  `nps_project` decimal(5,2) DEFAULT NULL,
  `percent_promoters` decimal(5,2) DEFAULT NULL COMMENT 'Percent of promoters in the project',
  `percent_neutrals` decimal(5,2) DEFAULT NULL COMMENT 'Percent of neutrals in the project',
  `percent_detractors` decimal(5,2) DEFAULT NULL COMMENT 'Percent of detractors in the project',
  PRIMARY KEY (`id_project`),
  KEY `idx_projects_csat_project` (`csat_project`),
  KEY `idx_projects_name_project` (`name_project`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `customers` (
  `id_customer` int NOT NULL AUTO_INCREMENT,
  `name_customer` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name_department` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `csat_customer` decimal(5,2) DEFAULT NULL,
  `nps_customer` decimal(5,2) DEFAULT NULL,
  `percent_promoters` decimal(5,2) DEFAULT NULL COMMENT 'Percent of promoters for the customer',
  `percent_neutrals` decimal(5,2) DEFAULT NULL COMMENT 'Percent of neutrals for the customer',
  `percent_detractors` decimal(5,2) DEFAULT NULL COMMENT 'Percent of detractors for the customer',
  PRIMARY KEY (`id_customer`),
  KEY `idx_customers_csat_customer` (`csat_customer`),
  KEY `idx_customers_name_department` (`name_department`),
  KEY `idx_customers_name_customer` (`name_customer`),
  CONSTRAINT `fk_customers_departments` FOREIGN KEY (`name_department`) REFERENCES `departments` (`name_department`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `projects_departments` (
  `id_project` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_department` int unsigned NOT NULL,
  PRIMARY KEY (`id_project`, `id_department`),
  KEY `idx_projects_departments_department` (`id_department`),
  CONSTRAINT `fk_projects_departments_project` FOREIGN KEY (`id_project`) REFERENCES `projects` (`id_project`),
  CONSTRAINT `fk_projects_departments_department` FOREIGN KEY (`id_department`) REFERENCES `departments` (`id_department`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `customers_projects` (
  `id_customer` int NOT NULL DEFAULT '0',
  `id_project` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_customer`, `id_project`),
  KEY `idx_customers_projects_idcustomer_idproject` (`id_customer`, `id_project`),
  KEY `idx_customers_projects_customer` (`id_customer`),
  KEY `idx_customers_projects_project` (`id_project`),
  CONSTRAINT `customers_projects_ibfk_1` FOREIGN KEY (`id_customer`) REFERENCES `customers` (`id_customer`),
  CONSTRAINT `fk_customers_projects_projects` FOREIGN KEY (`id_project`) REFERENCES `projects` (`id_project`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `tasklists` (
  `id_tasklist` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_tasklist` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_project` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `csat_tasklist` decimal(5,2) DEFAULT NULL,
  `total_items` int DEFAULT '0',
  `percent_promoters` decimal(5,2) DEFAULT NULL COMMENT 'Percent of promoters in the tasklist',
  `percent_neutrals` decimal(5,2) DEFAULT NULL COMMENT 'Percent of neutrals in the tasklist',
  `percent_detractors` decimal(5,2) DEFAULT NULL COMMENT 'Percent of detractors in the tasklist',
  PRIMARY KEY (`id_tasklist`),
  KEY `idx_tasklists_project` (`id_project`),
  KEY `idx_tasklists_csat_tasklist` (`csat_tasklist`),
  KEY `idx_tasklists_idproject_idtasklist` (`id_project`,`id_tasklist`),
  KEY `idx_tasklists_name_tasklist` (`name_tasklist`),
  CONSTRAINT `fk_tasklists_projects` FOREIGN KEY (`id_project`) REFERENCES `projects` (`id_project`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `feedbacks` (
  `id_feedback` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_tasklist` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_feedback` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `type_feedback` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `csat_feedback` decimal(5,2) DEFAULT NULL,
  `total_items` int DEFAULT '0',
  `total_participants` int DEFAULT '0',
  `status` enum('Pending','In Progress','Completed') DEFAULT 'Pending',
  `csat_content` decimal(5,2) DEFAULT NULL,
  `csat_consultant` decimal(5,2) DEFAULT NULL,
  `csat_event` decimal(5,2) DEFAULT NULL,
  `nps_feedback` decimal(5,2) DEFAULT NULL,
  `percent_promoters` decimal(5,2) DEFAULT NULL COMMENT 'Percent of promoters in feedback',
  `percent_neutrals` decimal(5,2) DEFAULT NULL COMMENT 'Percent of neutrals in feedback',
  `percent_detractors` decimal(5,2) DEFAULT NULL COMMENT 'Percent of detractors in feedback',
  `response_a` int DEFAULT '0' COMMENT 'Percent of responses A (in-person)',
  `response_b` int DEFAULT '0' COMMENT 'Percent of responses B (in-person)',
  `response_c` int DEFAULT '0' COMMENT 'Percent of responses C (in-person)',
  `response_d` int DEFAULT '0' COMMENT 'Percent of responses D (in-person)',
  `response_avg` int DEFAULT '0' COMMENT 'Average percent of responses (in-person)',
  `response_yes` int DEFAULT '0' COMMENT 'Percent of Yes responses (online)',
  `response_no` int DEFAULT '0' COMMENT 'Percent of No responses (online)',
  `response_a_online` int DEFAULT '0' COMMENT 'Percent of responses A (online)',
  `response_b_online` int DEFAULT '0' COMMENT 'Percent of responses B (online)',
  `response_c_online` int DEFAULT '0' COMMENT 'Percent of responses C (online)',
  `response_d_online` int DEFAULT '0' COMMENT 'Percent of responses D (online)',
  `response_avg_online` int DEFAULT '0' COMMENT 'Average percent of responses (online)',
  PRIMARY KEY (`id_feedback`),
  KEY `idx_feedbacks_tasklist` (`id_tasklist`),
  KEY `idx_feedbacks_status` (`status`),
  KEY `idx_feedbacks_csat_feedback` (`csat_feedback`),
  KEY `idx_feedbacks_idtasklist_idfeedback` (`id_tasklist`,`id_feedback`),
  KEY `idx_feedbacks_nps_feedback` (`nps_feedback`),
  KEY `idx_feedbacks_csat_content` (`csat_content`),
  KEY `idx_feedbacks_csat_event` (`csat_event`),
  KEY `idx_feedbacks_csat_consultant` (`csat_consultant`),
  CONSTRAINT `fk_feedbacks_tasklist` FOREIGN KEY (`id_tasklist`) REFERENCES `tasklists` (`id_tasklist`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

END //
DELIMITER ;
CALL feedbacks_portfolio_test.test_pd_prepare_v1();
DROP PROCEDURE feedbacks_portfolio_test.test_pd_prepare_v1;
-- FIM B. DDL nao e revertido se houver falha parcial; reavalie A nesse caso.

-- C. INSTALAR AS TRES PROCEDURES REAIS ANTES DE D
-- Na MESMA conexao local, abra cada arquivo abaixo em uma aba do Workbench.
-- Antes de executar cada arquivo, execute USE feedbacks_portfolio_test;
-- e SELECT DATABASE(); nessa aba. Execute o arquivo completo com seus DELIMITERs:
--   procedures/sp_calculate_csat_nps_department.sql
--   procedures/sp_calculate_csat_nps_project.sql
--   procedures/sp_calculate_csat_nps_customer.sql
-- Se a routine ja existir, compare SHOW CREATE PROCEDURE com o arquivo atual.
-- Se for identica, reutilize. Se divergir, pare e reinstale explicitamente apenas
-- essa procedure no banco de teste, fora de qualquer transacao. Nao use versoes
-- simplificadas nem copie formulas para substituir as procedures reais.
-- As procedures de projeto/cliente permanecem inalteradas; o executor abaixo
-- desabilita safe updates ao chama-las e restaura o valor original ao terminar.

-- D. CENARIOS (selecionar de USE ate o final; executar somente apos A/B/C)
USE feedbacks_portfolio_test;
DELIMITER //
CREATE PROCEDURE feedbacks_portfolio_test.test_pd_check_v1(
    IN p_case VARCHAR(100),
    IN p_expected_1 DECIMAL(12,2), IN p_actual_1 DECIMAL(12,2),
    IN p_expected_2 DECIMAL(12,2), IN p_actual_2 DECIMAL(12,2),
    INOUT p_failures INT
)
BEGIN
    -- Nos testes de metricas: valor 1 = CSAT e valor 2 = NPS.
    -- Nos testes de estado/integridade: valor 1 = flag, contagem ou errno.
    IF NOT ((p_expected_1 <=> p_actual_1) AND (p_expected_2 <=> p_actual_2)) THEN
        SET p_failures = p_failures + 1;
    END IF;
    SELECT p_case AS cenario,
           p_expected_1 AS esperado_1, p_actual_1 AS obtido_1,
           p_expected_2 AS esperado_2, p_actual_2 AS obtido_2,
           IF((p_expected_1 <=> p_actual_1) AND (p_expected_2 <=> p_actual_2),
              'PASS', 'FAIL') AS resultado;
END //

CREATE PROCEDURE feedbacks_portfolio_test.test_pd_run_v1()
BEGIN
    DECLARE v_safe BOOLEAN DEFAULT @@session.sql_safe_updates;
    DECLARE v_started BOOLEAN DEFAULT FALSE;
    DECLARE v_failures INT DEFAULT 0;
    DECLARE v_errno INT DEFAULT 0;
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_customer INT;
    DECLARE v_a INT UNSIGNED;
    DECLARE v_b INT UNSIGNED;
    DECLARE v_c INT UNSIGNED;
    DECLARE v_d INT UNSIGNED;
    DECLARE v_empty INT UNSIGNED;
    DECLARE v_prefix VARCHAR(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_p1 VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_p2 VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_p3 VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_missing VARCHAR(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    DECLARE v_x DECIMAL(5,2);
    DECLARE v_y DECIMAL(5,2);
    DECLARE v_p1_csat DECIMAL(5,2);
    DECLARE v_p1_nps DECIMAL(5,2);
    DECLARE v_p2_csat DECIMAL(5,2);
    DECLARE v_p2_nps DECIMAL(5,2);
    DECLARE v_customer_csat DECIMAL(5,2);
    DECLARE v_customer_nps DECIMAL(5,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        IF v_started THEN
            ROLLBACK;
        END IF;
        SET SESSION sql_safe_updates = v_safe;
        RESIGNAL;
    END;

    IF DATABASE() <> 'feedbacks_portfolio_test'
       OR @@session.foreign_key_checks <> 1
       OR @@session.autocommit <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Use banco local de teste, autocommit=1 e FKs ativas.';
    END IF;
    SELECT COUNT(*) INTO v_count
    FROM information_schema.tables
    WHERE table_schema = 'feedbacks_portfolio_test' AND engine = 'InnoDB'
      AND table_name IN ('departments', 'projects', 'customers',
                         'projects_departments', 'customers_projects',
                         'tasklists', 'feedbacks');
    IF v_count <> 7 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prepare e confira as sete tabelas InnoDB em A/B.';
    END IF;
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'feedbacks_portfolio_test' AND routine_type = 'PROCEDURE'
      AND routine_name IN ('sp_calculate_csat_nps_department',
                           'sp_calculate_csat_nps_project',
                           'sp_calculate_csat_nps_customer');
    IF v_count <> 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Instale as tres procedures reais conforme C.';
    END IF;

    SET v_prefix = CONCAT('pdtest_', REPLACE(UUID(), '-', ''));
    SET v_p1 = CONCAT(v_prefix, '_p1');
    SET v_p2 = CONCAT(v_prefix, '_p2');
    SET v_p3 = CONCAT(v_prefix, '_p3');
    SET v_missing = CONCAT(v_prefix, '_none');
    -- UUID + prefixo identificavel; PK/UNIQUE continuam detectando qualquer colisao.
    IF EXISTS (SELECT 1 FROM projects WHERE id_project LIKE CONCAT(v_prefix, '%'))
       OR EXISTS (SELECT 1 FROM tasklists WHERE id_tasklist LIKE CONCAT(v_prefix, '%'))
       OR EXISTS (SELECT 1 FROM feedbacks WHERE id_feedback LIKE CONCAT(v_prefix, '%'))
       OR EXISTS (SELECT 1 FROM departments WHERE name_department LIKE CONCAT(v_prefix, '%'))
       OR EXISTS (SELECT 1 FROM customers WHERE name_customer LIKE CONCAT(v_prefix, '%'))
       OR EXISTS (SELECT 1 FROM departments WHERE id_department = 4294967295) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Colisao de fixture ou ID reservado: teste abortado.';
    END IF;

    START TRANSACTION;
    SET v_started = TRUE;

    INSERT INTO departments (name_department, csat_department, nps_department)
    VALUES (CONCAT(v_prefix, '_a'), 99, 99);
    SET v_a = LAST_INSERT_ID();
    INSERT INTO departments (name_department, csat_department, nps_department)
    VALUES (CONCAT(v_prefix, '_b'), 99, 99);
    SET v_b = LAST_INSERT_ID();
    INSERT INTO departments (name_department, csat_department, nps_department)
    VALUES (CONCAT(v_prefix, '_c'), 99, 99);
    SET v_c = LAST_INSERT_ID();
    INSERT INTO departments (name_department, csat_department, nps_department)
    VALUES (CONCAT(v_prefix, '_d'), 99, 99);
    SET v_d = LAST_INSERT_ID();
    INSERT INTO departments (name_department, csat_department, nps_department)
    VALUES (CONCAT(v_prefix, '_e'), 99, 99);
    SET v_empty = LAST_INSERT_ID();

    INSERT INTO projects (id_project, name_project) VALUES
        (v_p1, CONCAT(v_prefix, '_projeto_1')),
        (v_p2, CONCAT(v_prefix, '_projeto_2')),
        (v_p3, CONCAT(v_prefix, '_projeto_null'));
    -- Cliente tem BU E pelo nome; E deve permanecer sem metricas mesmo com esse
    -- cliente ligado a projetos avaliados. Nao inferimos BU a partir do cliente.
    INSERT INTO customers (name_customer, name_department)
    VALUES (CONCAT(v_prefix, '_cliente'), CONCAT(v_prefix, '_e'));
    SET v_customer = LAST_INSERT_ID();
    INSERT INTO customers_projects (id_customer, id_project) VALUES
        (v_customer, v_p1), (v_customer, v_p2), (v_customer, v_p3);
    INSERT INTO projects_departments (id_project, id_department) VALUES
        (v_p1, v_a), (v_p1, v_b), (v_p2, v_a), (v_p3, v_d);
    -- Caminho canonico preenchido explicitamente; nao depende da importacao.
    INSERT INTO tasklists (id_tasklist, id_project) VALUES
        (CONCAT(v_prefix, '_t1'), v_p1),
        (CONCAT(v_prefix, '_t2'), v_p2),
        (CONCAT(v_prefix, '_t3'), v_p3);
    -- P1: tres notas validas, duas iguais; P2: NULLs independentes por metrica.
    -- Quantidades de participantes diferentes detectam ponderacao indevida.
    INSERT INTO feedbacks
        (id_feedback, id_tasklist, csat_feedback, nps_feedback, total_participants)
    VALUES
        (CONCAT(v_prefix, '_f1'), CONCAT(v_prefix, '_t1'), 80, 20, 1),
        (CONCAT(v_prefix, '_f2'), CONCAT(v_prefix, '_t1'), 80, 20, 100),
        (CONCAT(v_prefix, '_f3'), CONCAT(v_prefix, '_t1'), 20, -40, 7),
        (CONCAT(v_prefix, '_f4'), CONCAT(v_prefix, '_t1'), NULL, NULL, 50),
        (CONCAT(v_prefix, '_f5'), CONCAT(v_prefix, '_t2'), 100, 100, 2),
        (CONCAT(v_prefix, '_f6'), CONCAT(v_prefix, '_t2'), 60, NULL, 200),
        (CONCAT(v_prefix, '_f7'), CONCAT(v_prefix, '_t2'), NULL, 40, 3),
        (CONCAT(v_prefix, '_f8'), CONCAT(v_prefix, '_t3'), NULL, NULL, 4);

    SET SESSION sql_safe_updates = 1;
    CALL sp_calculate_csat_nps_department();
    CALL test_pd_check_v1('BU preserva safe_updates=1',
        1, @@session.sql_safe_updates, NULL, NULL, v_failures);
    SET SESSION sql_safe_updates = 0;
    CALL sp_calculate_csat_nps_department();
    CALL test_pd_check_v1('BU preserva safe_updates=0',
        0, @@session.sql_safe_updates, NULL, NULL, v_failures);
    CALL sp_calculate_csat_nps_project();
    CALL sp_calculate_csat_nps_customer();

    -- Esperados independentes:
    -- P1/B: CSAT=(80+80+20)/3=60; NPS=(20+20-40)/3=0.
    -- P2: CSAT=(100+60)/2=80; NPS=(100+40)/2=70.
    -- A/cliente: CSAT=(80+80+20+100+60)/5=68;
    --            NPS=(20+20-40+100+40)/5=28.
    -- D: apenas metricas NULL; C/E: nenhuma avaliacao; antigos 99 viram NULL.
    SELECT csat_department, nps_department INTO v_x, v_y
    FROM departments WHERE id_department = v_a;
    CALL test_pd_check_v1('BU A: P1 e P2, peso por avaliacao', 68, v_x, 28, v_y, v_failures);
    SELECT csat_department, nps_department INTO v_x, v_y
    FROM departments WHERE id_department = v_b;
    CALL test_pd_check_v1('BU B: P1, notas iguais contam separadamente', 60, v_x, 0, v_y, v_failures);
    SELECT csat_department, nps_department INTO v_x, v_y
    FROM departments WHERE id_department = v_c;
    CALL test_pd_check_v1('BU C inicialmente vazia limpa valores antigos', NULL, v_x, NULL, v_y, v_failures);
    SELECT csat_department, nps_department INTO v_x, v_y
    FROM departments WHERE id_department = v_d;
    CALL test_pd_check_v1('BU D com avaliacao toda NULL limpa valores antigos', NULL, v_x, NULL, v_y, v_failures);
    SELECT csat_department, nps_department INTO v_x, v_y
    FROM departments WHERE id_department = v_empty;
    CALL test_pd_check_v1('BU E do cliente nao herda avaliacoes dos projetos', NULL, v_x, NULL, v_y, v_failures);

    SELECT csat_project, nps_project INTO v_p1_csat, v_p1_nps FROM projects WHERE id_project = v_p1;
    CALL test_pd_check_v1('P1 com duas BUs conta cada avaliacao uma vez',
        60, v_p1_csat, 0, v_p1_nps, v_failures);
    SELECT csat_project, nps_project INTO v_p2_csat, v_p2_nps FROM projects WHERE id_project = v_p2;
    CALL test_pd_check_v1('P2 com uma BU: NULL ignorado por metrica',
        80, v_p2_csat, 70, v_p2_nps, v_failures);
    SELECT csat_project, nps_project INTO v_x, v_y FROM projects WHERE id_project = v_p3;
    CALL test_pd_check_v1('P3 apenas NULL', NULL, v_x, NULL, v_y, v_failures);
    SELECT csat_customer, nps_customer INTO v_customer_csat, v_customer_nps
    FROM customers WHERE id_customer = v_customer;
    CALL test_pd_check_v1('Cliente: peso por avaliacao, sem multiplicar BUs',
        68, v_customer_csat, 28, v_customer_nps, v_failures);

    INSERT INTO projects_departments (id_project, id_department) VALUES (v_p1, v_c);
    CALL sp_calculate_csat_nps_department();
    CALL sp_calculate_csat_nps_project();
    CALL sp_calculate_csat_nps_customer();
    SELECT csat_department, nps_department INTO v_x, v_y FROM departments WHERE id_department = v_c;
    CALL test_pd_check_v1('Nova BU C herda todas as avaliacoes de P1', 60, v_x, 0, v_y, v_failures);
    SELECT csat_department, nps_department INTO v_x, v_y FROM departments WHERE id_department = v_a;
    CALL test_pd_check_v1('BU A permanece igual ao adicionar C', 68, v_x, 28, v_y, v_failures);
    SELECT csat_project, nps_project INTO v_x, v_y FROM projects WHERE id_project = v_p1;
    CALL test_pd_check_v1('P1 invariante ao adicionar terceira BU',
        v_p1_csat, v_x, v_p1_nps, v_y, v_failures);
    SELECT csat_project, nps_project INTO v_x, v_y FROM projects WHERE id_project = v_p2;
    CALL test_pd_check_v1('P2 invariante ao adicionar BU em P1',
        v_p2_csat, v_x, v_p2_nps, v_y, v_failures);
    SELECT csat_customer, nps_customer INTO v_x, v_y FROM customers WHERE id_customer = v_customer;
    CALL test_pd_check_v1('Cliente invariante ao adicionar terceira BU',
        v_customer_csat, v_x, v_customer_nps, v_y, v_failures);
    SELECT COUNT(*) INTO v_count FROM customers
    WHERE id_customer = v_customer AND name_department = CONCAT(v_prefix, '_e');
    CALL test_pd_check_v1('Vinculo cliente-BU pelo nome preservado', 1, v_count, NULL, NULL, v_failures);

    -- Handlers limitados a UMA instrucao e ao codigo exato esperado.
    -- Qualquer outro erro chega ao EXIT HANDLER: ROLLBACK, restauracao, RESIGNAL.
    SET v_errno = 0;
    BEGIN
        DECLARE CONTINUE HANDLER FOR 1062 SET v_errno = 1062;
        INSERT INTO projects_departments (id_project, id_department) VALUES (v_p1, v_a);
    END;
    CALL test_pd_check_v1('Vinculo duplicado rejeitado: errno 1062',
        1062, v_errno, NULL, NULL, v_failures);

    SET v_errno = 0;
    BEGIN
        DECLARE CONTINUE HANDLER FOR 1452 SET v_errno = 1452;
        INSERT INTO projects_departments (id_project, id_department) VALUES (v_missing, v_a);
    END;
    CALL test_pd_check_v1('Projeto inexistente rejeitado: errno 1452',
        1452, v_errno, NULL, NULL, v_failures);

    SET v_errno = 0;
    BEGIN
        DECLARE CONTINUE HANDLER FOR 1452 SET v_errno = 1452;
        INSERT INTO projects_departments (id_project, id_department) VALUES (v_p1, 4294967295);
    END;
    CALL test_pd_check_v1('BU inexistente rejeitada: errno 1452',
        1452, v_errno, NULL, NULL, v_failures);
    SELECT COUNT(*) INTO v_count FROM projects_departments
    WHERE id_project IN (v_p1, v_p2, v_p3, v_missing);
    CALL test_pd_check_v1('Somente cinco vinculos validos persistem na transacao',
        5, v_count, NULL, NULL, v_failures);

    ROLLBACK;
    SET v_started = FALSE;
    SET SESSION sql_safe_updates = v_safe;
    CALL test_pd_check_v1('Estado original de safe_updates restaurado',
        v_safe, @@session.sql_safe_updates, NULL, NULL, v_failures);
    SELECT
        (SELECT COUNT(*) FROM projects WHERE id_project LIKE CONCAT(v_prefix, '%')) +
        (SELECT COUNT(*) FROM departments WHERE name_department LIKE CONCAT(v_prefix, '%')) +
        (SELECT COUNT(*) FROM customers WHERE id_customer = v_customer) +
        (SELECT COUNT(*) FROM tasklists WHERE id_tasklist LIKE CONCAT(v_prefix, '%')) +
        (SELECT COUNT(*) FROM feedbacks WHERE id_feedback LIKE CONCAT(v_prefix, '%')) +
        (SELECT COUNT(*) FROM projects_departments WHERE id_project LIKE CONCAT(v_prefix, '%')) +
        (SELECT COUNT(*) FROM customers_projects WHERE id_customer = v_customer)
    INTO v_count;
    CALL test_pd_check_v1('ROLLBACK removeu todos os dados ficticios',
        0, v_count, NULL, NULL, v_failures);
    SELECT v_prefix AS fixture, 0 AS falhas_esperadas, v_failures AS falhas_obtidas,
           IF(v_failures = 0, 'PASS', 'FAIL') AS resultado_final;
    IF v_failures <> 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'FAIL: consulte resultados; dados ja revertidos.';
    END IF;
END //
DELIMITER ;
CALL feedbacks_portfolio_test.test_pd_run_v1();
-- Limpeza apenas de helpers de teste, fora da transacao.
-- Se o CALL falhar, inspecione o erro: o handler reverte dados e restaura safe updates.
-- Depois da analise, estas duas instrucoes podem ser executadas manualmente.
DROP PROCEDURE feedbacks_portfolio_test.test_pd_run_v1;
DROP PROCEDURE feedbacks_portfolio_test.test_pd_check_v1;
