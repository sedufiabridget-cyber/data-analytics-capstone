-- ============================================================
-- Roblox Africa Operations — Workforce Intelligence Project
-- schema.sql — table creation + indexes
-- Run this FIRST, before analysis_queries.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS roblox_workforce;
USE roblox_workforce;

DROP TABLE IF EXISTS employee_performance_yearly;
DROP TABLE IF EXISTS department_performance_yearly;
DROP TABLE IF EXISTS employee_analytics;

-- ------------------------------------------------------------
-- Dimension table: one row per employee (30,000 rows)
-- ------------------------------------------------------------
CREATE TABLE employee_analytics (
    EmployeeID              INT PRIMARY KEY,
    Department_Code           VARCHAR(5),
    department_name             VARCHAR(40),
    Position                     VARCHAR(20),
    Gender                        VARCHAR(10),
    Age                            INT,
    Tenure_Years                    DECIMAL(4,1),
    employee_status                  VARCHAR(15),
    Education_Level                    VARCHAR(20),
    Field_of_Study                       VARCHAR(40),
    Basic_Salary                          DECIMAL(10,2),
    Allowances                             DECIMAL(10,2),
    Total_Compensation                       DECIMAL(10,2),
    Insurance_status                          VARCHAR(10),
    Medical_leave_eligible                     VARCHAR(5),
    Medical_leave_balance                       INT,
    Avg_Performance_Score                        DECIMAL(4,2),
    Total_Projects_Completed                      INT,
    Avg_Training_Hours                             DECIMAL(5,2),
    Avg_Attendance_Rate                             DECIMAL(5,2),
    Bonus_Years_Count                                INT
);

-- ------------------------------------------------------------
-- Fact table: one row per employee per year, 2021-2025 (150,000 rows)
-- ------------------------------------------------------------
CREATE TABLE employee_performance_yearly (
    EmployeeID          INT,
    Year                 INT,
    Performance_Score     DECIMAL(4,2),
    Projects_Completed      INT,
    Training_Hours           DECIMAL(5,2),
    Attendance_Rate            DECIMAL(5,2),
    Bonus_Awarded                VARCHAR(5),
    FOREIGN KEY (EmployeeID) REFERENCES employee_analytics(EmployeeID)
);

-- ------------------------------------------------------------
-- Fact table: one row per department per year, 2021-2025 (40 rows)
-- ------------------------------------------------------------
CREATE TABLE department_performance_yearly (
    Department_Code           VARCHAR(5),
    Department                 VARCHAR(40),
    Year                         INT,
    Average_Performance_Score     DECIMAL(4,2),
    Total_Revenue_Generated        DECIMAL(14,2),
    Total_Cost                      DECIMAL(14,2),
    Training_Hours_Completed         DECIMAL(6,2)
);

-- ------------------------------------------------------------
-- Indexes — speeds up every GROUP BY / JOIN in analysis_queries.sql
-- ------------------------------------------------------------
CREATE INDEX idx_ea_dept ON employee_analytics(Department_Code);
CREATE INDEX idx_ea_edu ON employee_analytics(Education_Level);
CREATE INDEX idx_epy_emp ON employee_performance_yearly(EmployeeID);
CREATE INDEX idx_epy_year ON employee_performance_yearly(Year);
CREATE INDEX idx_dpy_dept ON department_performance_yearly(Department_Code);
CREATE INDEX idx_dpy_year ON department_performance_yearly(Year);

-- ------------------------------------------------------------
-- Load data: use MySQL Workbench's Table Data Import Wizard
-- (right-click roblox_workforce schema -> Table Data Import Wizard)
-- pointing at the 3 CSVs in /data:
--   powerbi_employee_analytics.csv              -> employee_analytics
--   powerbi_employee_performance_yearly.csv      -> employee_performance_yearly
--   powerbi_department_performance_yearly.csv    -> department_performance_yearly
-- ------------------------------------------------------------

-- Verify row counts after loading:
SELECT 'employee_analytics' AS tbl, COUNT(*) AS rows_loaded FROM employee_analytics
UNION ALL
SELECT 'employee_performance_yearly', COUNT(*) FROM employee_performance_yearly
UNION ALL
SELECT 'department_performance_yearly', COUNT(*) FROM department_performance_yearly;
