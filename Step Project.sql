USE employees;

# 1. Покажіть середню зарплату співробітників за кожен рік, до 2005 року.
WITH RECURSIVE avg_salaries (during_year, avg_salary) AS
(SELECT 1985 , AVG(s.salary)
        FROM salaries AS s
        WHERE 1985 BETWEEN YEAR(s.from_date) AND YEAR(s.to_date)
UNION ALL
SELECT during_year + 1, (SELECT AVG(s.salary)
                         FROM salaries AS s
						 WHERE during_year + 1 BETWEEN YEAR(s.from_date) AND YEAR(s.to_date))
FROM avg_salaries
WHERE during_year < 2005
)
SELECT during_year, avg_salary
FROM avg_salaries;


/* 2. Покажіть середню зарплату співробітників по кожному відділу. Примітка: потрібно 
розрахувати по поточній зарплаті, та поточному відділу співробітників*/
SELECT de.dept_no, AVG(s.salary) AS avg_salary
FROM salaries AS s
INNER JOIN dept_emp AS de ON (s.emp_no = de.emp_no)
WHERE CURDATE() BETWEEN s.from_date AND s.to_date
AND CURDATE() BETWEEN de.from_date AND de.to_date
GROUP BY de.dept_no;


# 3. Покажіть середню зарплату співробітників по кожному відділу за кожний рік
SELECT de.dept_no, YEAR(s.to_date) AS year, AVG(s.salary) AS avg_salary
FROM salaries AS s
INNER JOIN dept_emp AS de ON (s.emp_no = de.emp_no)
GROUP BY de.dept_no, year;


# 4. Покажіть відділи в яких зараз працює більше 15000 співробітників
SELECT dept_no, COUNT(emp_no) AS count_emp
FROM dept_emp
WHERE CURDATE() BETWEEN from_date AND to_date
GROUP BY dept_no
HAVING COUNT(emp_no) > 15000;


# 5. Для менеджера який працює найдовше покажіть його номер, відділ, дату прийому на роботу, прізвище
SELECT e.emp_no, d.dept_name, e.hire_date, e.last_name, TIMESTAMPDIFF(DAY, dm.from_date, dm.to_date) AS ammount_as_manager 
FROM dept_manager AS dm
INNER JOIN employees AS e ON (dm.emp_no = e.emp_no)
INNER JOIN departments AS d ON (d.dept_no = dm.dept_no)
ORDER BY ammount_as_manager DESC
LIMIT 1;


# 6. Покажіть топ-10 діючих співробітників компанії з найбільшою різницею між їх зарплатою і середньою зарплатою в їх відділі.
WITH AvgSalaryDeptCTE (emp_no, salary, dept_no, avg_salary)  AS
(SELECT s.emp_no, s.salary, de.dept_no, 
AVG(s.salary) OVER (PARTITION BY de.dept_no) AS avg_salary
FROM salaries AS s
INNER JOIN dept_emp AS de ON (s.emp_no = de.emp_no)
WHERE CURDATE() BETWEEN s.from_date AND s.to_date
AND CURDATE() BETWEEN de.from_date AND de.to_date
)
SELECT emp_no, salary, avg_salary, ABS(salary - avg_salary) AS diff_salary
FROM AvgSalaryDeptCTE 
ORDER BY diff_salary DESC
LIMIT 10;


/* 7. Для кожного відділу покажіть другого по порядку менеджера. Необхідно вивести відділ, 
прізвище ім’я менеджера, дату прийому на роботу менеджера і дату коли він став 
менеджером відділу */
WITH ManagerCTE (dept_name, last_name, first_name, hire_date, from_date, rnk) AS (
	SELECT ed.dept_name, ee.last_name, ee.first_name, ee.hire_date, edm.from_date,
    RANK() OVER (PARTITION BY edm.dept_no ORDER BY edm.from_date) AS rnk
    FROM dept_manager AS edm
    INNER JOIN employees AS ee ON (edm.emp_no = ee.emp_no)
	INNER JOIN departments AS ed ON (edm.dept_no = ed.dept_no)
) 
SELECT dept_name, last_name, first_name, hire_date, from_date
FROM ManagerCTE
WHERE rnk = 2;


