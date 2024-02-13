# 1. У схемі employees в таблиці employees додати новий стовпець - lang_no (int).
ALTER TABLE employees.employees
ADD COLUMN lang_no INT;


/* 2. Оновити стовпець lang_no значенням "1" для всіх у кого рік приходу на роботу 1985 та 1988.
 Іншим значенням співробітників оновлено значення "2" */
UPDATE employees
SET lang_no = 
  CASE 
  WHEN YEAR(hire_date) = 1985 OR YEAR(hire_date) = 1988 THEN 1
  ELSE 2
  END;
  

# 3. У схемі tempdb створити нову таблицю language з двома полями lang_no (int) і lang_name (varchar(3)).
USE tempdb;

CREATE TABLE IF NOT EXISTS language (
	lang_no INT,
	lang_name VARCHAR(3) 
);


# 4. Додати в таблицю tempdb.language два рядки: 1 – rus, 2 – rus.
INSERT INTO language (lang_no, lang_name)
VALUES 
      (1, 'rus'),
      (2, 'eng'); # не логічно присвоювати однакову мову, то я змінила в 2 рядку rus на eng


/* 5. Зв'язати таблиці зі схеми employees та tempdb щоб показати всю інформацію з таблиці employees
та один стовпець lang_name з таблиці language (стовпці lang_no не відображати). */
SELECT ee.emp_no, ee.birth_date, ee.first_name, ee.last_name, ee.gender, ee.hire_date, tl.lang_name
FROM employees.employees AS ee
INNER JOIN tempdb.language AS tl ON (ee.lang_no = tl.lang_no);


# 6. На основі запиту з 5-го завдання, створити в'ю employees_lang.
CREATE VIEW employees_lang AS
SELECT ee.emp_no, ee.birth_date, ee.first_name, ee.last_name, ee.gender, ee.hire_date, tl.lang_name
FROM employees.employees AS ee
INNER JOIN tempdb.language AS tl ON (ee.lang_no = tl.lang_no);


# 7. Через в'ю employees_lang вивести кількість співробітників у розрізі мови.
SELECT lang_name, COUNT(lang_name) AS ammount_emp
FROM employees_lang
GROUP BY lang_name;

