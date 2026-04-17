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



-- --------------------------------------------
-- TASK 2: Attrition Analysis by Department and Job Role
-- --------------------------------------------

-- Part A: Attrition by Department
WITH attrition_by_dept AS (
    SELECT
        department,
        COUNT(*)                                                     AS headcount,
        COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)                AS attrition_count,
        ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)::NUMERIC
              * 100.0 / NULLIF(COUNT(*), 0), 2)                      AS attrition_rate_pct
    FROM employees
    GROUP BY department
)
SELECT
    department,
    headcount,
    attrition_count,
    attrition_rate_pct,
    DENSE_RANK() OVER (ORDER BY attrition_rate_pct DESC)             AS attrition_rank
FROM attrition_by_dept
ORDER BY attrition_rate_pct DESC;


-- Part B: Attrition by Job Role (rate > 15% only)
WITH attrition_by_role AS (
    SELECT
        job_role,
        COUNT(*)                                                     AS headcount,
        COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)                AS attrition_count,
        ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)::NUMERIC
              * 100.0 / NULLIF(COUNT(*), 0), 2)                      AS attrition_rate_pct
    FROM employees
    GROUP BY job_role
    HAVING ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)::NUMERIC
                 * 100.0 / NULLIF(COUNT(*), 0), 2) > 15
)
SELECT
    job_role,
    headcount,
    attrition_count,
    attrition_rate_pct,
    DENSE_RANK() OVER (ORDER BY attrition_rate_pct DESC)             AS attrition_rank
FROM attrition_by_role
ORDER BY attrition_rate_pct DESC;




-- --------------------------------------------
-- TASK 3: Compensation Analysis
-- --------------------------------------------

-- Part A: Gender Pay Comparison per Department
WITH gender_pay_dept AS (
    SELECT
        department,
        ROUND(AVG(monthly_income), 2)                                AS avg_monthly_income,
        ROUND(AVG(monthly_income) FILTER (WHERE gender = 'Male'), 2) AS male_avg_income,
        ROUND(AVG(monthly_income) FILTER (WHERE gender = 'Female'), 2) AS female_avg_income
    FROM employees
    GROUP BY department
)
SELECT
    department,
    avg_monthly_income,
    male_avg_income,
    female_avg_income,
    male_avg_income - female_avg_income                              AS pay_gap,
    ROUND((male_avg_income - female_avg_income) * 100.0
          / NULLIF(female_avg_income, 0), 2)                         AS pay_gap_pct
FROM gender_pay_dept
ORDER BY pay_gap DESC;


-- Part B: Compensation by Job Level
SELECT
    job_level,
    COUNT(*)                                                         AS headcount,
    ROUND(AVG(monthly_income), 2)                                    AS avg_monthly_income,
    MIN(monthly_income)                                              AS min_monthly_income,
    MAX(monthly_income)                                              AS max_monthly_income,
    ROUND(AVG(percent_salary_hike), 2)                               AS avg_salary_hike_pct,
    DENSE_RANK() OVER (ORDER BY AVG(monthly_income) DESC)            AS income_rank
FROM employees
GROUP BY job_level
ORDER BY job_level;



-- --------------------------------------------
-- TASK 4: Tenure and Promotion Analysis
-- --------------------------------------------
WITH tenure_buckets AS (
    SELECT
        CASE
            WHEN years_at_company <= 2  THEN '0-2 years'
            WHEN years_at_company <= 5  THEN '3-5 years'
            WHEN years_at_company <= 10 THEN '6-10 years'
            ELSE '10+ years'
        END                                                          AS tenure_bucket,
        COUNT(*)                                                     AS total_employees,
        ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)::NUMERIC
              * 100.0 / NULLIF(COUNT(*), 0), 2)                      AS attrition_rate_pct,
        ROUND(AVG(monthly_income), 2)                                AS avg_monthly_income,
        ROUND(AVG(years_since_last_promotion), 2)                    AS avg_years_since_promotion,
        ROUND(AVG(years_at_company)
              / NULLIF(AVG(years_since_last_promotion), 0), 2)       AS promotion_rate,
        ROUND(AVG(job_satisfaction), 2)                              AS avg_job_satisfaction
    FROM employees
    GROUP BY tenure_bucket
)
SELECT *
FROM tenure_buckets
ORDER BY
    CASE tenure_bucket
        WHEN '0-2 years'  THEN 1
        WHEN '3-5 years'  THEN 2
        WHEN '6-10 years' THEN 3
        WHEN '10+ years'  THEN 4
    END;
	
	



