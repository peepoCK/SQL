SELECT *
FROM PortfolioProject..CovidDeaths
	
SELECT *
FROM PortfolioProject..CovidVaccinations


-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
		ORDER BY 1,2

-- Convert Column to numeric 
ALTER TABLE CovidDeaths
	ALTER Column total_cases numeric 

ALTER TABLE CovidDeaths
	ALTER Column total_deaths numeric 


-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
		ORDER BY 1,2

-- DeathPercentage in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
	WHERE location = 'United States' AND continent IS NOT NULL
	ORDER BY 1,2


-- Looking at Total Cases vs Population, United States

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
	WHERE location = 'United States' AND continent IS NOT NULL
		ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
GROUP BY location, population
		ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population 

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
GROUP BY location
	ORDER BY TotalDeathCount DESC

-- Continent with Highest Death Count per Population
	-- Does not include data from 'WHERE Continent IS NULL' so TotalDeathCount is not 100% accurate

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
GROUP BY continent
	ORDER BY TotalDeathCount DESC

-- Accurate representation of TotalDeathCount 

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
	WHERE continent IS NULL
GROUP BY location
	ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths 
FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
GROUP BY date
		ORDER BY 1,2

-- Total Population vs Vaccinations

--ALTER TABLE CovidVaccinations
--	ALTER Column new_vaccinations bigint 

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinationCount
-- , (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	ORDER BY 2,3


-- Using CTE 
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingVaccinationCount)
AS
	(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinationCount
-- , (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	-- ORDER BY 2,3
	)

SELECT *, (RollingVaccinationCount/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac


-- Using TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
	(
	Continent nvarchar(255), 
	Location nvarchar(255), 
	Date datetime, Population numeric, 
	New_vaccinations bigint, 
	RollingVaccinationCount numeric
	)
INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinationCount
-- , (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	-- ORDER BY 2,3

SELECT *, (RollingVaccinationCount/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


-- Creating Views to store data for later visualizations

-- 1ST VIEW
DROP VIEW IF EXISTS PercentPopulationVaccinated
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinationCount
-- , (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths AS CD
JOIN PortfolioProject..CovidVaccinations AS CV
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
	-- ORDER BY 2,3
GO
	SELECT *
	FROM PercentPopulationVaccinated
		ORDER BY 2,3

-- 2ND VIEW
DROP VIEW IF EXISTS HighestInfectionRate
GO
CREATE VIEW HighestInfectionRate AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
GROUP BY location, population
		--ORDER BY PercentPopulationInfected DESC
GO
	SELECT *
	FROM HighestInfectionRate
		ORDER BY PercentPopulationInfected DESC

-- 3RD VIEW
DROP VIEW IF EXISTS HighestDeathCountbyLocation
GO
CREATE VIEW HighestDeathCountbyLocation AS
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
	WHERE continent IS NOT NULL
GROUP BY location
	--ORDER BY TotalDeathCount DESC
GO	
	SELECT *
	FROM HighestDeathCountbyLocation
		ORDER BY TotalDeathCount DESC



