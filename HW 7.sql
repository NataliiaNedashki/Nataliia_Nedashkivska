USE tempdb;

/* 1. У схемі tempdb створити таблицю dept_emp з розподілом за партиціями поля from_date. Для 
цього:
• З бази даних employees таблиці dept_emp з Info-Table inspector-DDL взяти і скопіювати 
код створення тієї таблиці.
• Прибрати з DDL коду згадку про KEY та CONSTRAINT.
• І додати код для секціонування по полю from_date з 1985 до 2002. Партиції по кожному 
році.
*/
CREATE TABLE IF NOT EXISTS dept_emp (
   emp_no  int NOT NULL,
   dept_no  char(4) NOT NULL,
   from_date date NOT NULL,
   to_date  date NOT NULL
)
PARTITION BY RANGE (YEAR(from_date)) (
PARTITION p0 VALUES LESS THAN (1985),
PARTITION p1 VALUES LESS THAN (1986),
PARTITION p2 VALUES LESS THAN (1987),
PARTITION p3 VALUES LESS THAN (1988),
PARTITION p4 VALUES LESS THAN (1989),
PARTITION p5 VALUES LESS THAN (1990),
PARTITION p6 VALUES LESS THAN (1991),
PARTITION p7 VALUES LESS THAN (1992),
PARTITION p8 VALUES LESS THAN (1993),
PARTITION p9 VALUES LESS THAN (1994),
PARTITION p10 VALUES LESS THAN (1995),
PARTITION p11 VALUES LESS THAN (1996),
PARTITION p12 VALUES LESS THAN (1997),
PARTITION p13 VALUES LESS THAN (1998),
PARTITION p14 VALUES LESS THAN (1999),
PARTITION p15 VALUES LESS THAN (2000),
PARTITION p16 VALUES LESS THAN (2001),
PARTITION p17 VALUES LESS THAN MAXVALUE
 );
 

# 2. Створити індекс таблицю tempdb.dept_emp по полю dept_no.
CREATE INDEX Dept_NO ON dept_emp(dept_no);


# 3. З таблиці tempdb.dept_emp вибрати дані лише за 1990 рік.
SELECT *
FROM dept_emp 
PARTITION (p5);


/* 4. На основі попереднього завдання, через explain переконатися, що сканування даних йде тільки 
по одній секції. зафіксувати як коментаря через /* висновок з explain */
EXPLAIN SELECT *
FROM dept_emp 
WHERE YEAR(from_date) = 1990;
/* з'явилось колонка partitions, в якій вказані патриції, що використовуються в цій таблиці*/


# 5. Завантажити будь-який CSV файл у схему tempdb.
CREATE TABLE IF NOT EXISTS SIM_CARDS (
   SCRD_ID INT,
   ICC  TEXT,
   CHANGE_USER TEXT,
   CHANGE_DATE TEXT,
   PUK1 TEXT,
   PUK2 TEXT
);

LOAD DATA INFILE 'SIM_CARDS.csv'
INTO TABLE SIM_CARDS
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(SCRD_ID, ICC, CHANGE_USER, CHANGE_DATE, PUK1, PUK2);



