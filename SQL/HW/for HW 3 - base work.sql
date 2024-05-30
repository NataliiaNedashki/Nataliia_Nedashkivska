 USE world;
 
 SELECT * 
 FROM city
 Where id = 3426;
 # 3426
 SELECT *
 FROM country
 WHERE Name = 'Ukraine';
 
 SELECT *
 FROM country
 WHERE Continent Like 'A%';
 
 SELECT *
 FROM countrylanguage;
 
 SELECT wcntr.Code, wcntr.Name, wcntr.Population, wct.Name, wct.Population, wct.Population / wcntr.Population AS P
 FROM country AS wcntr
 INNER JOIN city AS wct ON (wcntr.Code = wct.CountryCode)
 WHERE wcntr.Name = 'Ukraine';
 
 SELECT wct.Name, wcntr.Name, wct.Population, wcntr.Population, wct.Population / wcntr.Population AS P
 FROM country AS wcntr
 INNER JOIN city AS wct ON (wcntr.Code = wct.CountryCode)
 ORDER BY P DESC
 LIMIT 3;
 
 
  SELECT wct.Name AS city_name, wcntr.Name AS country_name, wct.Population AS city_population, wcntr.Population AS country_population,
  wct.Population / wcntr.Population AS population_share,
  RANK() OVER (PARTITION BY wcntr.Continent ORDER BY (wct.Population / wcntr.Population) DESC) AS rnk_PS
  FROM country AS wcntr
  INNER JOIN city AS wct ON (wcntr.Code = wct.CountryCode)
  ORDER BY city_population DESC
  LIMIT 3;
  
  

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


 WITH PopulationContinentCTE (country_name, country_population, continent, population_continent, rnk_PS) AS (
      SELECT Name, Population, Continent, 
      SUM(Population) OVER (PARTITION BY Continent) AS population_continent,
      RANK() OVER (PARTITION BY continent ORDER BY (SUM(Population) OVER (PARTITION BY Continent)) DESC) AS rnk_PS
      FROM country)
 SELECT country_name, country_population, continent, population_continent, 
 country_population / population_continent AS population_share
 FROM PopulationContinentCTE
 WHERE rnk_PS <= 2;

 
 WITH PopulationContinentCTE (country_name, country_population, continent, population_continent, rnk_PS) AS (
      SELECT Name, Population, Continent, 
      SUM(Population) OVER (PARTITION BY Continent) AS population_continent,
      RANK() OVER (PARTITION BY continent ORDER BY ( country_population / population_continent) DESC) AS rnk_PS
      FROM country)
 SELECT country_name, country_population, continent, population_continent, 
 country_population / population_continent AS population_share
 FROM PopulationContinentCTE
 WHERE rnk_PS <= 2;
 
 
WITH PopulationContinentCTE (country_name, country_population, continent, population_continent) AS (
      SELECT Name, Population, Continent, 
      SUM(Population) OVER (PARTITION BY Continent) AS population_continent
      FROM country)
 SELECT country_name, country_population, continent, population_continent, 
 country_population / population_continent AS population_share,
 RANK() OVER (PARTITION BY continent ORDER BY ( country_population / population_continent) DESC) AS rnk_PS
 FROM PopulationContinentCTE; 
 
 
 
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



