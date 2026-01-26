---GROUP BY and HAVING Clause: 
--1. List out the department wise maximum salary, minimum salary and 
--average salary of the employees. 

select
d.name,
max(SALARY),
MIN(SALARY),
avg(salary)
from
employee as e
join department as d on e.DEPARTMENT_ID = d.Department_Id
group by d.Name;

--2. List out the job wise maximum salary, minimum salary and average 
--salary of the employees. 
--3. List out the number of employees who joined each month in ascending order. 

select
COUNT(employee_id),
datename(month,hire_date)
from
EMPLOYEE
group by datename(month,hire_date)
order by COUNT(employee_id);


--4. List out the number of employees for each month and year in 
--ascending order based on the year and month. 






--5. List out the Department ID having at least four employees. 
--6. How many employees joined in February month. 
--7. How many employees joined in May or June month. 

     select
	 count(EMPLOYEE_ID)
	 from
	 EMPLOYEE
	 where datepart(MONTH,HIRE_DATE) in (5, 6)
	 

--8. How many employees joined in 1985? 
--9. How many employees joined each month in 1985?

     select
	 MONTH(HIRE_DATE),
	 count(*)
	 from
	 EMPLOYEE
	 where year(HIRE_DATE) = 1985
	 group by month(HIRE_DATE)

--10. How many employees were joined in April 1985? 
--11. Which is the Department ID having greater than or equal to 3 employees 
--joining in April 1985? 

     select
	 DEPARTMENT_ID,
	 count(*)
	 from
	 EMPLOYEE
	 where year(HIRE_DATE) = 1985 and month(HIRE_DATE) = 4
	 group by DEPARTMENT_ID
	 having count(*) >= 3;

--Joins: 
--1. List out employees with their department names. 
--2. Display employees with their designations. 
--3. Display the employees with their department names and city. 
--4. How many employees are working in different departments? Display with 
--department names. 
--5. How many employees are working in the sales department? 
--6. Which is the department having greater than or equal to 3 
--employees and display the department names in 
--ascending order. 
--7. How many employees are working in 'Dallas'? 
--8. Display all employees in sales or operation departments.
 

 ---CONDITIONAL STATEMENT 
--1. Display the employee details with salary grades. Use conditional statement to 
--create a grade column. 

   select
   *,
     case when salary >= 2500 then 'A'
	      when salary >= 2000 then 'B'
		  when salary >= 1500 then 'C'
		  when salary >= 1000 then 'D'
		  else 'E'
		  end grade
   from
   EMPLOYEE;

--2. List out the number of employees grade wise. Use conditional statement to 
--create a grade column. 

         select
     count(*),
     case when salary >= 2500 then 'A'
	      when salary >= 2000 then 'B'
		  when salary >= 1500 then 'C'
		  when salary >= 1000 then 'D'
		  else 'E'
		  end grade
   from
   EMPLOYEE
   group by case when salary >= 2500 then 'A'
	      when salary >= 2000 then 'B'
		  when salary >= 1500 then 'C'
		  when salary >= 1000 then 'D'
		  else 'E'
		  end;

--3. Display the employee salary grades and the number of employees between 
--2000 to 5000 range of salary.

               select
     DEPARTMENT_ID,
     case when salary >= 2500 then 'A'
	      when salary >= 2000 then 'B'
		  when salary >= 1500 then 'C'
		  when salary >= 1000 then 'D'
		  else 'E'
		  end grade
   from
   EMPLOYEE
   where salary between 2000 and 5000;

---Subqueries: 
--1. Display the employees list who got the maximum salary. 

    select
	*
	from
	EMPLOYEE
	where SALARY = (select max(salary) from EMPLOYEE);


---2. Display the employees who are working in the sales department. 

    select
	*
	from
	EMPLOYEE as e
	where DEPARTMENT_ID in (select d.Department_Id from DEPARTMENT as d
	where Name = 'sales')
    
--3. Display the employees who are working as 'Clerk'. 

        select
	*
	from
	EMPLOYEE as e
	where JOB_ID in (select d.Job_ID from JOB as d
	where Designation = 'clerk')



--4. Display the list of employees who are living in 'Boston'. 
--5. Find out the number of employees working in the sales department. 

    select
	count(*)
	from
	EMPLOYEE as e
	where DEPARTMENT_ID in (select d.Department_Id from DEPARTMENT as d
	where Name = 'sales')


--6. Update the salaries of employees who are working as clerks on the basis of 
--10%. 
begin transaction
     update EMPLOYEE
	 set salary = salary * 1.10
	 where JOB_ID in (select d.Job_ID from JOB as d
	where Designation = 'clerk')
rollback transaction
                            select * from EMPLOYEE
--7. Display the second highest salary drawing employee details. 

     	 select
		 *
		 from
		 employee
		 where EMPLOYEE.SALARY =(select max(salary) from
		 EMPLOYEE where salary < (select max(salary) from EMPLOYEE)) 


--8. List out the employees who earn more than every employee in department 30. 

     select
	 *
	 from
	 EMPLOYEE
	 where salary > (select max(salary) from EMPLOYEE where DEPARTMENT_ID = 30)



--9. Find out which department has no employees.
--10. Find out the employees who earn greater than the average salary for 
--their department.


SELECT *
         FROM Employee e
         WHERE e.Salary = (
         SELECT MAX(Salary)
         FROM Employee
         WHERE Salary < (SELECT MAX(Salary) FROM Employee));
