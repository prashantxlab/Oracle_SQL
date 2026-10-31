select * from users;
select name, email from users;
select * from users where gender='Female';
select * from users where gender!='Male';
select * from users where salary > '70000';
select * from users where date_of_birth < '1995-01-01';
select * from users where gender='Female' and salary>'70000';
select * from users where gender='Male' or salary>'70000';
select * from users where salary between '50000' and '80000';

select * from users where gender in ('Male','Female');
select * from users where name like 'A%';
select * from users where name like '%a';
select * from users where name like '%ti%';
select * from users where date_of_birth is null;
select * from users where date_of_birth is not null;
select * from users order by salary desc;

select * from users order by salary desc limit 5;
select * from users where gender='Male' order by date_of_birth asc limit 5;

update users set salary=salary+10000 where id='10';
select * from users where id='10';

update users set salary=salary-10000 where id='10';
select * from users where id='10';

update users set name='Robert', email='robert@example.com' where id='5';
select * from users where id='5';

Select * from users where gender='Female' 
and salary>'60000' 
and date_of_birth > '1990-01-01';  

Select * from users where gender='Male' and salary between '50000' and '90000';

Select * from users where gender in ('Male','Other') order by salary desc;

select * from users where gender='Male' or salary> 70000 
order by date_of_birth desc limit 5;

select * from users where id='27';
insert into users (name, email, gender, date_of_birth, salary) 
values ('joginder','jogi@mail.com', 'Other', '2000-01-01','10000');

update users set id='26' where id='51'; 

delete from users where id='26';
delete from users where gender='Other';
select * from users where salary<40000;
delete from users where salary<'40000';

select name,gender,salary from users where gender='Female' 
and salary>'60000' order by salary desc limit 5;