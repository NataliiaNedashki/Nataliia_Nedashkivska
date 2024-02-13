USE employees;

/* 1. Для поточної максимальної річної заробітної плати в компанії ПОКАЗАТИ ПІБ 
працівника, відділ, поточну посаду, скільки часу займає поточну посада та
загальний стаж роботи в компанії. */
WITH empCTE(id, max_salary, title, dept_name, tenure_in_curtitle)  
AS 
 ( SELECT es.emp_no, MAX(salary), et.title, ed.dept_name, TIMESTAMPDIFF(year, ede.from_date, curdate())
    FROM salaries AS es
    INNER JOIN titles AS et ON(es.emp_no = et.emp_no) AND curdate() BETWEEN et.from_date AND et.to_date
    INNER JOIN dept_emp AS ede ON (et.emp_no = ede.emp_no)
    INNER JOIN departments AS ed ON (ed.dept_no = ede.dept_no)
    WHERE CURDATE() BETWEEN es.from_date AND es.to_date
    GROUP BY es.emp_no, et.title, ed.dept_name
    ORDER BY MAX(salary) DESC
    LIMIT 1
)
SELECT max_salary, ee.first_name, ee.last_name, title, dept_name, tenure_in_curtitle, TIMESTAMPDIFF(year, ee.hire_date, curdate()) AS tenure 
FROM employees AS ee
INNER JOIN empCTE AS eCte ON (ee.emp_no = eCte.id);


# 2. З документації MySQL перевірте, як працює функція ABS().
SELECT ABS(2), ABS(-128), ABS(-9223372036854776659786636876550976); 
SELECT ABS(-9223372036854775808); 
# ABS - математична функція модуль ("| |"), повертає абсолютне значення. Повертає той тип даних, який в початковому запиті.

 
/*3. Покажіть всю інформацію про працівника, зарплатний рік та різницю між зарплатою
та середньою зарплатою в компанії в цілому. Для працівника, чия заробітна плата
була призначена останньою з окладів, найближчих до загальної середньої
заробітної плати (не має значення, вища чи нижча).*/
SELECT ee.*, YEAR(es.from_date) AS salary_year, ABS(salary - (SELECT AVG(salary) FROM salaries)) AS salary_diff
FROM salaries AS es
INNER JOIN employees AS ee USING (emp_no) 
ORDER BY salary_diff
LIMIT 1;


# 4. Виберіть відомості, посаду та зарплату працівника з найвищою зарплатою, який більше не працює в компанії.
SELECT ee.*, et.title, maxs.salary
FROM employees AS ee
INNER JOIN (SELECT emp_no, MAX(to_date), MAX(salary) AS salary
            FROM salaries 
            GROUP BY emp_no
            HAVING MAX(to_date) != '9999-01-01'
            ORDER BY salary DESC
            LIMIT 1) AS maxs ON (ee.emp_no = maxs.emp_no)
INNER JOIN titles AS et ON (maxs.emp_no = et.emp_no)
LIMIT 1;


/* 5. Покажіть ПІБ, зарплату та рік зарплати для топ 5 працівників, які мають найвище
одноразове підвищення зарплати (в абсолютних числах). Також додайте топ 5
працівників, які мають найвище разове підвищення зарплати (у відсотках).*/
WITH SalaryChangesCTE (first_name, last_name, emp_no, current_salary, salary_year, previous_salary)  AS (
       SELECT e.first_name, e.last_name, s.emp_no, s.salary, YEAR(s.to_date), 
       LAG(s.salary) OVER (PARTITION BY s.emp_no ORDER BY s.to_date)  
       FROM salaries AS s
       INNER JOIN employees AS e ON (s.emp_no = e.emp_no)
)
SELECT first_name, last_name, emp_no, current_salary, salary_year, 'top 5 absolute_increase' AS 'flag', absolute_increase, percent_increase
    FROM ( SELECT *, ABS(current_salary - previous_salary) AS absolute_increase, 
          ((current_salary - previous_salary) / previous_salary) * 100 AS  percent_increase
         FROM  SalaryChangesCTE
         ORDER BY absolute_increase DESC
         LIMIT 5 ) AS Top5_absolute_increase
