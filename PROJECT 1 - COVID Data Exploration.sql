/* DATA EXPLORATION */
--**data as of 12/18/2021
--SELECT DATA WE WILL BE USING

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Calculate death %, shows chance of death if you contract covid in given country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%States%'
ORDER BY 1,2

--Looking at Total Cases vs Population
-- Shows % of population that got Covid

SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%States%'
ORDER BY 1,2

-- Looking at countries with highest infection Rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY Location,population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with highest death count per population
SELECT Location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- BREAKING DATA DOWN BY CONTINENT

SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population 

SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
---*need to add aggregate functions 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths AS int)) /SUM
	(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

----- If we want to see the death percentage world wide - (1.95 %) 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths, SUM(cast(new_deaths AS int)) /SUM
	(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

------------------------------------------------------------------------------------------
/*Covid Vaccinations*/
--Looking at total population vs vaccinated people
----**using CONVERT 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	AS RollingPeopleVaccianated
	, (RollingPeopleVaccianated/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--** USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	AS RollingPeopleVaccianated
--	, (RollingPeopleVaccianated/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopvsVac

---------/*TEMP TABLE*/

DROP TABLE IF Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	AS RollingPeopleVaccianated
--	, (RollingPeopleVaccianated/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

----Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date)
	AS RollingPeopleVaccianated
--	, (RollingPeopleVaccianated/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

--Query the newly created View
SELECT *
FROM PercentPopulationVaccinated

