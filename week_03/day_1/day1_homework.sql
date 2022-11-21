/* MVP */

/*Question 1.
Find all the employees who work in the ‘Human Resources’ department.
*/

SELECT  *
FROM    employees
WHERE   department = 'Human Resources';

/*Question 2.
Get the first_name, last_name, and country of the employees who work in the ‘Legal’ department.*/

SELECT  first_name,
        last_name,
        country
FROM    employees
WHERE   department = 'Legal';

/*Question 3.
Count the number of employees based in Portugal.*/

SELECT  COUNT(*)
FROM    employees
WHERE   country = 'Portugal';

/*Question 4.
Count the number of employees based in either Portugal or Spain.*/

SELECT  COUNT(*)
FROM    employees
WHERE   country IN ('Portugal', 'Spain');

/*Question 5.
Count the number of pay_details records lacking a local_account_no.*/

SELECT  COUNT(*)
FROM    pay_details
WHERE   local_account_no IS NULL;

/*Question 6.
Are there any pay_details records lacking both a local_account_no and iban number?*/

SELECT  COUNT(*)
FROM    pay_details
WHERE   (local_account_no IS NULL) AND (iban IS NULL);

/*Question 7.
Get a table with employees first_name and last_name ordered alphabetically by last_name (put any NULLs last).*/

SELECT  first_name,
        last_name 
FROM    employees
ORDER BY last_name ASC NULLS LAST;

/*Question 8.
Get a table of employees first_name, last_name and country, ordered alphabetically first by country and then by last_name (put any NULLs last).*/

SELECT  first_name,
        last_name,
        country 
FROM    employees
ORDER BY    country ASC NULLS LAST,
            last_name ASC NULLS LAST;

/*Question 9.
Find the details of the top ten highest paid employees in the corporation.*/

SELECT  *
FROM    employees
WHERE       salary NOTNULL 
ORDER BY    salary DESC
LIMIT 10;

/*Question 10.
Find the first_name, last_name and salary of the lowest paid employee in Hungary.*/

SELECT  first_name,
        last_name,
        salary
FROM    employees
WHERE   country = 'Hungary'
ORDER BY salary ASC 
LIMIT 1;

/*Question 11.
How many employees have a first_name beginning with ‘F’?*/

SELECT  COUNT(*)
FROM    employees
WHERE   first_name ILIKE 'f%';

/*Question 12.
Find all the details of any employees with a ‘yahoo’ email address?*/

SELECT  *
FROM    employees
WHERE   email ILIKE '%yahoo%';

/*Question 13. Count the number of pension enrolled employees not based in either France or Germany.*/

SELECT  COUNT(*)
FROM    employees
WHERE   (pension_enrol = TRUE) AND (country NOT IN ('France', 'Germany'))

/*Question 14.
What is the maximum salary among those employees in the ‘Engineering’ department who work 1.0 full-time equivalent hours (fte_hours)?*/

SELECT  salary
FROM    employees
WHERE   department = 'Engineering' AND fte_hours = 1.0
ORDER BY    salary DESC
LIMIT 1;

/*Question 15.
Return a table containing each employees first_name, last_name, full-time equivalent hours (fte_hours), salary, and a new column effective_yearly_salary which should contain fte_hours multiplied by salary.*/

SELECT  first_name,
        last_name,
        fte_hours,
        salary,
        salary * fte_hours AS effective_yearly_salary
FROM    employees

/*EXTENSION
*
*Question 16.
The corporation wants to make name badges for a forthcoming conference. 
Return a column badge_label showing employees’ first_name and last_name joined together with their department in the following style: 
'Bob Smith - Legal'. 
Restrict output to only those employees with stored first_name, last_name and department.*/

SELECT  CONCAT(first_name,' ',last_name,' - ',department) AS badge_label 
FROM    employees
WHERE   (first_name NOTNULL) AND
        (last_name NOTNULL) AND
        (department NOTNULL);

/*Question 17.
One of the conference organisers thinks it would be nice to add the year of the employees’ start_date to the badge_label to celebrate long-standing colleagues, in the following style ‘Bob Smith - Legal (joined 1998)’. Further restrict output to only those employees with a stored start_date.

[If you’re really keen - try adding the month as a string: ‘Bob Smith - Legal (joined July 1998)’]*/

SELECT  CONCAT(first_name,' ',last_name,' - ',department,' (joined ', EXTRACT(YEAR FROM start_date),')') AS badge_label 
FROM    employees
WHERE   (first_name NOTNULL) AND
        (last_name NOTNULL) AND
        (department NOTNULL);  
    
-- Extension of extension
    
SELECT  CONCAT(first_name,' ',last_name,' - ',department,' (joined ', TO_CHAR(start_date,'fmMonth'),' ',EXTRACT(YEAR FROM start_date),')') AS badge_label 
FROM    employees
WHERE   (first_name NOTNULL) AND
        (last_name NOTNULL) AND
        (department NOTNULL);
    
/*Question 18.
Return the first_name, last_name and salary of all employees together with a new column called salary_class 
with a value 'low' where salary is less than 40,000 and 
value 'high' where salary is greater than or equal to 40,000.*/
    
SELECT  first_name, 
        last_name,
        salary,
        (CASE 
            WHEN salary < 40000 THEN 'low'
            WHEN salary >= 40000 THEN 'high'
            ELSE NULL
        END) AS salary_class
FROM    employees;