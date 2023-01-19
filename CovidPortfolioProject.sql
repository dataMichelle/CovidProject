SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3, 4


SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopInfected DESC
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- SELECT Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Change column types
 USE PortfolioProject;
 ALTER TABLE CovidDeaths
	ALTER COLUMN total_cases FLOAT;
	

-- Looking at Total Cases vs. Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2 

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases / population) * 100 as PercentPopInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1, 2 

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 as PercentPopInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopInfected DESC

-- Showing the countries with the highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Breaking things down by continent
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Because the number for North America appears to be using US number we need to modify
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases) * 100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- Looking at total population vs. vaccinations

-- Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPplVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPplVaccinated / population) * 100
FROM #PercentPopulationVaccinated


-- USE CTE
-- With PopvsVac (continent, location, date, population, RollingPplVaccinated)

-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPplVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

-- Now you can query off the view
SELECT *
FROM PercentPopulationVaccinated