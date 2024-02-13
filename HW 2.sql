USE employees;

# завдання 1: ПІБ працівника, департамент, поточна посада, стаж на поточній посаді та загальний стаж роботи для максимальної зп
SELECT ee.first_name, ee.last_name, et.title, ed.dept_name, MAX(salary), TIMESTAMPDIFF(year, ee.hire_date, curdate()) AS tenure,
TIMESTAMPDIFF(year, ede.from_date, curdate()) AS tenure_in_curtitle
FROM employees AS ee
INNER JOIN salaries AS es ON(ee.emp_no = es.emp_no) AND curdate() BETWEEN es.from_date AND es.to_date
INNER JOIN titles AS et ON(es.emp_no = et.emp_no) AND curdate() BETWEEN et.from_date AND et.to_date
INNER JOIN dept_emp AS ede ON(et.emp_no = ede.emp_no)
INNER JOIN departments AS ed ON (ed.dept_no = ede.dept_no)
GROUP BY ee.first_name, ee.last_name, ed.dept_name, et.title, tenure, tenure_in_curtitle
ORDER BY MAX(salary) DESC
LIMIT 1;


# завдання 2: Для кожного департамента - ім’я та прізвище поточного керівника та його поточна зарплата
SELECT ed.dept_name, ee.first_name, ee.last_name, es.salary
FROM employees AS ee
INNER JOIN salaries AS es ON(ee.emp_no = es.emp_no) AND curdate() BETWEEN es.from_date AND es.to_date 
INNER JOIN dept_manager AS edm ON(es.emp_no = edm.emp_no) AND curdate() BETWEEN edm.from_date AND edm.to_date
INNER JOIN departments AS ed ON (edm.dept_no = ed.dept_no)
WHERE ee.emp_no = edm.emp_no;


# завдання 3: поточна зп кожного працівника і поточна зп поточного керівника
SELECT emp_no, salary, 'salary emp' AS 'flag'
FROM salaries
WHERE to_date = '9999-01-01'
UNION ALL
SELECT edm.emp_no, salary, 'salary manager'
FROM salaries AS es
INNER JOIN dept_manager AS edm USING(emp_no)
WHERE es.to_date = '9999-01-01'
AND edm.to_date = '9999-01-01';


# завдання 4:  співробітники, які зараз заробляють більше, ніж їхні керівники
SELECT es.emp_no
FROM salaries AS es
# Перевіряємо, чи номер співробітника (emp_no) знаходиться серед тих, хто є частиною деякого відділу
WHERE es.emp_no IN (
    SELECT ede.emp_no
    FROM dept_emp AS ede
# Вибираємо тільки унікальні номери відділів (dept_no), до яких належать співробітники
    WHERE ede.dept_no IN ( SELECT dept_no FROM dept_emp )
)
# Порівнюємо зарплату співробітника з зарплатою серед всіх керівників відповідних відділів
AND es.salary > ALL (
    SELECT esm.salary
    FROM salaries AS esm
# Приєднуємо керівників (emp_no) з таблиці dept_manager та їхні зарплати (salary)
    INNER JOIN dept_manager AS edm ON esm.emp_no = edm.emp_no AND edm.to_date = '9999-01-01'
# Обираємо тільки номери відділів (dept_no), до яких належать ці керівники
    WHERE edm.dept_no IN  ( SELECT dept_no FROM dept_manager WHERE to_date = '9999-01-01')
)
AND es.to_date = '9999-01-01';


# завдання 5: кількість співробітників на кожній посаді
SELECT et.title, COUNT(ee.emp_no) AS count_emp
FROM titles AS et
INNER JOIN employees AS ee USING (emp_no)
WHERE et.to_date = '9999-01-01'
GROUP BY et.title
ORDER BY count_emp DESC;


# завдання 5 - варіант 2
SELECT et.title, COUNT(et.emp_no) AS count_emp
FROM titles AS et
WHERE et.to_date = '9999-01-01'
GROUP BY et.title
ORDER BY count_emp DESC;


# завдання 6: повні імена співробітників, які працювали більш ніж в одному відділі
SELECT first_name, last_name
FROM employees AS ee
INNER JOIN dept_emp AS edm USING(emp_no)
GROUP BY first_name, last_name
HAVING COUNT(edm.dept_no) > 1;


# завдання 7: середня та максимальна зарплати в тисячах доларів за кожен рік
SELECT YEAR(from_date) AS year, ROUND(AVG(salary) / 1000, 1) AS avg_salary, ROUND(MAX(salary) / 1000, 1) AS max_salary
FROM salaries
GROUP BY YEAR(from_date);


# завдання 8: кількість жінок і чоловіків, що були найняті в вихідні дні
SELECT gender, COUNT(emp_no) AS count_emp
FROM employees
WHERE DAYOFWEEK(hire_date) IN (1, 6)
GROUP BY gender;

