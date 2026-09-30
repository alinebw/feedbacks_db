-- Each feedback contributes once to each BU of its project, with equal weight.
-- AVG ignores NULL; an empty/all-NULL set clears previously stored metrics.
DELIMITER //

CREATE PROCEDURE sp_calculate_csat_nps_department ()
BEGIN
    DECLARE v_safe_updates BOOLEAN DEFAULT @@SESSION.sql_safe_updates;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET SESSION sql_safe_updates = v_safe_updates;
        RESIGNAL;
    END;

    SET SESSION sql_safe_updates = 0;

    UPDATE departments d
    SET
        csat_department = (
            SELECT AVG(f.csat_feedback)
            FROM projects_departments pd
            JOIN projects p ON p.id_project = pd.id_project
            JOIN tasklists t ON t.id_project = p.id_project
            JOIN feedbacks f ON f.id_tasklist = t.id_tasklist
            WHERE pd.id_department = d.id_department
        ),
        nps_department = (
            SELECT AVG(f.nps_feedback)
            FROM projects_departments pd
            JOIN projects p ON p.id_project = pd.id_project
            JOIN tasklists t ON t.id_project = p.id_project
            JOIN feedbacks f ON f.id_tasklist = t.id_tasklist
            WHERE pd.id_department = d.id_department
        );

    SET SESSION sql_safe_updates = v_safe_updates;
END //

DELIMITER ;
