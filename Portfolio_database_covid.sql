/*
Portfolio of Covid-19 datebase

skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM portfolioProject..CovidDeaths
WHERE continent is not null
--Using"is not null" to clean some error in data base
ORDER BY 3,4



-- Select Data that we are going to be using


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- LOOKING AT TOTAL CASES VS TOTAL DEATHS


SELECT Location, date, total_cases, total_deaths,
       (total_deaths/total_cases)*100 AS deaths_percentage
FROM portfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2 DESC


--filtering by different country/state
SELECT Location, date, total_cases, total_deaths,
       (total_deaths/total_cases)*100 AS deaths_percentage
FROM portfolioProject..CovidDeaths
WHERE Location ='New Zealand' AND continent is not null
--other way to use WHERE location LIKE '%countryname%'
ORDER BY 1,2 DESC


-- LOOKING AT TOTAL CASES VS POPULATION
--Shows what percentage of population got covid


SELECT Location, date, total_cases, population,
       (total_cases/population)*100 AS Total_Population_Got_Covid
FROM portfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 DESC

--filtering by different country/state
SELECT Location, date, total_cases, population,
       (total_cases/population)*100 AS Total_Population_Got_Covid
FROM portfolioProject..CovidDeaths
WHERE Location ='New Zealand' AND continent is not null
--other way to use WHERE location LIKE '%countryname%'
ORDER BY 1,2 DESC


-- LOOKING WITH HIGHEST INFECTION RATE COMPARED TO POPULATION


SELECT Location, population,
       MAX(total_cases) AS highest_infections,
       MAX((total_cases/population))*100 AS percent_Population_Infected
FROM portfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY highest_infections DESC


-- SHOWING COUNTRIES WITH HIGHEST DEATHS COUNT PER POPULATION


SELECT Location, MAX(CAST(total_deaths AS INT)) AS total_deaths_count
FROM portfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY total_deaths_count DESC


--SHOWING BY CONTINENT


SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_deaths_count
FROM portfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_deaths_count DESC


--GLOBAL NUMBERS


SELECT SUM(new_cases) AS total_cases, 
       SUM(CAST(total_deaths AS INT)) AS total_deaths,
	   SUM(CAST(total_deaths AS INT))/SUM(total_cases)*100 AS deaths_percentage
FROM portfolioProject..CovidDeaths
--WHERE Location ='New Zealand'--other way to use WHERE location LIKE '%countryname%' 
WHERE continent is not null 
ORDER BY 1,2 DESC


--USING JOIN



-- LOOKING AT TOTAL POPULATION VS VACCINATIONS


SELECT dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations as numeric)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.date) AS people_vaccinated
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null AND new_vaccinations is not null
ORDER BY 2,3 


--filtering by different country/state
SELECT dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations as numeric)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.date) AS people_vaccinated
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.location ='New Zealand' AND dea.continent is not null AND new_vaccinations is not null
ORDER BY 2,3 DESC



--USING CTE



WITH PopvsVac (continent,Location, date, population, new_vaccinations, people_vaccinated)
AS
(
SELECT dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations as numeric)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.date) AS people_vaccinated
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null AND new_vaccinations is not null
--ORDER BY 2,3
)
SELECT *, (people_vaccinated/population)*100 AS percent_population
FROM PopvsVac


-- CREATING TEMP TABLE


DROP TABLE IF exists #PercentpopulationVaccinated
CREATE TABLE #PercentpopulationVaccinated
(
continet nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric

)
INSERT INTO #PercentpopulationVaccinated
SELECT dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.date) AS people_vaccinated
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (people_vaccinated/population)*100 AS percent_population
FROM #PercentpopulationVaccinated


-- CREATING VIEWS TO FUTURE ANALYSIS AND CREATE TABLEAU VIZ


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.date) AS people_vaccinated
FROM portfolioProject..CovidDeaths dea
JOIN portfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3


CREATE VIEW TotalDeathsPerContinent AS 
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_deaths_count
FROM portfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
--ORDER BY total_deaths_count DESC


CREATE VIEW TotalDeathsPerPopulation AS
SELECT Location, MAX(CAST(total_deaths AS INT)) AS total_deaths_count
FROM portfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
--ORDER BY total_deaths_count DESC


CREATE VIEW TotalCasesPerPopulation AS 
SELECT Location, date, total_cases, population,
       (total_cases/population)*100 AS Total_Population_Got_Covid
FROM portfolioProject..CovidDeaths
WHERE continent is not null
--ORDER BY 1,2 DESC


CREATE VIEW PercentPopulationInfected AS
SELECT Location, population,
       MAX(total_cases) AS highest_infections,
       MAX((total_cases/population))*100 AS percent_Population_Infected
FROM portfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, population
--ORDER BY highest_infections DESC


