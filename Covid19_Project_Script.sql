/*
Covid19 Data Exploration
Skills used: Joins, Common Table Expressions (CTE), Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM Covid..CovidDeaths
ORDER BY 3, 4;

SELECT *
FROM Covid..CovidVaccinations
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid..CovidDeaths
ORDER BY 1, 2;

-- total_cases vs total_deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM Covid..CovidDeaths
WHERE location = 'Singapore'
ORDER BY 1, 2;

-- total_cases vs population
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS infection_rate
FROM Covid..CovidDeaths
WHERE location = 'Singapore'
ORDER BY 1, 2;

-- countries with highest infection rates
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population) * 100 AS max_infection_rate
FROM Covid..CovidDeaths
GROUP BY location, population
ORDER BY max_infection_rate DESC;

-- countries with highest death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- continents with highest death count
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM Covid..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- daily numbers across the world
SELECT date, SUM(new_cases) AS daily_cases, SUM(CAST(new_deaths AS INT)) AS daily_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS daily_death_percentage
FROM Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

-- total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) as rolling_vaccinations
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) as rolling_vaccinations
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_vaccinations/population) * 100 AS population_vaccinated_rate
FROM pop_vs_vac;

-- temp table
DROP TABLE IF EXISTS #population_vaccinated_rate
CREATE TABLE #population_vaccinated_rate 
(
continent NVARCHAR(255), 
location NVARCHAR(255), 
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_vaccinations NUMERIC
)

INSERT INTO #population_vaccinated_rate
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) as rolling_vaccinations
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_vaccinations/population) * 100 AS population_vaccinated_rate
FROM #population_vaccinated_rate;

-- create view to store data for visualization
CREATE VIEW population_vaccinated_rate AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.date) as rolling_vaccinations
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM population_vaccinated_rate;
