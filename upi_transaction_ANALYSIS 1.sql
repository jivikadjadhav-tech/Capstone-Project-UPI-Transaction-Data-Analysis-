CREATE DATABASE UPI_Analysis;
USE UPI_Analysis;

 CREATE TABLE merchant_info (
    merchant_id VARCHAR(20) PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    merchant_type VARCHAR(50),
    region VARCHAR(50),
    onboard_date VARCHAR(10),
    risk_score DECIMAL(5,2) CHECK (risk_score >= 0 AND risk_score <= 1)
);

select onboard_date from merchant_onfo;

ALTER TABLE merchant_info
ADD COLUMN onboard_date_new DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE merchant_info
SET onboard_date_new = STR_TO_DATE(onboard_date,'%d-%m-%Y');

SET SQL_SAFE_UPDATES = 1;

SELECT onboard_date, onboard_date_new
FROM merchant_info
LIMIT 10;

describe merchant_info;

ALTER TABLE merchant_info
DROP COLUMN onboard_date;

ALTER TABLE merchant_info
CHANGE onboard_date_new onboard_date DATE;

select*from merchant_info

drop table customer_master;

CREATE TABLE customer_master (
    customer_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    mobile_number VARCHAR(15) UNIQUE NOT NULL,
    age INT CHECK (age >= 18),
    gender VARCHAR(10),
    region VARCHAR(50),
    date_joined DATE,
    is_business_user BOOLEAN,
    risk_score DECIMAL(5,2) CHECK (risk_score >= 0 AND risk_score <= 1)
);

select*from customer_master;

DROP TABLE DEVICE_INFO;

CREATE TABLE device_info (
    device_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    device_type VARCHAR(50),
    app_version VARCHAR(20),
    is_rooted TINYINT(1),   
    last_active DATE,
    validation_customer_id VARCHAR(20),

    FOREIGN KEY (customer_id)
    REFERENCES customer_master(customer_id)
);

SELECT*FROM device_info;

DROP TABLE upi_account_details;
CREATE TABLE upi_account_details (
    upi_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(20),
    bank_name VARCHAR(50),
    account_type VARCHAR(20),
    date_added DATE,
    status VARCHAR(20),
    validation_customer_id VARCHAR(50)

);
select*from upi_account_details;

CREATE TABLE customer_feedback_surveys (
    feedback_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    date_submitted DATE NOT NULL,
    feedback_text TEXT,
    satisfaction_score INT CHECK (satisfaction_score BETWEEN 1 AND 5),
    issue_type VARCHAR(50),
    resolved TINYINT(1),  
    validation_customer_id VARCHAR(20),

    FOREIGN KEY (customer_id)
    REFERENCES customer_master(customer_id)
);

CREATE TABLE fraud_alert_history (
    alert_id VARCHAR(50) PRIMARY KEY,
    transaction_id VARCHAR(30),
    alert_type VARCHAR(50),
    alert_date DATE,
    resolved TINYINT,
    resolution_date DATE,
    remarks VARCHAR(300)
);

drop table upi_transaction_history;

select *from upi_transaction_history ;

ALTER TABLE upi_transaction_history
MODIFY COLUMN transaction_id VARCHAR(30),
MODIFY COLUMN upi_id VARCHAR(50),
MODIFY COLUMN customer_id VARCHAR(20),
MODIFY COLUMN merchant_id VARCHAR(20),
MODIFY COLUMN device_id VARCHAR(20),
MODIFY COLUMN DAY VARCHAR(20),
modify column transaction_type varchar(20),
modify column counterparty_upi varchar(20),
modify column status varchar(20),
modify column device_type varchar(20),
modify column channel varchar(20),
modify column failure_reason varchar(100)
 ;

ALTER TABLE customer_master
ADD PRIMARY KEY (customer_id);

ALTER TABLE upi_account_details
ADD PRIMARY KEY (upi_id);

ALTER TABLE merchant_info
ADD PRIMARY KEY (merchant_id);

ALTER TABLE device_info
ADD PRIMARY KEY (device_id);

SHOW CREATE TABLE upi_transaction_history;

DESCRIBE upi_transaction_history;

SELECT
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'upi_analysis'
AND TABLE_NAME = 'upi_transaction_history'
AND REFERENCED_TABLE_NAME IS NOT NULL;

ALTER TABLE upi_transaction_history
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customer_master(customer_id);

ALTER TABLE upi_transaction_history
ADD CONSTRAINT fk_upi
FOREIGN KEY (upi_id)
REFERENCES upi_account_details(upi_id);

ALTER TABLE upi_transaction_history
ADD CONSTRAINT fk_device_info
FOREIGN KEY (device_id)
REFERENCES device_info(device_id);

SELECT DISTINCT merchant_id
FROM upi_transaction_history
WHERE merchant_id IS NOT NULL
AND merchant_id NOT IN (
    SELECT merchant_id
    FROM merchant_info
);

