USE employees;

# 1. Відобразити співробітників та навпроти кожного, показати інформацію про різницю поточної та першої зарплати.
WITH FirstSalaryCTE AS (
	SELECT DISTINCT emp_no,
    FIRST_VALUE(salary) OVER (PARTITION BY emp_no ORDER BY from_date ) AS first_salary
    FROM salaries
    ) 
SELECT  emp_no, abs(salary - first_salary) AS diff_salary
FROM salaries
INNER JOIN FirstSalaryCTE USING(emp_no)
WHERE CURDATE() BETWEEN from_date AND to_date;


# 2. Відобразити департаменти та працівників, які отримують найвищу зарплату у своєму департаменті.
WITH RankSalaryCTE AS (
    SELECT es.emp_no, es.salary, ed.dept_name,
	ROW_NUMBER() OVER (PARTITION BY ed.dept_name ORDER BY es.salary DESC) AS salary_rank
    FROM salaries AS es
    INNER JOIN dept_emp AS edm USING (emp_no)
    INNER JOIN departments AS ed ON (edm.dept_no = ed.dept_no)
    WHERE CURDATE() BETWEEN es.from_date AND es.to_date
)
SELECT emp_no, salary, dept_name
FROM RankSalaryCTE
WHERE salary_rank = 1;


# 3. З таблиці посад, відобразити співробітника з його поточною посадою та попередньою. 
SELECT et.emp_no, et.title, ept.previous_title
FROM titles AS et
LEFT JOIN  (
           SELECT emp_no, LAST_VALUE (title) OVER (PARTITION BY emp_no ORDER BY to_date ROWS 1 PRECEDING) AS previous_title
           FROM titles
		   WHERE to_date <> '9999-01-01') AS ept ON (et.emp_no = ept.emp_no)
WHERE CURDATE() BETWEEN from_date AND to_date;


WITH PreviousTitleCTE (emp_no, previous_title) AS (
           SELECT emp_no, LAST_VALUE (title) OVER (PARTITION BY emp_no ORDER BY to_date ROWS 1 PRECEDING) AS previous_title
           FROM titles
		   WHERE CURDATE() BETWEEN from_date AND to_date
         )
SELECT et.emp_no, et.title, ept.previous_title
FROM titles AS et
LEFT JOIN PreviousTitleCTE AS ept ON (et.emp_no = ept.emp_no)
WHERE CURDATE() BETWEEN from_date AND to_date;


# 4. З таблиці посад, порахувати інтервал у днях - скільки минуло часу від першої посади до поточної.
SELECT dft.emp_no, dft.to_date, dft.date_first_title, TIMESTAMPDIFF(DAY, dft.date_first_title, dft.to_date) AS date_diff
FROM ( SELECT emp_no, from_date, to_date,
	   FIRST_VALUE(to_date) OVER (PARTITION BY emp_no ORDER BY to_date) AS date_first_title
       FROM titles ) AS dft
WHERE CURDATE() BETWEEN dft.from_date AND dft.to_date;


WITH DateFirstTitleCTE (emp_no, from_date, to_date, date_first_title) AS
( SELECT emp_no, from_date, to_date,
	   FIRST_VALUE(to_date) OVER (PARTITION BY emp_no ORDER BY to_date) AS date_first_title
       FROM titles )
SELECT emp_no, to_date, date_first_title, TIMESTAMPDIFF(DAY, date_first_title, to_date) AS date_diff
FROM DateFirstTitleCTE 
WHERE CURDATE() BETWEEN from_date AND to_date;


# 5. Вибрати співробітників та відобразити їх рейтинг за роком прийняття на роботу. Спробуйте різні типи рейтингів.
SELECT emp_no, YEAR(hire_date),
DENSE_RANK() OVER (ORDER BY YEAR(hire_date)) AS d_rnk,
RANK() OVER (ORDER BY YEAR(hire_date)) AS rnk,
ROW_NUMBER() OVER (PARTITION BY YEAR(hire_date) 
				   ORDER BY YEAR(hire_date)) AS 'Row number'
FROM employees;

