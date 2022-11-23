/*1 MVP


Question 1.
How many employee records are lacking both a grade and salary?
*/

SELECT  count(*)
FROM    employees 
WHERE   grade IS NULL
    AND salary IS NULL;
    
/*Question 2.
Produce a table with the two following fields (columns):

the department
the employees full name (first and last name)
Order your resulting table alphabetically by department, and then by last name*/

SELECT  department,
        first_name,
        last_name,
        concat(first_name,' ',last_name) AS full_name 
FROM    employees
ORDER BY    department, last_name;

/*Question 3.
Find the details of the top ten highest paid employees who have a last_name beginning with ‘A’.
*/

SELECT  *
FROM    employees
WHERE   last_name LIKE 'A%'
ORDER BY salary DESC NULLS LAST 
LIMIT 10;

/*Question 4.
Obtain a count by department of the employees who started work with the corporation in 2003.*/

SELECT  department, count(*)
FROM    employees
WHERE   start_date BETWEEN '2003-01-01' AND '2003-12-31'
GROUP BY department;

/*Question 5.
Obtain a table showing department, fte_hours and the number of employees in each department who work each fte_hours pattern.
Order the table alphabetically by department, and then in ascending order of fte_hours.*/

SELECT      department, fte_hours, count(*)
FROM        employees
GROUP BY    department, fte_hours
ORDER BY    department,
            fte_hours ASC;
            
/*Question 6.
Provide a breakdown of the numbers of employees enrolled, not enrolled, and with unknown enrollment status in the corporation pension scheme.*/
        
SELECT  pension_enrol, count(*)
FROM    employees
GROUP BY pension_enrol;

/*Question 7.
Obtain the details for the employee with the highest salary in the ‘Accounting’ department who is not enrolled in the pension scheme?*/

SELECT  *
FROM    employees
WHERE   (department = 'Accounting')
    AND (pension_enrol = FALSE)
ORDER BY salary DESC NULLS LAST
LIMIT 1;

/*Question 8.
Get a table of country, number of employees in that country, 
and the average salary of employees in that country for any countries in which more than 30 employees are based. 
Order the table by average salary descending.*/

SELECT
    country,
    count(*),
    avg(salary) AS avg_salary
FROM employees
GROUP BY country
HAVING count(country) > 30
ORDER BY avg_salary;

/*
Question 9.
11. Return a table containing each employees first_name, last_name, full-time equivalent hours (fte_hours), salary, 
and a new column effective_yearly_salary which should contain fte_hours multiplied by salary. 
Return only rows where effective_yearly_salary is more than 30000.*/

SELECT  first_name,
        last_name,
        fte_hours,
        salary,
        fte_hours * salary AS effective_yearly_salary
FROM    employees
WHERE   (SELECT fte_hours * salary) > 30000

/*Question 10
Find the details of all employees in either Data Team 1 or Data Team 2*/

SELECT  *
FROM    employees AS e
    INNER JOIN teams AS t 
        ON e.team_id = t.id
WHERE   name = 'Data Team 1' OR 
        name = 'Data Team 2'
        
/*
Question 11
Find the first name and last name of all employees who lack a local_tax_code.
*/

SELECT  *
FROM    employees AS e 
    INNER JOIN pay_details AS pd
        ON e.pay_detail_id = pd.id 
WHERE pd.local_tax_code IS NULL

/*Question 12.
The expected_profit of an employee is defined as (48 * 35 * charge_cost - salary) * fte_hours, 
where charge_cost depends upon the team to which the employee belongs. 
Get a table showing expected_profit for each employee.*/

SELECT  e.id, 
        e.first_name, 
        e.start_date,
        e.department, 
        e.salary,
        ((48 * 35 * CAST(t.charge_cost AS int) - salary) * fte_hours) AS expected_profit
FROM    employees AS e
    INNER JOIN teams AS t 
        ON e.team_id = t.id;
    
/*Question 13. [Tough]
Find the first_name, last_name and salary of the lowest paid employee in Japan who works the least common full-time equivalent hours across the corporation.”*/
    
-- Easy way
    
SELECT first_name, last_name, salary
FROM    employees
WHERE   (country = 'Japan') AND
        (fte_hours = (  SELECT fte_hours
                        FROM employees
                        GROUP BY fte_hours
                        ORDER BY count(*) ASC 
                        LIMIT 1))
ORDER BY salary
LIMIT 1;

-- the long way

SELECT first_name, last_name, salary
FROM    employees
WHERE   (country = 'Japan') AND
        (fte_hours = (  SELECT  fte_hours
                        FROM (  SELECT  fte_hours,
                                        count(*)
                                FROM    employees
                                GROUP BY fte_hours
                                ORDER BY count(*) ASC
                                LIMIT 1) AS least_common_fte))
ORDER BY salary
LIMIT 1;

/*Question 14.
Obtain a table showing any departments in which there are two or more employees lacking a stored first name. 
Order the table in descending order of the number of employees lacking a first name, and then in alphabetical order by department.*/

SELECT  department, count(*)
FROM    employees
WHERE   first_name IS NULL
GROUP BY department
HAVING count(*) >= 2