-- --------------------------------------------
-- TASK 5: Satisfaction and Attrition Analysis
-- --------------------------------------------
WITH satisfaction_buckets AS (
    SELECT
        CASE
            WHEN job_satisfaction = 1 THEN 'Low'
            WHEN job_satisfaction = 2 THEN 'Medium'
            WHEN job_satisfaction = 3 THEN 'High'
            WHEN job_satisfaction = 4 THEN 'Very High'
        END                                                          AS satisfaction_level,
        job_satisfaction,
        COUNT(*)                                                     AS total_employees,
        ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END)::NUMERIC
              * 100.0 / NULLIF(COUNT(*), 0), 2)                      AS attrition_rate_pct,
        ROUND(AVG(monthly_income), 2)                                AS avg_monthly_income,
        ROUND(COUNT(overtime) FILTER (WHERE overtime = 'Yes')
              * 100.0 / COUNT(overtime), 2)                          AS overtime_rate_pct,
        ROUND(AVG(work_life_balance), 2)                             AS avg_work_life_balance
    FROM employees
    GROUP BY job_satisfaction
)
SELECT
    satisfaction_level,
    total_employees,
    attrition_rate_pct,
    avg_monthly_income,
    overtime_rate_pct,
    avg_work_life_balance
FROM satisfaction_buckets
ORDER BY job_satisfaction;

-- --------------------------------------------
-- TASK 6: Income Progression by Job Level
-- --------------------------------------------
WITH income_by_level AS (
    SELECT
        job_level,
        COUNT(*)                                                     AS headcount,
        ROUND(AVG(monthly_income), 2)                                AS avg_monthly_income,
        MIN(monthly_income)                                          AS min_monthly_income,
        MAX(monthly_income)                                          AS max_monthly_income,
        MAX(monthly_income) - MIN(monthly_income)                    AS income_range,
        LEAD(ROUND(AVG(monthly_income), 2), 1)
            OVER (ORDER BY job_level)                                AS next_level_avg_income
    FROM employees
    GROUP BY job_level
)
SELECT
    job_level,
    headcount,
    avg_monthly_income,
    min_monthly_income,
    max_monthly_income,
    income_range,
    next_level_avg_income,
    ROUND(next_level_avg_income - avg_monthly_income, 2)             AS income_jump,
    ROUND((next_level_avg_income - avg_monthly_income)
          * 100.0 / NULLIF(avg_monthly_income, 0), 2)               AS income_jump_pct
FROM income_by_level
ORDER BY job_level;



-- --------------------------------------------
-- TASK 7: Employee Directory
-- --------------------------------------------
SELECT
    employee_number,
    CONCAT(INITCAP(job_role), ' - ', INITCAP(department))            AS role_department,
    INITCAP(gender)                                                  AS gender,
    INITCAP(education_field)                                         AS education_field,
    CASE
        WHEN job_level <= 2 THEN 'Junior'
        WHEN job_level  = 3 THEN 'Mid-Level'
        ELSE 'Senior'
    END                                                              AS seniority_level,
    CASE
        WHEN monthly_income >= 10000 THEN 'High Earner'
        WHEN monthly_income >= 5000  THEN 'Mid Earner'
        ELSE 'Low Earner'
    END                                                              AS income_label,
    CASE
        WHEN overtime = 'Yes' THEN 'Overtime'
        ELSE 'Standard'
    END                                                              AS work_schedule
FROM employees
ORDER BY employee_number;




























