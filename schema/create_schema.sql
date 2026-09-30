
-- Table structure for table `feedbacks`
--

DROP TABLE IF EXISTS `feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
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


-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
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


-- Table structure for table `tasklists`
--

DROP TABLE IF EXISTS `tasklists`;
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


-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
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


-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
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

-- Table structure for table `projects_departments`
-- Created after both parent tables; one row per project/department pair.
DROP TABLE IF EXISTS `projects_departments`;
CREATE TABLE `projects_departments` (
  `id_project` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_department` int unsigned NOT NULL,
  PRIMARY KEY (`id_project`, `id_department`),
  KEY `idx_projects_departments_department` (`id_department`),
  CONSTRAINT `fk_projects_departments_project` FOREIGN KEY (`id_project`) REFERENCES `projects` (`id_project`),
  CONSTRAINT `fk_projects_departments_department` FOREIGN KEY (`id_department`) REFERENCES `departments` (`id_department`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Table structure for table `customers_projects`
--

DROP TABLE IF EXISTS `customers_projects`;
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


-- Table structure for table `deliverables`
--

DROP TABLE IF EXISTS `deliverables`;
CREATE TABLE `deliverables` (
  `id_deliverable` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_feedback` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `received_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `csat_deliverable` decimal(5,2) DEFAULT NULL,
  `respondent_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nps` decimal(5,2) DEFAULT NULL COMMENT 'NPS score for the deliverable',
  `csat_content` decimal(5,2) DEFAULT NULL COMMENT 'CSAT score for the content of the deliverable',
  `csat_consultant` decimal(5,2) DEFAULT NULL COMMENT 'CSAT score for the consultant of the deliverable',
  `csat_event` decimal(5,2) DEFAULT NULL COMMENT 'CSAT score for the event of the deliverable',
  `nps_status` enum('Promoter','Neutral','Detractor') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'NPS classification for the deliverable',
  `mandatory_comment` text COLLATE utf8mb4_unicode_ci COMMENT 'Mandatory comment from the form',
  `optional_comment` text COLLATE utf8mb4_unicode_ci COMMENT 'Optional comment from the form',
  `average_csat` decimal(5,2) DEFAULT NULL COMMENT 'Overall CSAT average for the deliverable calculated based on specific scores',
  `status` enum('PENDING','PROCESSED') COLLATE utf8mb4_unicode_ci DEFAULT 'PENDING',
  `processing_date` datetime DEFAULT NULL,
  `id_project` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_tasklist` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `csat_content_option` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `csat_content_online_option` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `platform_accessible` varchar(3) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Indicates if the platform was considered accessible by the respondent',
  `type_feedback` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Indicates if the feedback is In-person or Online',
  PRIMARY KEY (`id_deliverable`),
  KEY `idx_deliverables_idfeedback_iddeliverable` (`id_feedback`, `id_deliverable`),
  KEY `idx_deliverables_nps` (`nps`),
  KEY `idx_deliverables_csat_content` (`csat_content`),
  KEY `idx_deliverables_csat_event` (`csat_event`),
  KEY `idx_deliverables_received_date` (`received_date`),
  KEY `idx_deliverables_csat_consultant` (`csat_consultant`),
  KEY `idx_deliverables_csat_deliverable` (`csat_deliverable`),
  KEY `fk_deliverable_project` (`id_project`),
  CONSTRAINT `fk_deliverable_feedback` FOREIGN KEY (`id_feedback`) REFERENCES `feedbacks` (`id_feedback`),
  CONSTRAINT `fk_deliverable_project` FOREIGN KEY (`id_project`) REFERENCES `projects` (`id_project`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Table structure for table `questions`
--

DROP TABLE IF EXISTS `questions`;
CREATE TABLE `questions` (
  `id_question` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_feedback` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `order` int NOT NULL,
  `ref` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_question`, `id_feedback`),
  KEY `idx_questions_question_type` (`question_type`),
  KEY `idx_questions_type_id` (`question_type`, `id_question`),
  KEY `idx_questions_idquestion_idfeedback` (`id_question`, `id_feedback`),
  KEY `idx_questions_idquestion` (`id_question`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Table structure for table `questions_deliverables`
--

DROP TABLE IF EXISTS `questions_deliverables`;
CREATE TABLE `questions_deliverables` (
  `id_question` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_deliverable` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_question`, `id_deliverable`),
  KEY `questions_deliverables_iddeliverable` (`id_deliverable`),
  CONSTRAINT `questions_deliverables_iddeliverable` FOREIGN KEY (`id_deliverable`) REFERENCES `deliverables` (`id_deliverable`),
  CONSTRAINT `questions_deliverables_idquestion` FOREIGN KEY (`id_question`) REFERENCES `questions` (`id_question`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Table structure for table `answers`
--

DROP TABLE IF EXISTS `answers`;
CREATE TABLE `answers` (
  `id_answer` int NOT NULL AUTO_INCREMENT,
  `id_deliverable` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_question` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_feedback` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `answer_value` decimal(5,2) DEFAULT NULL COMMENT 'Numeric value of the answer (for calculations like CSAT and NPS)',
  `answer_text` text COLLATE utf8mb4_unicode_ci COMMENT 'Text of the answer (comments or open-ended responses)',
  `answer_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Type of the answer (choice, rating, text, etc.)',
  `answer_json` json DEFAULT NULL COMMENT 'Stores the complete answer in JSON format for types like choice',
  `csat_content` decimal(5,2) DEFAULT NULL COMMENT 'Conversion of JSON answer to numeric values in choice type',
  `ref` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_answer`),
  KEY `idx_answers_deliverable` (`id_deliverable`),
  KEY `idx_answers_question_feedback` (`id_question`, `id_feedback`),
  KEY `idx_answers_iddeliverable_idquestion` (`id_deliverable`, `id_question`),
  KEY `idx_answers_idfeedback_iddeliverable` (`id_feedback`, `id_deliverable`),
  KEY `idx_answers_answer_value` (`answer_value`),
  KEY `idx_answers_type_value` (`answer_type`, `answer_value`),
  FULLTEXT KEY `idx_answers_answer_text` (`answer_text`),
  CONSTRAINT `fk_answers_deliverable` FOREIGN KEY (`id_deliverable`) REFERENCES `deliverables` (`id_deliverable`),
  CONSTRAINT `fk_answers_question_feedback` FOREIGN KEY (`id_question`, `id_feedback`) REFERENCES `questions` (`id_question`, `id_feedback`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- Table structure for table `processing_logs`
--

DROP TABLE IF EXISTS `processing_logs`;
CREATE TABLE `processing_logs` (
  `id_log` int NOT NULL AUTO_INCREMENT,
  `id_deliverable` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_feedback` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `processing_date` datetime NOT NULL,
  `status` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id_log`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
