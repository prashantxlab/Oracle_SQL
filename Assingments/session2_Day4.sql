-- employee whose salary is between 5000 and 10000
select * from hr.EMPLOYEES where SALARY between 5000 and 10000;

SELECT employee_id, first_name, last_name, salary from hr.EMPLOYEES where salary between 5000 and 10000;

-- last name containing letter n
select * from hr.EMPLOYEES where LAST_NAME like '%n';

-- first name contains an
select * from hr.employees where first_name like '%an%';

-- first name second charachter is a
select * from hr.EMPLOYEES where first_name like '_a%';

-- first name that do not start with s
select * from hr.EMPLOYEES where FIRST_NAME not like 'S%';

-- people from department_id 50 whose salary is less than 5000

select employee_id, first_name, salary from hr.EMPLOYEES where DEPARTMENT_ID=50
MINUS
select EMPLOYEE_ID, FIRST_NAME, SALARY from hr.EMPLOYEES where salary > 5000;

-- character built-in functions

-- Upper
select first_name, upper(first_name) as upper_name from hr.EMPLOYEES;

--lower
select first_name, lower(first_name) as lower_name from hr.EMPLOYEES;

-- Initcap
select first_name, initcap(first_name) as init_name from hr.EMPLOYEES;

-- Length
SELECT first_name, length(first_name) as name_lenth from hr.EMPLOYEES;

-- Substr
select first_name, substr(first_name,1,3) as first_three_name from hr.EMPLOYEES; 

-- Instr
select first_name, instr(first_name,'a') as position_of_a from hr.EMPLOYEES;

-- Concat
select first_name, last_name, concat(first_name, last_name) as full_name from hr.EMPLOYEES;

-- || concatination operator
select first_name, last_name, first_name || ' ' || last_name as full_name from hr.EMPLOYEES;

-- Trim
select trim('   Oracle SQL  ') as result from DUAL;

-- Ltrim
select ltrim('  Oracle SQL  Test') as result from DUAL;

-- Rtrim
select rtrim('  Oracle SQL  Test') as result from dual;

-- Lpad
select first_name, LPAD(first_name, 15, '*') as padded_name from hr.EMPLOYEES;

-- Rpad
select FIRST_NAME, rpad(first_name, 15, '$') as padded_name from hr.EMPLOYEES;


-- Replace
select first_name, replace(first_name,'a','@') as modified_name from hr.employees;