UPDATE upi_transaction_history
SET merchant_id = NULL
WHERE merchant_id = 'Not Applicable';

SELECT DISTINCT merchant_id
FROM upi_transaction_history
WHERE merchant_id LIKE '%Applicable%';

select*from upi_transaction_history;

SELECT DISTINCT CONCAT('|', merchant_id, '|')
FROM upi_transaction_history
WHERE merchant_id LIKE '%Applicable%';

UPDATE upi_transaction_history
SET merchant_id = NULL
WHERE TRIM(merchant_id) = 'Not Applicable';

SELECT COUNT(*)
FROM upi_transaction_history
WHERE merchant_id = 'Not Applicable';

SET SQL_SAFE_UPDATES = 0;

SELECT COUNT(DISTINCT merchant_id)
FROM upi_transaction_history;

SELECT COUNT(DISTINCT merchant_id)
FROM merchant_info;

DESCRIBE upi_transaction_history;
DESCRIBE merchant_info;

SELECT DISTINCT merchant_id
FROM upi_transaction_history
WHERE merchant_id IS NOT NULL
AND merchant_id NOT IN (
    SELECT merchant_id
    FROM merchant_info
);

SELECT DISTINCT u.merchant_id
FROM upi_transaction_history u
LEFT JOIN merchant_info m
ON u.merchant_id = m.merchant_id
WHERE u.merchant_id IS NOT NULL
AND m.merchant_id IS NULL;

SELECT COUNT(*)
FROM merchant_info
WHERE merchant_id IS NULL;

SHOW ENGINE INNODB STATUS;

ALTER TABLE upi_transaction_history
ADD CONSTRAINT fk_merchant
FOREIGN KEY (merchant_id)
REFERENCES merchant_info(merchant_id);
SELECT COUNT(*)
FROM upi_transaction_history
WHERE merchant_id = 'Not Applicable';

SHOW CREATE TABLE merchant_info;
SHOW CREATE TABLE upi_transaction_history;

SELECT COUNT(*)
FROM upi_transaction_history
WHERE merchant_id IS NOT NULL
AND merchant_id NOT IN (
    SELECT merchant_id
    FROM merchant_info
);

UPDATE upi_transaction_history
SET merchant_id = NULL
WHERE merchant_id NOT IN (
    SELECT merchant_id
    FROM merchant_info
);

ALTER TABLE upi_transaction_history
ADD CONSTRAINT fk_merchant
FOREIGN KEY (merchant_id)
REFERENCES merchant_info(merchant_id);

ALTER TABLE customer_feedback_surveys
ADD CONSTRAINT fk_feedback_customer
FOREIGN KEY (customer_id)
REFERENCES customer_master(customer_id);

ALTER TABLE fraud_alert_history
ADD CONSTRAINT fk_alert_transaction
FOREIGN KEY (transaction_id)
REFERENCES upi_transaction_history(transaction_id);

ALTER TABLE upi_transaction_history
ADD PRIMARY KEY (transaction_id);

ALTER TABLE upi_transaction_history
ADD UNIQUE (transaction_id);

SELECT transaction_id, COUNT(*)
FROM upi_transaction_history
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- insights
-- 1.total transaction amount
SELECT 
  ROUND(SUM(amount),2) AS total_trasnsaction_amount
FROM upi_transaction_history;

-- 2.total transactions
SELECT 
  ROUND(count(transaction_id),2) AS total_trasnsactions
FROM upi_transaction_history;

-- 3.Average transaction amount
SELECT 
  ROUND(avg(amount),2) AS avg_trasnsaction_amount
FROM upi_transaction_history;

SELECT*FROM upi_transaction_history;

-- 4 Failure rate
SELECT 
  (
	(SUM(CASE WHEN STATUS='FAILED' THEN 1 ELSE 0 END)*100.0)
     /COUNT(*)
	) AS failure_rate
FROM upi_transaction_history;

-- 5.Fraud rate
SELECT 
count(*) AS total_transactions,
sum(fraud_flag) AS fraud_transactions,
ROUND((SUM(fraud_flag) * 100.0) / COUNT(*), 2) AS fraud_rate
FROM upi_transaction_history;

-- 6.Success Rate
SELECT 
  (
	(SUM(CASE WHEN STATUS='success' THEN 1 ELSE 0 END)*100.0)
     /COUNT(*)
	) AS success_rate
FROM upi_transaction_history;

-- 7 Pending Rate
SELECT 
  (
	(SUM(CASE WHEN STATUS='Pending' THEN 1 ELSE 0 END)*100.0)
     /COUNT(*)
	) AS Pending_rate
FROM upi_transaction_history;

-- 8. success transaction
SELECT 
count(status) as successful_transactions
FROM upi_transaction_history
where Status='success';
select count(status) as pending_transactions
from upi_transaction_history
where status ='pending';
select count(status) as failed_transactions
from upi_transaction_history
where status ='failed';

-- avtive users
select count(distinct(customer_id))
from upi_transaction_history;

