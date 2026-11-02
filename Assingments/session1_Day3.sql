-- display all employee records
select * from hr.EMPLOYEES;

-- display employee first names 
select first_name from hr.EMPLOYEES;

-- display first name and last name
SELECT first_name, last_name from hr.employees;

-- display employees from dipartment 50
select * from hr.EMPLOYEES where DEPARTMENT_ID = 50;

-- display employees with job ID SA_REP
SELECT * from hr.EMPLOYEES where JOB_ID = 'SA_REP';

-- display employees whose first name is Steven
select * from hr.employees where FIRST_NAME = 'Steven';

-- Count employees in each department
select DEPARTMENT_ID, count(*) as employee_count from hr.EMPLOYEES group by DEPARTMENT_ID;

-- Find average salary in each department
select DEPARTMENT_ID, avg(salary) as avg_salary from hr.EMPLOYEES group by DEPARTMENT_ID;

-- Find maximum salary in each department
select DEPARTMENT_ID, max(salary) as max_salary from hr.EMPLOYEES group by DEPARTMENT_ID;

-- Find minimum salary in each department
select DEPARTMENT_ID, min(salary) as min_salary from hr.EMPLOYEES group by DEPARTMENT_ID;

-- Find total salary paid by each department
select DEPARTMENT_ID, sum(salary) as total_salary from hr.EMPLOYEES group by DEPARTMENT_ID;

-- Count employees for each job
select JOB_ID, count(*) as employee_count from hr.EMPLOYEES group by JOB_ID;

-- Count employees by department and job
select DEPARTMENT_ID, JOB_ID, COUNT(*) as employee_count from hr.EMPLOYEES group by DEPARTMENT_ID, JOB_ID;

-- Average salary by department and job
select DEPARTMENT_ID, JOB_ID, AVG(salary) as avg_salary from hr.EMPLOYEES group by DEPARTMENT_ID, JOB_ID;

-- Total salary by department and job
select DEPARTMENT_ID, JOB_ID, sum(salary) as total_salary from hr.EMPLOYEES group by DEPARTMENT_ID, JOB_ID;

-- minumum salary having more than 5000 by department id
select DEPARTMENT_ID, min(salary) as min_salary from hr.EMPLOYEES group by DEPARTMENT_ID having min(salary) > 5000;