/*Question 15. [Bit tougher]
Return a table of those employee first_names shared by more than one employee, together with a count of the number of times each first_name occurs. 
Omit employees without a stored first_name from the table.
Order the table descending by count, and then alphabetically by first_name*/

SELECT first_name, count(*)
FROM employees
WHERE first_name IS NOT NULL 
GROUP BY first_name
HAVING count(*) > 1
ORDER BY    count(*) DESC,
            first_name
            
/*Find the proportion of employees in each department who are grade 1.*/

WITH dep_total AS (
    SELECT  department, count(*) AS dept_total_employees
    FROM    employees
    GROUP BY department)
SELECT  e.department,
        count(*) AS dept_grade1,
        dg.dept_total_employees,
        (count(*) / CAST(dg.dept_total_employees AS REAL)) AS g1_proportion
FROM employees AS e
    LEFT JOIN dep_total AS dg
        ON e.department = dg.department
WHERE grade = 1
GROUP BY e.department, dg.dept_total_employees

/*2 Extension
 * 
 * Question 1. [Tough]
Get a list of the id, first_name, last_name, department, salary and fte_hours of employees in the largest department. 
Add two extra columns showing the ratio of each employee’s salary to that department’s average salary, 
and each employee’s fte_hours to that department’s average fte_hours.
 */

WITH dep_largest AS (
    SELECT  department
    FROM    employees
    GROUP BY department
    ORDER BY count(*) DESC
    LIMIT 1),
        dep_avg_salary AS (
    SELECT  department, avg(salary)
    FROM    employees
    GROUP BY department),
        dep_avg_fte AS (
    SELECT  department, avg(fte_hours)
    FROM    employees
    GROUP BY department)
SELECT  id,
        first_name,
        last_name,
        e.department,
        salary,
        (round((salary / d_a_s.avg) * 100,2)) AS salary_ratio,
        fte_hours,
        (round((fte_hours / d_a_f.avg) * 100,2)) AS fte_ratio
FROM employees AS e
    INNER JOIN dep_avg_salary AS d_a_s
        ON e.department = d_a_s.department
    INNER JOIN dep_avg_fte AS d_a_f
        ON e.department = d_a_f.department
WHERE e.department = (SELECT department FROM dep_largest)

/*[Extension - really tough! - how could you generalise your query to be able to handle the fact that two or more departments may be tied in their counts of employees. 
 * In that case, we probably don’t want to arbitrarily return details for employees in just one of these departments].*/

WITH dep_largest AS (
    SELECT  department,
            cnt,
            RANK () OVER (ORDER BY cnt DESC) AS rnk
    FROM (
        SELECT  department,
                count(*) AS cnt
        FROM    employees
        GROUP BY department) AS t)
SELECT  id,
        first_name,
        last_name,
        e.department,
        salary,
        (round((salary / 
            (avg(salary) OVER (PARTITION BY e.department))) * 100, 2))
                AS salary_ratio,
        fte_hours,
        (round((fte_hours / 
            (avg(fte_hours) OVER (PARTITION BY e.department))) * 100, 2))
                AS fte_ratio
FROM employees AS e
    INNER JOIN dep_largest AS d_l
        ON e.department = d_l.department
WHERE d_l.rnk = 1;

/*Question 2.
Have a look again at your table for MVP question 6. 
It will likely contain a blank cell for the row relating to employees with ‘unknown’ pension enrollment status. 
This is ambiguous: it would be better if this cell contained ‘unknown’ or something similar. 
Can you find a way to do this, perhaps using a combination of COALESCE() and CAST(), or a CASE statement?*/

SELECT  (CASE
            WHEN pension_enrol = TRUE 
                THEN 'Yes'
            WHEN pension_enrol = FALSE
                THEN 'No'
            WHEN pension_enrol IS NULL
                THEN 'Unknown'           
            END) AS pension_enrol,
        count(*)
FROM    employees
GROUP BY pension_enrol;

/*Question 3. Find the first name, last name, email address and start date of all the employees who are members of the ‘Equality and Diversity’ committee. 
 * Order the member employees by their length of service in the company, longest first.*/

SELECT  e.first_name,
        e.last_name,
        e.email,
        e.start_date
FROM employees AS e 
    INNER JOIN employees_committees AS ec
        ON e.id = ec.employee_id
    INNER JOIN committees AS c
        ON c.id = ec.committee_id
WHERE c."name" = 'Equality and Diversity'
ORDER BY start_date NULLS LAST

/*Question 4. [Tough!]
Use a CASE() operator to group employees who are members of committees into salary_class of 'low' (salary < 40000) or 'high' (salary >= 40000).
A NULL salary should lead to 'none' in salary_class. 
Count the number of committee members in each salary_class.*/

SELECT (CASE
            WHEN salary < 40000
                THEN 'low'
            WHEN salary >= 40000
                THEN 'high'
            WHEN salary IS NULL
                THEN 'none'
        END) AS salary_class,
        count(DISTINCT(e.id))
FROM employees AS e
    INNER JOIN employees_committees AS ec 
        ON e.id = ec.employee_id
GROUP BY salary_class

SELECT *
FROM employees_committees AS ec 