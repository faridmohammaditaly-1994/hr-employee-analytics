-- ============================================
-- Project: HR Employee Analytics
-- File: setup.sql
-- Purpose: Schema setup and table creation
-- ============================================

-- --------------------------------------------
-- STEP 1: Create Schema
-- --------------------------------------------
CREATE SCHEMA IF NOT EXISTS hr;

-- --------------------------------------------
-- STEP 2: Create Table with clean column names
-- --------------------------------------------
CREATE TABLE hr.employees (
    age                        INT,
    attrition                  VARCHAR(5),
    business_travel            VARCHAR(50),
    daily_rate                 INT,
    department                 VARCHAR(50),
    distance_from_home         INT,
    education                  INT,
    education_field            VARCHAR(50),
    employee_count             INT,
    employee_number            INT,
    environment_satisfaction   INT,
    gender                     VARCHAR(10),
    hourly_rate                INT,
    job_involvement            INT,
    job_level                  INT,
    job_role                   VARCHAR(50),
    job_satisfaction           INT,
    marital_status             VARCHAR(20),
    monthly_income             INT,
    monthly_rate               INT,
    num_companies_worked       INT,
    over18                     VARCHAR(5),
    overtime                   VARCHAR(5),
    percent_salary_hike        INT,
    performance_rating         INT,
    relationship_satisfaction  INT,
    standard_hours             INT,
    stock_option_level         INT,
    total_working_years        INT,
    training_times_last_year   INT,
    work_life_balance          INT,
    years_at_company           INT,
    years_in_current_role      INT,
    years_since_last_promotion INT,
    years_with_curr_manager    INT
);

-- --------------------------------------------
-- STEP 3: Notes
-- --------------------------------------------
-- Data imported via DBeaver CSV import wizard
-- All columns mapped to clean lowercase names
-- Source: WA_Fn-UseC_-HR-Employee-Attrition.csv
-- Rows loaded: 1470