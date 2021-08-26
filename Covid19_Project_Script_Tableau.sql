/*
Queries used for Tableau Project
*/

-- 1. Death percentage worldwide
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 as death_percentage
FROM Covid..CovidDeaths
WHERE continent IS NOT NULL;

-- 2. Total deaths across all continents
SELECT location, SUM(CAST(new_deaths AS INT)) as total_deaths
FROM Covid..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_deaths DESC;

-- 3. Countries with highest infection rate
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population) * 100 AS max_infection_rate
FROM Covid..CovidDeaths
GROUP BY location, population
ORDER BY max_infection_rate DESC;

-- 4. Daily cumulative infection rate worldwide
SELECT location, population, date, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population) * 100 AS max_infection_rate
FROM Covid..CovidDeaths
GROUP BY location, population, date
ORDER BY max_infection_rate DESC;