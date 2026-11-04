select * from hr.DEPARTMENTS;

-- print system date based on the server location
select sysdate from dual;

-- print the eployees hiring date and current date
SELECT employee_id, first_name, hire_date, sysdate from hr.employees;

-- print the systemtime
select systimestamp from dual;

-- -------------------

-- add 3 months
select sysdate, add_months(sysdate,3) from dual;

-- add 6 months to hiredate showing probation end date
select first_name, hire_date, 
add_months(hire_date, 6) as probation_period
from hr.EMPLOYEES;

-- find months between two dates
SELECT months_between(DATE '2026-11-05', DATE '2026-6-05') from dual;

-- find number of months employee has worked
select first_name, hire_date, 
ceil(months_between(sysdate, hire_date)) as months_worked from hr.EMPLOYEES;

-- last day of current month
SELECT sysdate, last_day(sysdate) from dual;

-- last day of individual hire_date month
select first_name, hire_date, last_day(hire_date) from hr.EMPLOYEES;

-- find next monday from today
select sysdate, next_day(sysdate, 'Monday') from dual;

-- find next friday from today
select sysdate, next_day(sysdate, 'Friday') from dual;

-- find next monday from the hire_date
select first_name, hire_date, next_day(hire_date, 'Monday') as Next_Monday from hr.employees;

-- 
select first_name, hire_date, extract(day from hire_date) as current_year from hr.employees;

-- separate current year months and date from today
select extract(year from sysdate) as current_year,
extract(MONTH from sysdate) as current_month,
extract(DAY from sysdate) as current_day from dual;

