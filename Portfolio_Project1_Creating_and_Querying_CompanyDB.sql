--Portfolio Project 1: Creating and Querying Company's DB using SQL
--Description: This SQL Project carried out involves the Creation and manpiulation of a HR Database containing 4 tables,
-- populating the tables, and querying the data in the tables to provide insights for the compay and help them make 
--informed decisions.

-- Creating database

CREATE DATABASE EmployeesDbForHrDept
 GO
 USE EmployeesDbForHrDept

-- Creating and populating table 1: Employees Table
CREATE TABLE Employee(
	EmpID NVARCHAR(50) NOT NULL,
	EmpName NVARCHAR(50) NOT NULL,
	Salary INT NOT NULL,
    DepartmentID NVARCHAR(10) ,
	StateID NVARCHAR(10) 
)
select * from Employee

INSERT INTO Employee(EmpID, EmpName, Salary,DepartmentID,StateID) 
VALUES ('A01', 'Monika singh','10000','1','101'),
	   ('A02', 'Vishal kumar','25000','2','101' ),
	   ('B01', 'sunil Rana','10000','3','102'),
	   ('B02', 'Saurav Rawat','15000','2','103'),
	   ('B03','Vivek Kataria','19000','4','104'),
	   ('C01','Vipul Gupta','45000','2','105'),
	   ('C02','Geetika Basin','33000','3','101'),
	   ('C03','Satish Sharama','45000','1','103'),
	   ('C04','Sagar Kumar','50000','2','102'),
	   ('C05','Amitabh singh','37000','3','108');

select * from Employee

-- Creating and populating table 2: Department table
CREATE TABLE Department (
	DepartmentID INT PRIMARY KEY IDENTITY,
	Departmentname NVARCHAR(50) NOT NULL,
)

SET IDENTITY_INSERT dbo.Department on;
INSERT INTO Department(DepartmentID, Departmentname) 
VALUES ('1', 'IT'),
	   ('2', 'HR' ),
	   ('3', 'Admin'),
	   ('4', 'Account');

SET IDENTITY_INSERT dbo.Department off;

select * from Department

-- Creating and populating table 3: StateMaster table
CREATE TABLE StateMaster (
	StateID INT PRIMARY KEY IDENTITY,
	Statename NVARCHAR(50) NOT NULL,
)
SET IDENTITY_INSERT dbo.StateMaster on;

INSERT INTO StateMaster(StateID,Statename)
VALUES ('101', 'Lagos'),
		('102', 'Abuja'),
		('103', 'Kano'),
		('104','Delta'),
		('105','Ido');

SET IDENTITY_INSERT dbo.StateMaster off;

select * from StateMaster

-- Creating and populating table 4: Projectmanager table
CREATE TABLE Projectmanager (
	ProjectManagerID INT PRIMARY KEY IDENTITY,
	ProjectManagerName NVARCHAR(50) NOT NULL,
	DepartmentID NVARCHAR(10) not null
)
SET IDENTITY_INSERT dbo.Projectmanager on;

INSERT INTO Projectmanager(ProjectManagerID,ProjectManagerName, DepartmentID) 
VALUES ('1', 'Monika','1'),
	   ('2', 'Vivek','1' ),
	   ('3', 'Vipul','2'),
	   ('4', 'Satish','2'),
	   ('5','Amitabh','3');

SET IDENTITY_INSERT dbo.Projectmanager off;

select * from Projectmanager

-- modifying the database name
ALTER DATABASE EmployeesDbForHrDept MODIFY NAME = EmployeeDbForHrDept

--Ist Task completed!
-- to cross check the outputs

select * from Employee
select * from Department
select * from StateMaster
select * from Projectmanager


--Portfolio project 1 ;Part 2: Querying the Database to help the company make informed decisions
--Task: To provide solutions for the following problems as accurately as possible using sql queries.

--Ques.1. Write a SQL query to fetch the list of employees with same salary.
SELECT EmpName, Salary
FROM Employee
WHERE Salary IN (
    SELECT Salary
    FROM Employee
    GROUP BY Salary
	 HAVING COUNT(Salary) > 1

)
ORDER BY Salary;

--Ques.2. Write a SQL query to fetch Find the second highest salary and the department and name of the earner. 
Select top 2 Empname, Departmentname, Salary
from Employee Emp
join Department Dept
on Emp.DepartmentID = Dept.DepartmentID
where Salary < (
select max(Salary)
from Employee
)
Order by Salary desc

--OR
SELECT SALARY, Empname
FROM Employee
ORDER BY Salary DESC
OFFSET 1 ROW
FETCH NEXT 1 ROW ONLY

--Ques.3. Write a query to get the maximum salary from each department, the name of the department and the name of the earner. 

