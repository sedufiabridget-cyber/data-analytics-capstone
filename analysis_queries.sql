-- ============================================================
-- Roblox Africa Operations — Workforce Intelligence Project
-- analysis_queries.sql — one query block per capstone objective
-- Run AFTER schema.sql and after data has been loaded
-- ============================================================

USE roblox_workforce;

-- ============================================================
-- OBJECTIVE 1: Workforce composition by department, role, gender
-- ============================================================
SELECT department_name,
       COUNT(*) AS headcount,
       ROUND(100 * SUM(Gender='Female') / COUNT(*), 1) AS pct_female,
       ROUND(AVG(Age), 1) AS avg_age,
       ROUND(AVG(Tenure_Years), 1) AS avg_tenure
FROM employee_analytics
GROUP BY department_name
ORDER BY headcount DESC;

SELECT department_name, Position, COUNT(*) AS headcount
FROM employee_analytics
GROUP BY department_name, Position
ORDER BY department_name, headcount DESC;

-- ============================================================
-- OBJECTIVE 2: Education level & field of study vs. job placement
-- ============================================================
SELECT Education_Level,
       COUNT(*) AS headcount,
       ROUND(AVG(Basic_Salary), 0) AS avg_salary,
       ROUND(AVG(Avg_Performance_Score), 2) AS avg_performance
FROM employee_analytics
GROUP BY Education_Level
ORDER BY avg_salary DESC;

SELECT department_name, Field_of_Study, COUNT(*) AS headcount
FROM employee_analytics
GROUP BY department_name, Field_of_Study
ORDER BY department_name, headcount DESC;

-- Salary spread across education levels, as a single % figure
SELECT ROUND(
    (MAX(avg_salary) - MIN(avg_salary)) / AVG(avg_salary) * 100, 2
) AS salary_spread_pct
FROM (
    SELECT Education_Level, AVG(Basic_Salary) AS avg_salary
    FROM employee_analytics
    GROUP BY Education_Level
) t;

-- ============================================================
-- OBJECTIVE 3: Compensation patterns & cost distribution
-- ============================================================
SELECT e.department_name,
       ROUND(AVG(e.Basic_Salary), 0) AS avg_salary,
       ROUND(SUM(e.Total_Compensation), 0) AS total_comp_spend,
       ROUND(SUM(d.Total_Revenue_Generated), 0) AS total_revenue,
       ROUND(SUM(d.Total_Cost), 0) AS total_cost,
       ROUND(SUM(d.Total_Revenue_Generated) / SUM(d.Total_Cost), 2) AS revenue_per_cost
FROM employee_analytics e
JOIN department_performance_yearly d ON e.Department_Code = d.Department_Code
GROUP BY e.department_name
ORDER BY revenue_per_cost;

-- ============================================================
-- OBJECTIVE 4: Health-related operational risks
-- ============================================================
SELECT department_name,
       ROUND(100 * SUM(Insurance_status='Expired') / COUNT(*), 1) AS pct_insurance_expired,
       ROUND(100 * SUM(Insurance_status='Pending') / COUNT(*), 1) AS pct_insurance_pending,
       ROUND(AVG(Medical_leave_balance), 1) AS avg_leave_balance,
       ROUND(100 * SUM(Medical_leave_eligible='No') / COUNT(*), 1) AS pct_not_leave_eligible
FROM employee_analytics
GROUP BY department_name
ORDER BY pct_insurance_expired DESC;

-- ============================================================
-- SUPPORTING: Employee status mix (attrition-risk proxy)
-- ============================================================
SELECT department_name,
       ROUND(100 * SUM(employee_status='Active') / COUNT(*), 1) AS pct_active,
       ROUND(100 * SUM(employee_status='On Leave') / COUNT(*), 1) AS pct_on_leave,
       ROUND(100 * SUM(employee_status='Inactive') / COUNT(*), 1) AS pct_inactive
FROM employee_analytics
GROUP BY department_name;

-- ============================================================
-- SUPPORTING: Training investment vs. productivity (feeds Objective 5)
-- ============================================================

-- Company-wide performance trend, 2021-2025
SELECT Year, ROUND(AVG(Average_Performance_Score), 2) AS company_avg_performance
FROM department_performance_yearly
GROUP BY Year
ORDER BY Year;

-- Correlation: training hours vs. performance / revenue / cost
-- (MySQL has no built-in CORREL() — this computes Pearson's r manually)
SELECT
    ROUND(
        (COUNT(*) * SUM(Training_Hours_Completed * Average_Performance_Score) - SUM(Training_Hours_Completed) * SUM(Average_Performance_Score))
        / (SQRT(COUNT(*) * SUM(POW(Training_Hours_Completed,2)) - POW(SUM(Training_Hours_Completed),2))
         * SQRT(COUNT(*) * SUM(POW(Average_Performance_Score,2)) - POW(SUM(Average_Performance_Score),2)))
    , 2) AS corr_training_vs_performance
FROM department_performance_yearly;

SELECT
    ROUND(
        (COUNT(*) * SUM(Training_Hours_Completed * Total_Revenue_Generated) - SUM(Training_Hours_Completed) * SUM(Total_Revenue_Generated))
        / (SQRT(COUNT(*) * SUM(POW(Training_Hours_Completed,2)) - POW(SUM(Training_Hours_Completed),2))
         * SQRT(COUNT(*) * SUM(POW(Total_Revenue_Generated,2)) - POW(SUM(Total_Revenue_Generated),2)))
    , 2) AS corr_training_vs_revenue
FROM department_performance_yearly;

SELECT
    ROUND(
        (COUNT(*) * SUM(Training_Hours_Completed * Total_Cost) - SUM(Training_Hours_Completed) * SUM(Total_Cost))
        / (SQRT(COUNT(*) * SUM(POW(Training_Hours_Completed,2)) - POW(SUM(Training_Hours_Completed),2))
         * SQRT(COUNT(*) * SUM(POW(Total_Cost,2)) - POW(SUM(Total_Cost),2)))
    , 2) AS corr_training_vs_cost
FROM department_performance_yearly;

-- ============================================================
-- OBJECTIVE 5: Recommendations — supporting query
-- Departments furthest from the norm on cost efficiency AND risk
-- (used to justify which departments to name in recommendations)
-- ============================================================
SELECT e.department_name,
       ROUND(SUM(d.Total_Revenue_Generated) / SUM(d.Total_Cost), 2) AS revenue_per_cost,
       ROUND(100 * SUM(e.Insurance_status='Expired') / COUNT(DISTINCT e.EmployeeID), 1) AS pct_insurance_expired
FROM employee_analytics e
JOIN department_performance_yearly d ON e.Department_Code = d.Department_Code
GROUP BY e.department_name
ORDER BY revenue_per_cost ASC;
