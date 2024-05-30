USE test_create_db;

/* 1. Створити таблицю client з полями:
• clnt_no (AUTO_INCREMENT первинний ключ)
• cnlt_name (не можна null значення)
• clnt_tel (не можна null значення)
• clnt_region_no   */
CREATE TABLE IF NOT EXISTS client (
	clnt_no INT AUTO_INCREMENT PRIMARY KEY,
	cnlt_name VARCHAR(255) NOT NULL,
	clnt_tel VARCHAR(255) NOT NULL,
	clnt_region_no TINYINT
) ENGINE = INNODB;


/*2. Створити таблицю sales з полями:
• clnt_no (зовнішній ключ на таблицю client поле clnt_no; режим RESTRICT для
update та delete)
• product_no (не можна null значення)
• date_act (за промовчанням поточна дата)  */
CREATE TABLE IF NOT EXISTS sales (
	clnt_no INT,
    product_no INT NOT NULL,
	date_act TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (clnt_no) REFERENCES client (clnt_no) ON UPDATE RESTRICT ON DELETE RESTRICT 
	);
    
 
# 3. Додати 5 клієнтів (тестові дані на власний розсуд) до таблиці client.
INSERT INTO client (clnt_no, cnlt_name, clnt_tel, clnt_region_no)
VALUES 
      (1, 'Luke', '0237271169', 3),
      (2, 'Leia', '0338421797', 1),
      (3, 'Khan', '0412578311', 4),
      (4, 'Obi Wan', '0571176935', 7),
      (5, 'Veider', '0666666666', 6);


# 4. Додати по 2 продажі для кожного співробітника (тестові дані на своє розсуд ) у таблицю sales
INSERT INTO sales (clnt_no, product_no, date_act)
VALUES 
       (1, 101, '1997-03-23'), (1, 121, DEFAULT),
	   (2, 323, '1998-04-26'), (2, 347, '2012-12-31'),
      (3, 777, '2013-07-14'), (3, 326, '2014-10-12'),
      (4, 101, '1996-01-07'), (4, 203, '2010-09-01'),
      (5, 666, '1996-01-01'), (5, 666, '2000-01-01');
      

# 5. З таблиці client, спробувати видалити клієнта з clnt_no=1 та побачити очікувану помилку. 
DELETE FROM client
WHERE clnt_no = 1;      
/*	
Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails 
(`test_create_db`.`sales`, CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`clnt_no`) REFERENCES `client` (`clnt_no`) 
ON DELETE RESTRICT ON UPDATE RESTRICT) */


# 6. Видалити з sales клієнта clnt_no=1, після чого повторити видалення з client по clnt_no=1 
DELETE FROM sales
WHERE clnt_no = 1;

DELETE FROM client
WHERE clnt_no = 1;


# 7. З таблиці client видалити стовпець clnt_region_no.
ALTER TABLE client
DROP COLUMN clnt_region_no;


# 8. У таблиці client перейменувати поле clnt_tel на clnt_phone
ALTER TABLE client
CHANGE COLUMN
	clnt_tel
	clnt_phone VARCHAR(255) NOT NULL;
    
# 9. Видалити дані у таблиці departments_dup за допомогою DDL оператора truncate.
CREATE TABLE departments_dup AS SELECT * FROM employees.departments; # спочатку створила таблицю departments_dup

TRUNCATE TABLE departments_dup;
