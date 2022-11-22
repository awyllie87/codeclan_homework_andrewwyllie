/*1 MVP
Question 1.
(a). Find the first name, last name and team name of employees who are members of teams.*/

SELECT  first_name, 
        last_name, 
        t."name" 
FROM employees AS e 
    INNER JOIN teams AS t 
        ON e.team_id = t.id; 

/*(b). Find the first name, last name and team name of employees who are members of teams and are enrolled in the pension scheme.*/

SELECT  first_name,
        last_name,
        t."name" 
FROM    employees AS e
    INNER JOIN teams AS t
        ON e.team_id = t.id 
WHERE   pension_enrol = TRUE; 

/*(c). Find the first name, last name and team name of employees who are members of teams, where their team has a charge cost greater than 80.*/

SELECT  first_name,
        last_name,
        t."name"
FROM    employees AS e
    INNER JOIN teams AS t
        ON e.team_id = t.id 
WHERE   CAST(t.charge_cost AS int) > 80;

/*Question 2.*/
/*(a). Get a table of all employees details, together with their local_account_no and local_sort_code, if they have them.*/

SELECT e.*, pd.local_account_no, pd.local_sort_code 
FROM    employees AS e 
    INNER JOIN pay_details AS pd 
        ON e.pay_detail_id = pd.id; 

/*(b). Amend your query above to also return the name of the team that each employee belongs to.*/

SELECT  e.*, 
        t."name" AS team_name, 
        pd.local_account_no,
        pd.local_sort_code 
FROM    employees AS e 
    INNER JOIN pay_details AS pd 
        ON e.pay_detail_id = pd.id
    LEFT JOIN teams AS t 
        ON e.team_id = t.id; 
    
/*Question 3.*/
/*(a). Make a table, which has each employee id along with the team that employee belongs to.*/
    
SELECT  e.id,
        t."name"
FROM    employees AS e
    LEFT JOIN teams AS t 
        ON e.team_id = t.id;

/*(b). Breakdown the number of employees in each of the teams.*/

SELECT  t.name,
        count(*) AS no_employees
FROM    employees AS e
    LEFT JOIN teams AS t 
        ON e.team_id = t.id
GROUP BY t.name;
    
/*(c). Order the table above by so that the teams with the least employees come first.*/

SELECT  t.name,
        count(*) AS no_employees
FROM    employees AS e
    LEFT JOIN teams AS t 
        ON e.team_id = t.id
GROUP BY t.name
ORDER BY no_employees ASC;

/*Question 4.*/
/*(a). Create a table with the team id, team name and the count of the number of employees in each team.*/

SELECT  t.id,
        t.name,
        count(t.id) AS no_employees
FROM    employees AS e
    LEFT JOIN teams AS t 
        ON e.team_id = t.id
GROUP BY t.id, t."name"
ORDER BY t.id;


/*(b). The total_day_charge of a team is defined as the charge_cost of the team multiplied by the number of employees in the team. Calculate the total_day_charge for each team.*/

SELECT  t.id,
        t.name,
        count(t.id) AS no_employees,
        count(t.id) * CAST(t.charge_cost AS int) AS total_day_charge
FROM    employees AS e
    LEFT JOIN teams AS t 
        ON e.team_id = t.id
GROUP BY t.id, t."name"
ORDER BY t.id;

/*(c). How would you amend your query from above to show only those teams with a total_day_charge greater than 5000?*/

SELECT  t.id,
        t.name,
        count(t.id) AS no_employees,
        count(t.id) * CAST(t.charge_cost AS int) AS total_day_charge
FROM    employees AS e
    LEFT JOIN teams AS t 
        ON e.team_id = t.id
GROUP BY t.id, t."name"
HAVING count(t.id) * CAST(t.charge_cost AS int) > 5000
ORDER BY t.id;

/*2 Extension*/

/*Question 5.
How many of the employees serve on one or more committees?*/

SELECT count(DISTINCT(employee_id)) AS has_committee
FROM employees_committees AS ec;

/*Question 6.
How many of the employees do not serve on a committee?*/
        
SELECT count(DISTINCT(e.id)) AS has_no_committee
FROM employees AS e 
    LEFT JOIN employees_committees AS ec
        ON e.id = ec.employee_id
WHERE committee_id IS NULL;