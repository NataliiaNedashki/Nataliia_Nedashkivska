USE employees;
# завдання 1: список співробітниць, що були найняті 01.01.1990 і 01.01.2000
SELECT *  
FROM employees
WHERE gender = 'F'
AND hire_date = '1990-01-01'
OR hire_date = '2000-01-01';


# завдання 2: співробітники, у яких ім'я та прізвище збігаються
SELECT *
FROM employees
WHERE first_name = last_name;


# завдання 2: співробітники з однаковими іменами і прізвищами
SELECT first_name, last_name, COUNT(emp_no) AS 'count emp_no'
FROM employees
GROUP BY first_name, last_name 
HAVING COUNT(emp_no) > 1;


# завдання 3: ім'я, прізвище, стать, дата прийняття на роботу співробітників з номерами 10001, 10002, 10003 і 10004
SELECT first_name, last_name, gender, hire_date
FROM employees
WHERE emp_no IN (10001, 10002, 10003, 10004);


# завдання 4: назви департаментів, які містять букву "а" або "е" на другуму місці
SELECT *
FROM departments
WHERE dept_name LIKE'%a%'
OR dept_name LIKE '_e%';


# завдання 5: співробітник, якому було 45 років, коли його прийняли на роботу, він народився в жовтні і був прийнятий на роботу в неділю.
SELECT * 
FROM employees
WHERE gender = 'M'
AND TIMESTAMPDIFF(year, birth_date, hire_date) = 45
AND MONTH(birth_date) = 10
AND DAYOFWEEK(hire_date) = 1;


# завдання 6: максимальна зарплата після 01.06.1995 
SELECT MAX(salary)
FROM salaries
WHERE from_date > '1995-06-01';


# завдання 7: кількість співробітників, які ще працюють в департаментах з понад 13000 робітників
SELECT dept_no, COUNT(dept_no) AS 'amunt emp'
FROM dept_emp
WHERE to_date > current_date
GROUP BY dept_no
HAVING COUNT(dept_no) > 13000
ORDER BY COUNT(dept_no) ASC;


# завдання 8: максимальна і мінімальна зарплата
SELECT MAX(salary), MIN(salary)
FROM salaries;