Select D.DepartmentName, E.EmpName, E.Salary MaxSalary
from Employee E
Join Department D on E.DepartmentID = D.DepartmentID
Join ( Select DepartmentID, Max(Salary) as MaxSalary
	from Employee
	group by DepartmentID) M on E.DepartmentID =M.DepartmentID
	and E.Salary = M.MaxSalary

--Ques.4. Write a SQL query to fetch Projectmanger-wise count of employees sorted by projectmanger's count in descending order.
select  P.ProjectManagerName, P.ProjectManagerID, count(distinct E.EmpName) count_of_PMs 
from Employee E 
join Projectmanager P
on E.DepartmentID=P.DepartmentID
group by  P.ProjectManagerName, P.ProjectManagerID
order by count_of_PMs desc

--Ques 5: . Write a query to fetch only the first name from the EmpName column of Employee table and after that add the salary
--for example- empname is “Amit singh”  and salary is 10000 then output should be Amit_10000
select CONCAT(left(EmpName, Charindex(' ',EmpName) -1), '_' , Salary) FirstName_Salary
From Employee

--Ques 6:Write a SQL query to fetch only odd salaries from from the employee table
Select Salary from Employee
where Salary % 2 =1
--Ques 7: . Create a stored procedure  to fetch EmpID,Empname, Departmantname, ProjectMangerName where salary is greater than 30000.

Create procedure SP_GetHighSalaryEmployeess
as
begin
	select
		E.EmpID,
		E.EmpName,
		D.DepartmentName,
		P.ProjectManagerName,
		E.Salary
	from
		Employee E
		join Department D on E.DepartmentID = D.DepartmentID
		join Projectmanager P on D.DepartmentID = P.DepartmentID
	where 
		E.Salary > 30000
end
go
--run sp
exec [dbo].[SP_GetHighSalaryEmployeess]

-- Ques 8: create a scalar function to fetch the empname from the employee who has high salary and working in admin
create function GetHighestPaidAdminEmployee()
returns varchar(50)
as
begin
declare @EmpName Varchar(50)
select top 1 @EmpName = E.EmpName
from employee E
join Department D 
on E.DepartmentID = D.DepartmentID
where D.DepartmentName = 'Admin'
and E.Salary = (Select max(Salary) from Employee where DepartmentID = D.Department)
return @EmpName
end 
go
--test scalar fxn
select GetHighestPaidAdminEmployee = HighestPaidAdminEmployee


--Ques 9:. Create a procedures to update the employee’s salary by 25% where department is ‘IT’ and project manger not ‘Vivek, Satish’
create procedure UpdateITSalary
as
begin 
	Update E
	Set E.Salary = E.Salary * 1.25
	from Employee E
	join Department D on E.DepartmentID=D.DepartmentID
	join Projectmanager P on D.DepartmentID = P.DepartmentID
	where D.Departmentname = 'IT'
	and P.ProjectManagerName not in ('vivek','Satish')
end
go
--run sp
exec [dbo].[UpdateITSalary]
--test if it works as expected

select * from Employee

--Ques 10:. Create a Stored procedures  to fetch All the empname along with Departmentname, projectmanagername, statename and use error handling also.
Create procedure SP_GetAllEmployeesStatesQ
as
begin 
	begin try
	select
		E.EmpName,
		D.DepartmentName,
		P.ProjectManagerName,
		S.Statename
	from
		Employee E
		join Department D on E.DepartmentID = D.DepartmentID
		join Projectmanager P on D.DepartmentID = P.DepartmentID
		join StateMaster S on S.StateID = E.StateID
--I was also asked to use error handling but i dont know how to use it yet
	end try
	begin catch
		Declare @ErrorMessage NVARCHAR(4000);
		Set @ErrorMessage =ERROR_MESSAGE();
		RaisError (@ErrorMessage, 16,1 );
	End catch 
end

go
--run sp
exec [dbo].[SP_GetAllEmployeesStatesQ]

--Ques 11: . Create a view  to fetch EmpID,Empname, Departmantname, ProjectMangerName where salary is greater than 30000
create view vw_getHigherSalaryy as 
select E.EmpID,E.EmpName, dp.Departmentname,pm.ProjectManagerName
from Employee E
Join Department dp on E.DepartmentID= dp.DepartmentID
join Projectmanager pm on dp.DepartmentID=pm.DepartmentID
where
E.Salary > 3000

select * from [dbo].[vw_getHigherSalaryy]
--Ques 12: Create a view  to fetch the top earners from each department, the employee name and the dept they belong to.
Create view vw_Topearner_s_per_Dept as
select E.EmpName, D.DepartmentName, E.Salary Top_earners_Salary
from Employee E
join Department D on E.DepartmentID=D.DepartmentID
join ( select DepartmentID, Max(Salary) as Top_Salary
from Employee
Group by DepartmentID) T on T.DepartmentID =E.DepartmentID
and T.Top_Salary = E.Salary

select * from [dbo].[vw_Topearner_s_per_Dept]


--END OF PROJECT!!! 
--This has been exciting. Follow me to the next!
