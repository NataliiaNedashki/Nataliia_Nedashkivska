USE employees;

# 1. Показати для кожного співробітника його поточну зарплату та поточну зарплату поточного керівника
SELECT emp_no, salary, 'salary emp' AS 'flag'
FROM salaries
WHERE curdate() BETWEEN from_date AND to_date
UNION ALL
SELECT edm.emp_no, salary, 'salary manager'
FROM salaries AS es
INNER JOIN dept_manager AS edm USING(emp_no)
WHERE curdate() BETWEEN es.from_date AND es.to_date
AND curdate() BETWEEN edm.from_date AND edm.to_date;


# 2. Показати всіх співробітників, які зараз заробляють більше, ніж їхні керівники.
SELECT es.emp_no
FROM salaries AS es
WHERE es.emp_no IN (
    SELECT ede.emp_no
    FROM dept_emp AS ede
    WHERE ede.dept_no IN ( SELECT dept_no FROM dept_emp )
)
AND es.salary > ALL (
    SELECT esm.salary
    FROM salaries AS esm
    INNER JOIN dept_manager AS edm ON esm.emp_no = edm.emp_no AND curdate() BETWEEN edm.from_date AND edm.to_date
    WHERE edm.dept_no IN  ( SELECT dept_no FROM dept_manager WHERE curdate() BETWEEN from_date AND to_date)
)
AND curdate() BETWEEN es.from_date AND es.to_date;


/* 3. З таблиці dept_manager першим запитом вибрати дані щодо актуальних менеджерам департаментів та зробити свій стовпець “checks” зі значенням 'actual'. 
Другим запитом з цієї таблиці dept_manager вибрати НЕ актуальних менеджерів департаментів та зробити свій 
стовпець "checks" зі значенням 'old'. Поєднати результат двох запитів через union.
*/
SELECT *, 'actual' AS 'checks'
FROM dept_manager 
WHERE curdate() BETWEEN from_date AND to_date
UNION
SELECT *, 'old'
FROM dept_manager 
WHERE to_date != '9999-01-01';


# 4. До результату всіх рядків таблиці departments, додати ще два рядки з значеннями “d010”, “d011” для dept_no та “Data Base”, “Help Desk” для dept_name.
INSERT INTO departments (dept_no, dept_name)
VALUES ('d010', 'Data Base'), 
	   ('d011', 'Help Desk');


# 5. Знайти emp_no актуального менеджера з департаменту 'd003', далі через підзапит із таблиці співробітників вивести по ньому інформацію
SELECT *
FROM employees
WHERE emp_no IN
          (SELECT emp_no
           FROM dept_manager
		   WHERE dept_no = 'd003' 
		   AND curdate() BETWEEN from_date AND to_date);


# 6. Знайти максимальну дату прийому працювати, далі через подзапрос з таблиці співробітників вивести за цією датою інформацію щодо співробітників
SELECT *
FROM employees
WHERE hire_date IN (
                SELECT MAX(hire_date)
				FROM employees);

