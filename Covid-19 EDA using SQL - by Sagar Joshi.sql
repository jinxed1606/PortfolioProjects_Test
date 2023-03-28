/*
SQL Project 1 - Covid-19 Data Exploration in SQL

Skills used - CTEs, Temp Tables, Windows functions, Aggregate functions, creating Views, Converting Data Types
*/

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COVID-19 Deaths Data (03/01/2020 - 21/03/2023)
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)']
WHERE continent IS NOT NULL
ORDER BY 3, 4;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COVID-19 Vaccinations Data (03/01/2020 - 21/03/2023)
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM [SQL Portfolio Project - Alex].dbo.['CovidVaccinations - (Sagar)']
WHERE continent IS NOT NULL
ORDER BY 3, 4;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Select the Data from the Dataset.
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT location, date, population, total_cases, total_deaths, new_cases, new_deaths
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)']
WHERE continent IS NOT NULL
ORDER BY 1, 2;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Use Case 1 - Total Cases vs Total Deaths - Depicting the chances of Dying from Covid in India.
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS total_deaths_percentage
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)']
WHERE location = 'India' AND continent IS NOT NULL
ORDER BY 1, 2;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Use Case 2 - Total Cases vs Total Population - Depicting the % of population that got Covid in India.
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT location, date, population, total_cases, (total_cases/population)*100 AS total_cases_by_population
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)']
WHERE location = 'India' AND continent IS NOT NULL
ORDER BY 1, 2;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Use Case 3 - Countries with Highest Infected Rate compared to Population
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)']
--WHERE location = 'India' AND continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Use Case 4 - Countries with Highest Death Count by Population.
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT location, population, MAX(CONVERT(float, total_deaths)) AS HighestDeathCount, MAX((CONVERT(float, total_deaths))/population)*100 AS PercentPopulationDied
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)']
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- BREAKING THINGS DOWN BY CONTINENTS!!

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Use Case 5 - Continents with Highest Death Count by Population.
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT continent, MAX(CONVERT(float, total_deaths)) AS HighestDeathCount, MAX((CONVERT(float, total_deaths))/population)*100 AS PercentPopulationDied
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)']
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Use Case 6 - Global Covid-19 Numbers
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT location,
	SUM(CONVERT(float, new_cases)) AS total_new_cases, 
	SUM(CONVERT(float, new_deaths)) AS total_new_deaths, 
	(SUM(CONVERT(float, new_deaths))/SUM(CONVERT(float, new_cases)))*100 AS total_deaths_by_cases
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)']
WHERE location = 'India' AND continent IS NOT NULL
GROUP BY location
ORDER BY total_new_cases, total_new_deaths;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JOINING THE COVID DEATHS AND VACCINATIONS DATA
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)'] AS C19Deaths
JOIN [SQL Portfolio Project - Alex].dbo.['CovidVaccinations - (Sagar)'] AS C19Vacc
	ON C19Deaths.location = C19Vacc.location
	AND C19Deaths.date = C19Vacc.date

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Use Case 7 - Total Population vs Total Vaccinations (Showing people with atleast one dose of Vaccination)
---------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT C19Deaths.continent, C19Deaths.location, C19Deaths.date, C19Deaths.population, C19Vacc.new_vaccinations,
		SUM(CONVERT(float, C19Vacc.new_vaccinations)) OVER (PARTITION BY C19Deaths.location 
		ORDER BY C19Deaths.location, C19Deaths.date) AS PerDayVaccinations
		--(PerDayVaccinations/population)*100
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)'] AS C19Deaths
JOIN [SQL Portfolio Project - Alex].dbo.['CovidVaccinations - (Sagar)'] AS C19Vacc
	ON C19Deaths.location = C19Vacc.location
	AND C19Deaths.date = C19Vacc.date
WHERE C19Deaths.location = 'INDIA' AND C19Deaths.continent IS NOT NULL
ORDER BY 2, 3;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Using CTE to calculate per day vaccinations
---------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH TotPplVacc (continent, location, date, population, New_Vaccinations, TotalPeopleVaccinated)
 AS (
	SELECT C19Deaths.continent, C19Deaths.location, C19Deaths.date, C19Deaths.population, C19Vacc.new_vaccinations,
			SUM(CONVERT(float, C19Vacc.new_vaccinations)) OVER (PARTITION BY C19Deaths.location 
			ORDER BY C19Deaths.location, C19Deaths.date) AS TotalPeopleVaccinated
	FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)'] AS C19Deaths
	JOIN [SQL Portfolio Project - Alex].dbo.['CovidVaccinations - (Sagar)'] AS C19Vacc
		ON C19Deaths.location = C19Vacc.location
		AND C19Deaths.date = C19Vacc.date
	WHERE C19Deaths.location = 'INDIA' AND C19Deaths.continent IS NOT NULL
)
SELECT *, (TotalPeopleVaccinated/population)*100 AS PercentPopVacc
FROM TotPplVacc;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Using TEMP Tables to calculate % of population vaccinated
---------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS #PercentPopVacc

CREATE TABLE #PercentPopVacc (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric, 
	New_Vaccinations numeric,
	TotalPplVacc numeric
)
INSERT INTO #PercentPopVacc 
	SELECT C19Deaths.continent, C19Deaths.location, C19Deaths.date, C19Deaths.population, C19Vacc.new_vaccinations,
			SUM(CONVERT(float, C19Vacc.new_vaccinations)) OVER (PARTITION BY C19Deaths.location 
			ORDER BY C19Deaths.location, C19Deaths.date) AS PerDayVaccinations
	FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)'] AS C19Deaths
	JOIN [SQL Portfolio Project - Alex].dbo.['CovidVaccinations - (Sagar)'] AS C19Vacc
		ON C19Deaths.location = C19Vacc.location
		AND C19Deaths.date = C19Vacc.date
	WHERE C19Deaths.location = 'INDIA' AND C19Deaths.continent IS NOT NULL
	ORDER BY 2, 3

SELECT *, (TotalPplVacc/Population)*100
FROM #PercentPopVacc;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creating View for later Visualizations
---------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE VIEW PercentPplVacc AS
SELECT C19Deaths.continent, C19Deaths.location, C19Deaths.date, C19Deaths.population, C19Vacc.new_vaccinations,
		SUM(CONVERT(float, C19Vacc.new_vaccinations)) OVER (PARTITION BY C19Deaths.location 
		ORDER BY C19Deaths.location, C19Deaths.date) AS PerDayVaccinations
FROM [SQL Portfolio Project - Alex].dbo.['CovidDeaths - (Sagar)'] AS C19Deaths
JOIN [SQL Portfolio Project - Alex].dbo.['CovidVaccinations - (Sagar)'] AS C19Vacc
	ON C19Deaths.location = C19Vacc.location
	AND C19Deaths.date = C19Vacc.date
WHERE C19Deaths.location = 'INDIA' AND C19Deaths.continent IS NOT NULL

SELECT *
FROM PercentPplVacc;

---------------------------------------------------------------------------------------------------------------------------------------------------------------