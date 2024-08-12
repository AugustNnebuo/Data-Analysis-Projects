--SQL PROJECT 1: DATA CLEANING PROJECT WITH SQL
-- SQL FLAVOUR: SQLSERVER
-- DATASET : WORLD_LAYOFF DATASET (https://www.kaggle.com/datasets/swaptr/layoffs-2022)

-- Heyy, soo this is my second attempt at the Data cleaning Project on AlexTheAnalysts's Bootcamp. Hopefully, this one goes really well.

-- First i'd create a stage table to avoid messing up the main dataset. This step is recommended before starting any project.T
--Data Cleaning Steps i'd take:
-- 1. Remove duplicates  2. standardize the data 3. treating null values or blank values 4. remove unnecessary columns and rows

 use World_layoffs

 --creating the stage dataset called layoffs_staging2
 select * 
 into layoffs_staging2
 from layoffs
 where 1=0;

select *
from layoffs_staging2;

insert layoffs_staging2
select * from layoffs


--to change the date and location column name because date and location are builtin function names in sqlserver.
EXEC sp_rename 'dbo.layoffs_staging2.date', 'layoffdate', 'COLUMN'; 
EXEC sp_rename 'dbo.layoffs_staging2.location', 'layofflocation', 'COLUMN'; 


-- now that is done, next is to start cleaning...
-- 1. Removing duplicates

select *, ROW_NUMBER() over( partition  by company, layofflocation, industry, total_laid_off, percentage_laid_off, layoffdate, stage,
country, funds_raised order by (select null)) as rownumber
from layoffs_staging2;

with cte as (
select *, ROW_NUMBER() over( partition  by company, layofflocation, industry, total_laid_off, percentage_laid_off, layoffdate, stage,
country, funds_raised order by (select null)) as rownumber
from layoffs_staging2
)
delete from cte
where rownumber > 1;

--2. Standardizing data: this is basically seeing where your dataset has issues and correcting it
-- first we will trim the columns, then we would unify similar attributes

select * from layoffs_staging2
update layoffs_staging2
set company = trim(company)


select distinct(layofflocation) from layoffs_staging2

-- changing the date column datatype to date, total_laid_off to int , funds_raised to int, percentage_laid_off to int
select * from layoffs_staging2
alter table layoffs_staging2
--alter column total_laid_off int
--alter column funds_raised float
--alter column percentage_laid_off float
--alter column layoffdate date

-- 3. Treating blak or null rows and columns
select * from layoffs_staging2
where total_laid_off = '' and percentage_laid_off = '' ;

--select distinct(total_laid_off) from layoffs_staging2
where company is null

select * from layoffs_staging2
where company	= 'Appsmith'

update layoffs_staging2
set industry = null
where industry = '';

select * from layoffs_staging2
where company is null
or layofflocation is null
or industry is null
or total_laid_off is null
or percentage_laid_off is null
or layoffdate is null
or stage is null 
or country is null
 or funds_raised is null ;

 select * from layoffs_staging2
 where company is null or layofflocation is null or industry is null or stage is null or country is null;

 --4. removing unnecessary rows and columns

 select *
 from layoffs_staging2
 where total_laid_off is null
 and percentage_laid_off is null;


 delete
  from layoffs_staging2
 where total_laid_off is null
 and percentage_laid_off is null;

  delete
  from layoffs_staging2
 where industry is null

-- This brings us to the end of this project. It has been quite interesting. Next I would perform an Exploratory Data Analysis on this data.
-- If that is something that interests you, then go over to my next project. Thank you!