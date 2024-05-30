USE employees;

# 1. Покажіть середню зарплату за кожен рік.
SELECT YEAR(from_date), AVG(salary)
FROM salaries
GROUP BY YEAR(from_date);


/* 2. Покажіть середню зарплату співробітників по кожному відділу. Примітка: 
візьміть поточні відділи та поточну зарплату*/
SELECT de.dept_no, AVG(s.salary) AS avg_salary
FROM salaries AS s
INNER JOIN dept_emp AS de ON (s.emp_no = de.emp_no)
WHERE CURDATE() BETWEEN s.from_date AND s.to_date
AND CURDATE() BETWEEN de.from_date AND de.to_date
GROUP BY de.dept_no;


/* 3. Покажіть середню зарплату співробітників по кожному відділу за кожний рік. Примітка: 
для середньої зарплати відділу X року Y нам потрібно взяти середнє 
значення всіх зарплат співробітників у році Y, які були у відділі X в році Y.*/
SELECT de.dept_no, YEAR(s.to_date) AS year, AVG(s.salary) AS avg_salary
FROM salaries AS s
INNER JOIN dept_emp AS de ON (s.emp_no = de.emp_no)
GROUP BY de.dept_no, year;


# 4. Покажіть для кожного року найбільший відділ цього року та його середню зарплату.
WITH MaxDeptCTE (year, dept_no, emp_count, rn, avg_salary)  AS (
    SELECT YEAR(ede.from_date) AS year, ede.dept_no, COUNT(ede.emp_no) AS emp_count,
	ROW_NUMBER() OVER (PARTITION BY YEAR(ede.from_date) ORDER BY COUNT(ede.emp_no) DESC) AS rn, AVG(es.salary)
    FROM dept_emp AS ede
    INNER JOIN salaries AS es ON (es.emp_no = ede.emp_no) 
    GROUP BY YEAR(ede.from_date), ede.dept_no
)
SELECT year, dept_no, avg_salary
FROM MaxDeptCTE
WHERE rn = 1;


# 5. Покажіть детальну інформацію про поточного менеджера, який найдовше виконує свої обов'язки.
SELECT ee.*, TIMESTAMPDIFF(DAY, edm.from_date, edm.to_date) AS ammount_as_manager 
FROM dept_manager AS edm
INNER JOIN employees AS ee ON (edm.emp_no = ee.emp_no)
ORDER BY ammount_as_manager DESC
LIMIT 1;
