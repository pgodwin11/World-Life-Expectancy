# World Life Expectancy Project (Data Exploration)

SELECT *
FROM world_life_expectancy
;

/* 1. Find the minimum and maximum life expectancies for each country as well as the top 3 countries that had the biggest change over time ? 
 Haiti first with 28.7, Zimbabwe with 22.7, and Eritrea with 21.7. */
 
SELECT Country, 
MIN(lifeexpectancy) AS Min_Life_Expectancy,
MAX(lifeexpectancy) AS Max_Life_Expectancy,
ROUND(MAX(lifeexpectancy)-MIN(lifeexpectancy),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(lifeexpectancy)<> 0
AND MAX(lifeexpectancy) <>0
ORDER BY Life_Increase_15_Years DESC
;

SELECT Year, ROUND(AVG(lifeexpectancy),1) AS average_life_expectancy
FROM world_life_expectancy
WHERE lifeexpectancy <> 0
GROUP BY Year
ORDER BY Year
;

/* 2. Calculate the average life expectancy by year and also calculate the growth increase from the previous year. 
Which year experienced the biggest increase and what year experienced the lowest? */ 


WITH AvgLifeExpectancy AS (
    SELECT 
        Year, 
        ROUND(AVG(lifeexpectancy), 1) AS average_life_expectancy
    FROM 
        world_life_expectancy
    WHERE 
        lifeexpectancy <> 0
    GROUP BY 
        Year
    ORDER BY 
        Year
)
SELECT 
    Year, 
    average_life_expectancy,
    ROUND(average_life_expectancy - LAG(average_life_expectancy) OVER (ORDER BY Year),1) AS difference_from_previous_year
FROM 
    AvgLifeExpectancy
    ;
    
-- The year that had the biggest increase was 2017 to 2018 with 0.7 increase whereas the years with the lowest increase were 2016 to 2017 and 2021 to 2022 with 0.1.
    
/*
3. Highlight the correlation between average life expectency of a country by GDP: You can see how that within the top 10 average life expectancies out of the 158 countries Sweden and Japan were No.1 and 2 in average life expectancy
 with GDP ranks of 13 and 17 and average life expectancy of 82.5, aswell ad switzerland which had a GDP rank of 1 and ranked 3rd in average life expectancy at 82.3. You then had Sierra Leone and  Central Africa as rank 156 and 157
 with correlating GDP ranks of 143 and 151, with the average life expectancies at almost half of the no.1 spot at 48.5 at 46.1
*/

WITH lifeexpectancy_GDP AS 
( SELECT 
	Country,
     AVG(lifeexpectancy) AS avg_life_exp,
	 AVG(GDP) AS avg_gdp
FROM  world_life_expectancy
GROUP BY Country
HAVING avg_life_exp > 0
AND avg_gdp > 0
)

SELECT 
Country,
DENSE_RANK() OVER(ORDER BY avg_life_exp DESC) avg_life_exp_rnk, 
ROUND(avg_life_exp,1) AS avg_life_exp,
DENSE_RANK() OVER(ORDER BY avg_gdp DESC) avg_gdp_rnk,
ROUND(avg_gdp,1) avg_gdp
FROM lifeexpectancy_GDP
ORDER BY avg_life_exp_rnk ASC
;

/*4. How much of a difference in average life expectancy is there between developing countries compared to developed countries?
There's a difference of almost 13 years, with an average life expectancy of 66.8 for developing countries and 79.2 for developed countries.
It is important to note that there are only 32 developed countries in comparison to the 161 developing. */

SELECT 
Status, 
COUNT(Distinct Country) No_of_Countries,
ROUND(AVG(lifeexpectancy),1) avg_life_exp
FROM world_life_expectancy
GROUP BY Status
;
	

