USE employees;

# 1. Відобразити інформацію з таблиці співробітників та через підзапит додати його поточну посаду
SELECT ee.*, et.title
FROM employees AS ee
LEFT JOIN (SELECT emp_no, title FROM titles  # якщо вказати INNER JOIN видасть в таблиці тільки працівників, які зараз працюють
			WHERE CURDATE() BETWEEN from_date AND to_date) AS et USING (emp_no);


# 2. Відобразити інформацію з таблиці співробітників, які (exists) у минулому були з посадою 'Engineer'
SELECT ee.*
FROM  employees AS ee
INNER JOIN titles AS et USING (emp_no)
WHERE et.to_date != '9999-01-01' AND  et.title = 'Engineer';   

# 2. з урахування підзапитів
SELECT ee.*
FROM  employees AS ee
INNER JOIN (SELECT emp_no, title FROM titles 
            WHERE to_date != '9999-01-01' AND title = 'Engineer') AS et  USING (emp_no);      


# 3. Відобразити інформацію з таблиці працівників, у яких (in) актуальна зарплата від 50 тисяч до 75 тисяч
SELECT ee.*
FROM  employees AS ee
INNER JOIN salaries AS es ON (ee.emp_no = es.emp_no AND CURDATE() BETWEEN from_date AND to_date)
WHERE salary BETWEEN 50000 AND 75000; 

# 3. з урахування підзапитів
SELECT ee.*
FROM  employees AS ee
INNER JOIN (SELECT emp_no FROM salaries 
            WHERE salary BETWEEN 50000 AND 75000 AND CURDATE() BETWEEN from_date AND to_date) AS es 
            ON (ee.emp_no = es.emp_no); 


# 4. Створити копію таблиці працівників
CREATE TABLE employees_dub AS SELECT * FROM employees;


# 5. З таблиці employees_dub видалити співробітників, які були найняті в 1985 року.
DELETE 
FROM employees_dub
WHERE YEAR(hire_date) = '1985';

# 6. У таблиці employees_dub співробітнику за номером 10008 змінити дату прийому на роботу на '1994-09-01'
UPDATE employees_dub
SET hire_date = '1994-09-01'
WHERE emp_no = 10008;

# 7. До таблиці employees_dub додати двох довільних співробітників
INSERT INTO  employees_dub
SELECT * FROM employees.employees 
WHERE emp_no IN (10029, 10048);

# 7. До таблиці employees_dub додати двох довільних (придуманих) співробітників
INSERT INTO  employees_dub (emp_no, birth_date, first_name, last_name, gender, hire_date) 
VALUES
	   (500000, '1996-07-13', 'Vasyl', 'Maksymiv', 'M', CURRENT_DATE()),
       (500001, '1996-04-06', 'Lesia', 'Kosach', 'F', CURRENT_DATE());


 
