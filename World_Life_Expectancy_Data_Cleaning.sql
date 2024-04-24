# World Life Expectancy Project (Data Cleaning)

SELECT * 
FROM world_life_expectancy
;

-- 1. Check to see if we have duplicates using country and year as a unique identifier by combining country and year with CONCAT.

SELECT Country, Year, CONCAT(Country,Year),COUNT(CONCAT(Country,Year))
FROM world_life_expectancy        
GROUP BY Country, Year, CONCAT(Country,Year) 
HAVING COUNT(CONCAT(Country,Year)) >1;

-- 2. After identifying duplicates, we need to find the best way to delete them, which would be first to identify the row IDs.

WITH CTE AS (
    SELECT Row_ID, 
           CONCAT(Country, Year) AS CountryYear,
           ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY Row_ID) AS Row_Num
    FROM world_life_expectancy
)
SELECT *
FROM CTE 
WHERE Row_Num >1;

-- 3. Can now finally put this together with a DELETE statement to delete the correct rows.

WITH CTE AS (
    SELECT Row_ID, 
           CONCAT(Country, Year) AS CountryYear,
           ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY Row_ID) AS Row_Num -- this counts the number of rows and is essential for the filtering.
    FROM world_life_expectancy
)
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
		SELECT Row_ID
		FROM CTE
		WHERE Row_Num > 1
);

-- 4. Looking to see how many blank rows there are in the status column. We know that there are only two statuses: 'Developed' and 'Developing'.

SELECT * 
FROM world_life_expectancy
WHERE Status = '';

-- 5. The status of the selected countries should be the same as others, as it is just an issue of the relative years that were not included, which will be an easy fix.

SELECT DISTINCT Country
FROM world_life_expectancy        
WHERE Status = 'Developing';

-- added into our update statement

/*
Here we are going to perform a self-join on the table to itself. Since we know that all countries, regardless of the year, have a status, 
we just need to update the status of countries where the year has a blank status. T1 will act as the table which we want to populate blank 
statuses for the specific year, whereas T2 we will be using it to gather the correct statuses needed.
*/

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
     ON t1.Country = t2.Country 
SET t1.Status = 'Developing'
WHERE t1.status = ''
AND t2.Status <> '' -- this is to make sure we are looking at countries that are not blank
AND t2.Status = 'Developing';   -- finds all countries that are developing in the table which had other years that were blank                           

-- Same with Developed

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
     ON t1.Country = t2.Country 
SET t1.Status = 'Developed'
WHERE t1.status = ''
AND t2.Status <> '' -- this is to make sure we are looking at countries that are not blank, where we will be 
AND t2.Status = 'Developed';   -- finds all countries that are developed in the table which had other years that were blank 

-- 6. Noticed Blanks in Life expectancy, decided to get the next year and previous year and take as average as you can see overall growing at steady rate

SELECT * 
FROM world_life_expectancy
WHERE Lifeexpectancy = '';

SELECT t1.Country, t1.Year, t1.lifeexpectancy, -- the main table
t2.Country, t2.Year, t2.lifeexpectancy, -- represents previous years data
t3.Country, t3.Year, t3.lifeexpectancy, -- represents following years data
ROUND((t2.lifeexpectancy + t3.lifeexpectancy)/2,1) -- this here is the average of the previous and following year that we will use to populate the blank year
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1 
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.lifeexpectancy = '';

-- Used the join in an update statement

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1 
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.lifeexpectancy = ROUND((t2.lifeexpectancy + t3.lifeexpectancy)/2,1)
WHERE t1.lifeexpectancy = '';