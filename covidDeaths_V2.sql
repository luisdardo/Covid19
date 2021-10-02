SELECT * 
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT null
order by 3, 4



--current deaths vs current cases = deaths per cases at a point in time

Select location, date, new_cases,new_deaths, (new_deaths/new_cases)*100 AS current_perc_of_deaths
FROM PortfolioProject..covidDeaths
WHERE location like '%states%'
ORDER by 1, 2


--aggregated total deaths vs aggregated total cases = deaths per cases aggregated

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS aggregated_perc_of_deaths
FROM PortfolioProject..covidDeaths
WHERE location like '%states%'
ORDER by 1, 2


-- aggregated total cases Vs Population

SELECT location, date, population,total_cases ,(total_cases/population)*100 as PercOfcases
From PortfolioProject..covidDeaths
WHERE location like '%states%'
order by 1,2


--what country has the highest infection rate compared to population
SELECT location, population, MAX(total_cases)AS highestInfectionCount, MAX((total_cases/population))*100 AS percentagePopulationInfected
From PortfolioProject..covidDeaths
WHERE continent IS NOT null
GROUP BY location,population
ORDER BY percentagePopulationInfected DESC;


--Showing Countries with highest death count per population

SELECT location, population, MAX(CAST(total_deaths AS int))AS highestDeathCount, MAX((total_deaths/population))*100 AS percentageDeathsPopulation
From PortfolioProject..covidDeaths
WHERE continent IS NOT null
GROUP BY location,population
ORDER BY percentageDeathsPopulation DESC;

--BY CONTINENT

SELECT continent, MAX(CAST (total_deaths AS int)) AS totalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY totalDeathCount DESC


--showing continents with highest death count per population

SELECT continent, MAX(total_deaths/population)*100 AS deathRatePopulation
FROM portfolioProject..covidDeaths
WHERE continent IS NOT null
GROUP BY continent
order by deathRatePopulation DESC

-- Global Numbers

Select date, SUM(new_cases) AS newGlobalCases, SUM(CAST(new_deaths AS int)) AS newGlobalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) *100 AS globalDeathPercentageOfCases
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT null
GROUP BY date
ORDER by 1, 2


--QUERY  #23: looking at total population vs vaccination
SELECT d.continent,d.location, d.date,d.population,v.new_vaccinations
,SUM(CAST(v.new_vaccinations AS int) ) OVER (PARTITION by d.location ORDER BY d.location,d.date) AS dailyAggregatedVaccinations --using partition instead of GROUP BY
FROM PortfolioProject..covidDeaths d                 --sum over partition replaces GROUP BY, but it does not collapses into a single row, rather multiple with same results
JOIN PortfolioProject..covidVaccinations1 v
	ON d.location= v.location
	AND d.date= v.date
WHERE d.continent IS NOT null
ORDER BY 2,3

--A Common Table Expression, also called as CTE in short form, is a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement
--USING above dailyAggregatedVaccinations as CTE to be used in different query

WITH popVsvacs (continent,location, date, population,new_vaccinations, dailyAggregatedVaccinations)
AS
(
SELECT d.continent,d.location, d.date,d.population,v.new_vaccinations
,SUM(CAST(v.new_vaccinations AS int) ) OVER (PARTITION by d.location ORDER BY d.location,d.date) AS dailyAggregatedVaccinations 
FROM PortfolioProject..covidDeaths d                 
JOIN PortfolioProject..covidVaccinations1 v
	ON d.location= v.location
	AND d.date= v.date
WHERE d.continent IS NOT null
--ORDER BY 2,3
)

SELECT 
*,(dailyAggregatedVaccinations/population)*100 AS percentPopulationVaccinated
FROM popVsvacs

ORDER BY 2,3

--TEMP TABLE 

USE PortfolioProject

DROP TABLE if exists #PercentPopulationVaccinated2  --recommended 
CREATE TABLE #PercentPopulationVaccinated2 --THIS IS THE TEMPORARY TABLE CREATED

(continent nvarchar(255),           --THIS IS THE COLUMNS FOR TEMPORARY TABLE.. columns must be created prior
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
dailyAggregatedVaccinations  numeric
)

INSERT INTO #PercentPopulationVaccinated2           --Now we use the newly created temp table and we are going insert into it, all the select query results
SELECT d.continent,d.location, d.date,d.population,v.new_vaccinations  --all this data will be inserted into temptable
,SUM(CAST(v.new_vaccinations AS int) ) OVER (PARTITION by d.location ORDER BY d.location,d.date) AS dailyAggregatedVaccinations 
FROM PortfolioProject..covidDeaths d                 
JOIN PortfolioProject..covidVaccinations1 v
	ON d.location= v.location
	AND d.date= v.date
WHERE d.continent IS NOT null



SELECT *,(dailyAggregatedVaccinations/population)*100 AS percentVaccinated
FROM #PercentPopulationVaccinated2


--CREATING VIEWs   ..storing data for later visualizations

CREATE VIEW percentPopulationVaccinated AS 
SELECT d.continent,d.location, d.date,d.population,v.new_vaccinations  --all this data will be inserted into temptable
,SUM(CAST(v.new_vaccinations AS int) ) OVER (PARTITION by d.location ORDER BY d.location,d.date) AS dailyAggregatedVaccinations 
FROM PortfolioProject..covidDeaths d                 
JOIN PortfolioProject..covidVaccinations1 v
	ON d.location= v.location
	AND d.date= v.date
WHERE d.continent IS NOT null

SELECT * 
FROM percentPopulationVaccinated
WHERE location='hungary'