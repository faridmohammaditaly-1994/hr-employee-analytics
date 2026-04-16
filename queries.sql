-- ============================================
-- Project: HR Employee Analytics
-- Author: [Farid Mohammadi]
-- Tool: PostgreSQL
-- ============================================


-- --------------------------------------------
-- TASK 1: Workforce Overview + Data Audit
-- --------------------------------------------

-- Part A: Workforce Snapshot
SELECT
    COUNT(*)                                                         AS total_employees,
    COUNT(DISTINCT department)                                       AS total_departments,
    COUNT(DISTINCT job_role)                                         AS total_job_roles,
    COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)                    AS attrition_count,
    ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)::NUMERIC
          * 100.0 / NULLIF(COUNT(*), 0), 2)                          AS attrition_rate_pct,
    ROUND(AVG(age), 2)                                               AS avg_age,
    ROUND(AVG(monthly_income), 2)                                    AS avg_monthly_income,
    ROUND(AVG(years_at_company), 2)                                  AS avg_years_at_company
FROM employees;


-- Part B: Department Headcount
SELECT
    department,
    COUNT(*)                                                         AS headcount,
    COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)                    AS attrition_count,
    ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)::NUMERIC
          * 100.0 / NULLIF(COUNT(*), 0), 2)                          AS attrition_rate_pct
FROM employees
GROUP BY department
HAVING COUNT(*) > 50
ORDER BY attrition_rate_pct DESC;