-- fraud amount
select round(sum(amount),2) as fraud_transaction
from upi_transaction_history
where fraud_flag=1

-- rooted device
SELECT
    SUM(CASE WHEN is_rooted = 1 THEN 1 ELSE 0 END) AS rooted_devices,
    SUM(CASE WHEN is_rooted = 0 THEN 1 ELSE 0 END) AS non_rooted_devices
FROM device_info;

-- 1.total_transaction by year

select 
    date_format( transaction_date_time, '%Y-%m') as month, 
	round(sum(amount),2) as transaction
from upi_transaction_history
group by month
order by month desc;

-- active use by month
SELECT
    DATE_FORMAT(transaction_date_time, '%Y-%m') AS month,
    COUNT(DISTINCT customer_id) AS active_users
FROM upi_transaction_history
GROUP BY DATE_FORMAT(transaction_date_time, '%Y-%m')
ORDER BY month DESC;


-- customer retention rate by month
select
 round(count(distinct case when transaction_count>1 then customer_id end)*100.0
 / count(distinct customer_id),
2
 ) as customer_retention_rate
 from(
 select customer_id,
 count(*) as transaction_count
 from upi_transaction_history
 group by customer_id
 )t;
 
SELECT 
    c.customer_id, c.age, round(SUM(t.amount),2) AS transaction
FROM
    customer_master AS c
        JOIN
    upi_transaction_history AS t ON c.customer_id = t.customer_id
GROUP BY c.customer_id , c.age
ORDER BY c.age DESC;

SELECT 
   CASE
       WHEN c.gender='male' THEN 'M'
	   WHEN c.gender='female' THEN 'F'
       ELSE 'other'
    END AS Gender_group,
  COUNT(DISTINCT c.customer_id)  AS total_customers,
  COUNT(t.transaction_id) AS total_transactions, 
  ROUND(SUM(t.amount),2) AS transaction_amount
FROM
    customer_master AS c
        JOIN
    upi_transaction_history AS t
    ON c.customer_id = t.customer_id
GROUP BY Gender_group
ORDER BY Gender_group DESC;

SELECT
    CASE
        WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN c.age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(t.transaction_id) AS total_transactions,
    ROUND(SUM(t.amount), 2) AS total_transaction_amount
FROM customer_master c
JOIN upi_transaction_history t
    ON c.customer_id = t.customer_id
GROUP BY age_group
ORDER BY age_group;


select d.device_type,t.transaction_type,sum(t.amount) as total_amount
from device_info as d
join
upi_transaction_history as t
on d.device_id =t.device_id
group by total_amount
order by d.device_type desc
limit 5;

SELECT
    d.device_type,
    SUM(t.amount) AS total_amount
FROM device_info d
JOIN upi_transaction_history t
    ON d.device_id = t.device_id
GROUP BY d.device_type
ORDER BY total_amount DESC

-- transaction amount by status
Select status, sum(amount) as total_amount
from upi_transaction_history
group by status
order by total_amount;

-- transaction amount by tyansaction_type
Select transaction_type, sum(amount) as total_amount
from upi_transaction_history
group by transaction_type
order by total_amount;

Select account_type, count(status) as Status
from upi_account_details
group by account_type
order by Status;

SELECT
    account_type,
    COUNT(*) AS total_accounts,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM upi_account_details),
        2
    ) AS percentage
FROM upi_account_details
GROUP BY account_type
ORDER BY percentage DESC;

SELECT
    transaction_type,
    SUM(amount) AS total_amount,
    ROUND(
        SUM(amount) * 100.0 /
        (SELECT SUM(amount) FROM upi_transaction_history),
        2
    ) AS percentage
FROM upi_transaction_history
GROUP BY transaction_type
ORDER BY percentage DESC;

select failure_reason, sum(amount) as total_transaction
from upi_transaction_history
group by failure_reason
order by total_transaction;

-- fraud analysis
select 
    date_format( transaction_date_time, '%Y-%m') as month, 
sum(case when fraud_flag ='1'  then 1 else 0 end) as fraud_transaction
from upi_transaction_history
group by month
order by month desc;

SELECT
    hour(transaction_date_time),
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(
        SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS fraud_rate
FROM upi_transaction_history
GROUP BY hour(transaction_date_time)
ORDER BY hour(transaction_date_time) DESC;

SELECT
    year(transaction_date_time),
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) AS fraud_transactions,
    ROUND(
        SUM(CASE WHEN fraud_flag = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS fraud_rate
FROM upi_transaction_history
GROUP BY year(transaction_date_time)
ORDER BY year(transaction_date_time) DESC;


select
m.merchant_type,
count(*) as total_transaction,
sum(case when fraud_flag ='1' then 1 else 0 end) as fraud_transactions,
round(sum(case when fraud_flag ='1' then 1 else 0 end)*100.0/count(*),2) as fraud_rate
from upi_transaction_history as t
join merchant_info as m
on m.merchant_id=t.merchant_id
group by merchant_type
order by merchant_type;