/* 1. Створіть базу даних для управління курсами. База має включати наступні таблиці:
- students: student_no, teacher_no, course_no, student_name, email, birth_date.
- teachers: teacher_no, teacher_name, phone_no
- courses: course_no, course_name, start_date, end_date */
CREATE DATABASE IF NOT EXISTS courses;

CREATE TABLE IF NOT EXISTS teachers (
	teacher_no INT NOT NULL PRIMARY KEY,
	teacher_name VARCHAR(14) NOT NULL,
    phone_no BIGINT NOT NULL
);

CREATE TABLE IF NOT EXISTS courses (
	course_no INT NOT NULL PRIMARY KEY,
	course_name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE
);

CREATE TABLE IF NOT EXISTS students (
	student_no INT NOT NULL,
	teacher_no INT NOT NULL,
	course_no INT NOT NULL,
	student_name VARCHAR(14) NOT NULL,
    email VARCHAR(255),
    birth_date DATE,
    FOREIGN KEY (teacher_no) REFERENCES teachers (teacher_no),
    FOREIGN KEY (course_no) REFERENCES courses (course_no)
);

 
# 2. Додайте будь-які данні (7-10 рядків) в кожну таблицю
INSERT INTO teachers (teacher_no, teacher_name, phone_no)
VALUES 
	  (101, 'Remus', 380651313133),
      (102, 'Pomona', 380653472371),
      (103, 'Minerva', 380657777777),
      (104, 'Severus', 380656666666),
      (105, 'Filius', 380654271313),
      (106, 'Aurora', 380658772717),
      (107, 'Albus', 380659999999);
      
INSERT INTO courses (course_no, course_name, start_date, end_date)
VALUES 
      (1001, 'Defense Egainst The Dark Arts', '1997-09-01', '1998-06-30'),
      (1002, 'Herbology', '2000-09-01', '2001-06-30'),
      (1003, 'Transfiguration', '1997-09-01', '1998-06-30'),
      (1004, 'Potions', '2003-09-01', '2004-06-30'),
      (1005, 'Charms' , '2012-09-01', '2013-06-30'),
      (1006, 'Astrology', '2014-09-01', '2015-06-30'),
      (1007, 'Alshemy', '1927-09-01', '1928-06-30');
      
INSERT INTO students (student_no, teacher_no, course_no, student_name, email, birth_date)
VALUES 
      (1, 101, 1001, 'Harry', 'hp@hogwarts.uk', '1985-07-31'),
      (2, 102, 1002, 'Hermiony', 'hg@hogwarts.uk', '1984-09-19'),
      (3, 103, 1002, 'Ronald', 'rw@hogwarts.uk', '1985-03-01'),
      (4, 104, 1004, 'Draco', 'dm@hogwarts.uk', '1985-06-05'),
      (5, 102, 1002, 'Neville', 'nl@hogwarts.uk', '1985-07-30'),
      (6, 104, 1004, 'Luna', 'll@hogwarts.uk', '1986-02-13'),
      (7, 103, 1003, 'Fred', 'fw@hogwarts.uk', '1984-04-01'),
      (8, 103, 1003, 'George', 'gw@hogwarts.uk', '1984-04-01'),
      (9, 104, 1004, 'Dafna', 'dg@hogwarts.uk', '1985-12-23'),
      (10, 101, 1001, 'Ginny', 'gw@hogwarts.uk', '1986-08-11');
      

# 3. По кожному викладачу покажіть кількість студентів з якими він працював
SELECT t.teacher_name, COUNT(student_no) AS emount_student
FROM students AS s
RIGHT JOIN teachers AS t USING (teacher_no)
GROUP BY  t.teacher_name;


# 4. Спеціально зробіть 3 дубляжі в таблиці students (додайте ще 3 однакові рядки)
INSERT INTO students (student_no, teacher_no, course_no, student_name, email, birth_date)
VALUES 
      (1, 101, 1001, 'Harry', 'hp@hogwarts.uk', '1985-07-31'),
      (1, 101, 1001, 'Harry', 'hp@hogwarts.uk', '1985-07-31'),
      (1, 101, 1001, 'Harry', 'hp@hogwarts.uk', '1985-07-31');
      

# 5. Напишіть запит який виведе дублюючі рядки в таблиці students
SELECT student_no, teacher_no, course_no, student_name, email, birth_date, COUNT(*)
FROM students
GROUP BY student_no, teacher_no, course_no, student_name, email, birth_date
HAVING COUNT(*) > 1;