UNION ALL
SELECT first_name, last_name, emp_no, current_salary, salary_year, 'top 5 percent_increase', absolute_increase, percent_increase 
    FROM ( SELECT *, ABS(current_salary - previous_salary) AS absolute_increase, 
          ((current_salary - previous_salary) / previous_salary) * 100 AS  percent_increase
         FROM  SalaryChangesCTE
         ORDER BY percent_increase DESC
         LIMIT 5 ) AS Top5_percent_increase;
         
         
# 6. Створіть послідовність квадратних чисел до 9
WITH RECURSIVE SQUARE (n, square_n)
AS (
	SELECT 1, 1
	UNION
	SELECT n + 1, (n + 1) * (n + 1)
	FROM SQUARE
	LIMIT 9
)
SELECT *
FROM SQUARE;


USE world;
 
/*7. ПОКАЗАТИ назву міста, країну, населення міста, населення країни та частку для 3 
найбільших міст на континенті, які складають найбільшу частку населення країни.*/
WITH CityInfoCTE (city_name, country_name, city_population, country_population, population_share, rnk_PS)  
 AS (
	SELECT wct.Name, wcntr.Name, wct.Population, wcntr.Population,
    wct.Population / wcntr.Population,
    RANK() OVER (PARTITION BY wcntr.Continent ORDER BY (wct.Population / wcntr.Population) DESC)
    FROM country AS wcntr
    INNER JOIN city AS wct ON (wcntr.Code = wct.CountryCode)
)
SELECT city_name, country_name, city_population, country_population, population_share
FROM CityInfoCTE
WHERE rnk_PS <= 3;


/* 8. ПОКАЖІТЬ унікальний рейтинг (за часткою), назву
країни, континент, населення країни, населення континенту та частку для 2
найбільших країн на континенті, які становлять найвищу частку населення
континенту.*/
WITH PopulationContinentCTE (Id, population_continent) AS (
      SELECT Code, 
      SUM(Population) OVER (PARTITION BY Continent) AS population_continent
      FROM country),
RnPopulationContinentCTE (country_name, country_population, continent, population_continent, rn_PS) AS 
       ( SELECT c.Name, c.Population, c.Continent, pc.population_continent,
        ROW_NUMBER() OVER (PARTITION BY c.Continent ORDER BY ( c.Population / pc.population_continent) DESC) AS rn_PS
        FROM country AS c
        INNER JOIN PopulationContinentCTE AS pc ON (c.Code = pc.Id)
       )
 SELECT country_name, country_population, continent, population_continent, 
 country_population / population_continent AS population_share
 FROM RnPopulationContinentCTE
 WHERE rn_PS <= 2;
 

# 9. Для 3 найбільших континентів 2 найбільші країни і 2 найменші країни (за площею). Покажіть назву країни, область і столицю
 WITH AreaContinentCTE (Id, area_continent) AS (
      SELECT Code, 
      SUM(SurfaceArea) OVER (PARTITION BY Continent) AS area_continent
      FROM country),
TOP3AreaContinentCTE (Id, area_continent, dr_AC)  AS 
        (SELECT c.Code, ac.area_continent,
        DENSE_RANK() OVER (ORDER BY area_continent DESC) AS dr_AC
        FROM country AS c
        INNER JOIN AreaContinentCTE  AS ac ON (c.Code = ac.Id)
        ),
AreaCountryRankCTE (country_name, region, capital, Continent, LargestCountry, SmallestCountry)  AS (
    SELECT c.Name, c.Region, c.Capital, c.Continent,
	ROW_NUMBER() OVER (PARTITION BY c.Continent ORDER BY c.SurfaceArea DESC) AS LargestCountry,
	ROW_NUMBER() OVER (PARTITION BY c.Continent ORDER BY c.SurfaceArea ASC) AS SmallestCountry
	FROM country AS c
	INNER JOIN TOP3AreaContinentCTE AS ac3 ON (c.Code = ac3.Id)
	WHERE dr_AC <= 3
        )
SELECT country_name, region, wc.Name AS capital_name
FROM AreaCountryRankCTE AS acr
LEFT JOIN city AS wc ON (acr.capital = wc.ID)
WHERE SmallestCountry <= 2 OR LargestCountry <=2; 
 
