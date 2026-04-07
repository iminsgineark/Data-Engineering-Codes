-- ==============================
-- 1. EMPLOYEES TABLE
-- ==============================
CREATE DATABASE WF;
USE WF;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT,
    dept VARCHAR(10),
    salary INT
);

INSERT INTO employees VALUES
(101, 'HR', 50000),
(102, 'HR', 45000),
(103, 'IT', 60000),
(104, 'IT', 55000);

-- Query 1: Total Payroll (Window Function)
SELECT 
    employee_id,
    salary,
    SUM(salary) OVER () AS total_payroll
FROM employees;

-- Query 2: Department-wise Total
SELECT 
    dept,
    employee_id,
    salary,
    SUM(salary) OVER (PARTITION BY dept) AS dept_total
FROM employees;


-- ==============================
-- 2. USER LOGINS TABLE
-- ==============================

DROP TABLE IF EXISTS user_logins;

CREATE TABLE user_logins (
    user_id VARCHAR(10),
    login_time TIMESTAMP
);

INSERT INTO user_logins VALUES
('U001', '2024-03-15 10:30:00'),
('U001', '2024-03-14 09:15:00'),
('U001', '2024-03-13 14:22:00'),
('U002', '2024-03-15 11:00:00'),
('U002', '2024-03-12 08:45:00');

-- Query 3: ROW_NUMBER Ranking
SELECT 
    user_id,
    login_time,
    ROW_NUMBER() OVER(
        PARTITION BY user_id 
        ORDER BY login_time DESC
    ) AS login_rank
FROM user_logins;

-- Query 4: Deduplication (Latest Login)
WITH ranked AS (
    SELECT 
        user_id,
        login_time,
        ROW_NUMBER() OVER(
            PARTITION BY user_id 
            ORDER BY login_time DESC
        ) AS rn
    FROM user_logins
)
SELECT user_id, login_time
FROM ranked
WHERE rn = 1;


-- ==============================
-- 3. EXAM RESULTS TABLE
-- ==============================

DROP TABLE IF EXISTS exam_results;

CREATE TABLE exam_results (
    student VARCHAR(20),
    score INT
);

INSERT INTO exam_results VALUES
('Alice', 95),
('Bob', 90),
('Carol', 90),
('Dave', 85),
('Eve', 80);

-- Query 5: RANK vs DENSE_RANK
SELECT 
    student,
    score,
    RANK() OVER(ORDER BY score DESC) AS rank_col,
    DENSE_RANK() OVER(ORDER BY score DESC) AS dense_rank_col
FROM exam_results;


-- ==============================
-- 4. DAILY PRICES TABLE
-- ==============================

DROP TABLE IF EXISTS daily_prices;

CREATE TABLE daily_prices (
    product_id VARCHAR(10),
    price_date DATE,
    price DECIMAL(10,2)
);

INSERT INTO daily_prices VALUES
('P001', '2024-03-01', 100.00),
('P001', '2024-03-02', 105.00),
('P001', '2024-03-03', 98.00),
('P001', '2024-03-04', 110.00);

-- Query 6: LAG (Previous Price)
SELECT 
    product_id,
    price_date,
    price,
    LAG(price) OVER(
        PARTITION BY product_id 
        ORDER BY price_date
    ) AS prev_price
FROM daily_prices;

-- Query 7: LEAD (Next Price)
SELECT 
    product_id,
    price_date,
    price,
    LEAD(price) OVER(
        PARTITION BY product_id 
        ORDER BY price_date
    ) AS next_price
FROM daily_prices;

-- Query 8: Price Change Detection
SELECT 
    product_id,
    price_date,
    price,
    LAG(price) OVER(
        PARTITION BY product_id 
        ORDER BY price_date
    ) AS prev_price,
    price - LAG(price) OVER(
        PARTITION BY product_id 
        ORDER BY price_date
    ) AS price_change
FROM daily_prices;
