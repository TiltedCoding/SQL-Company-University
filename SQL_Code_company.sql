
SELECT dname, COUNT(ssn)
FROM department
INNER JOIN employee ON department.dnumber=employee.dno
GROUP BY dname
HAVING MAX(salary)>42000
;


SELECT fname
FROM department, employee
WHERE department.dnumber = employee.dno AND dno IN (SELECT distinct dno
													FROM employee
													WHERE salary IN (SELECT MIN (salary)
																	 FROM employee))
;


SELECT distinct fname
FROM employee, department
WHERE salary - 5000  > (SELECT AVG (salary)
						FROM employee, department
						WHERE DNAME = 'Research' AND employee.dno = department.dnumber)
΄

CREATE VIEW dept_managers AS
SELECT fname, dname, salary
FROM employee, department
WHERE department.mgrssn = employee.ssn
;

CREATE VIEW employees_and_projects_per_department AS 
(WITH number_of_employees AS -- reference for 'with' clause https://www.geeksforgeeks.org/sql-with-clause/
(SELECT COUNT(ssn) AS number_of_empl, dno FROM employee GROUP BY dno)
SELECT dname, fname, lname, number_of_empl, COUNT(pname) AS number_of_projects
FROM department INNER JOIN employee ON employee.ssn = mgrssn 
INNER JOIN project ON employee.dno = project.dnum
INNER JOIN number_of_employees ON number_of_employees.dno = employee.dno
GROUP BY dname, fname, lname, number_of_empl)
;

CREATE VIEW project_employees AS
(WITH works_on_temp AS
(SELECT pno, COUNT(pno) AS employees_per_project
FROM works_on
GROUP BY pno),
hours_temp AS
(SELECT pno, SUM(hours) AS hours_per_project
FROM works_on
GROUP BY pno),
males AS
(SELECT pno, COUNT(sex) AS count_males
FROM employee NATURAL JOIN works_on
WHERE ssn = essn AND sex = 'M'
GROUP BY pno),
females AS
(SELECT pno, COUNT(sex) AS count_females
FROM employee FULL OUTER JOIN works_on -- If not full outer, then project Z which has 0 females would not be taken into the table
ON ssn = essn AND sex = 'F'
GROUP BY pno)
SELECT pname, dname, employees_per_project, count_males, count_females, hours_per_project
FROM project
INNER JOIN department ON  dnum=dnumber
INNER JOIN works_on_temp ON works_on_temp.pno=pnumber
INNER JOIN males ON works_on_temp.pno = males.pno
INNER JOIN females ON males.pno = females.pno
INNER JOIN hours_temp ON hours_temp.pno = females.pno
ORDER BY hours_per_project, pname ASC)
;

CREATE VIEW top_hours_per_project AS
(WITH sum_of_hours_temp(essn, sum_of_hours) AS -- reference for 'with' clause https://www.geeksforgeeks.org/sql-with-clause/
(SELECT essn, SUM(hours) AS sum_of_hours  FROM works_on WHERE hours IS NOT null
GROUP BY essn
ORDER BY sum_of_hours DESC
LIMIT 3)
SELECT fname, dname, pname, hours
FROM employee 
NATURAL JOIN sum_of_hours_temp 
NATURAL JOIN department
NATURAL JOIN project 
NATURAL JOIN works_on
WHERE pnumber = pno AND dno = dnumber AND essn = ssn
ORDER BY hours ASC)
;