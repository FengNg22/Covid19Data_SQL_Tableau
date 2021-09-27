SELECT *
FROM PortfolioProject..coviddeath$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covidvaccination$
--ORDER BY 3,4

-- Select the data to be used
SELECT location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeath$
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Total Cases vs Total deaths in Malaysia
SELECT location,date, total_cases, total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..coviddeath$
WHERE location like '%malaysia%' AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
-- # shows what percentage of population got test and confirm
SELECT location,date,population, total_cases, 
	(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..coviddeath$
WHERE continent IS NOT NULL
-- WHERE location like '%malaysia%'
ORDER BY 1,2

-- Highest Infection Rate vs Population
SELECT location,population, MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..coviddeath$
-- WHERE location LIKE '%malaysia%' OR location LIKE 'Singapore'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Let's Break Down By Continent
-- Highest Death Count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeath$
-- WHERE location LIKE '%malaysia%' OR location LIKE 'Singapore'
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeath$
-- WHERE location LIKE '%malaysia%' OR location LIKE 'Singapore'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Continent with highest death count per population 
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeath$
-- WHERE location LIKE '%malaysia%' OR location LIKE 'Singapore'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT 
--	date, 
	SUM(new_cases) AS totalnewcases, 
	SUM(CAST(new_deaths as INT)) AS totalnewdeath, 
	SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentagePerDay
FROM PortfolioProject..coviddeath$
-- WHERE location like '%malaysia%' AND 
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY date,DeathPercentagePerDay desc

SELECT 
	date, 
	SUM(new_cases) AS totalnewcases, 
	SUM(CAST(new_deaths as INT)) AS totalnewdeath, 
	SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentagePerDay
FROM PortfolioProject..coviddeath$
-- WHERE location like '%malaysia%' AND 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date,DeathPercentagePerDay desc

-- Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		-- SUM(CONVERT(int, vac.new_vaccinations))
FROM PortfolioProject..coviddeath$ AS dea
JOIN PortfolioProject..covidvaccination$ AS vac
	ON (dea.date=vac.date)
	AND (dea.location = vac.location) 
WHERE dea.continent IS NOT NULL  -- AND dea.location='Malaysia' AND new_vaccinations IS NOT NULL
--GROUP BY dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
ORDER BY 2,3

-- Use CTE 
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		-- SUM(CONVERT(int, vac.new_vaccinations))
FROM PortfolioProject..coviddeath$ AS dea
JOIN PortfolioProject..covidvaccination$ AS vac
	ON (dea.date=vac.date)
	AND (dea.location = vac.location) 
WHERE dea.continent IS NOT NULL  -- AND dea.location='Malaysia' AND new_vaccinations IS NOT NULL
--GROUP BY dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac
-- WHERE location='Malaysia'



-- Temp Table
DROP Table IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeath$ AS dea
JOIN PortfolioProject..covidvaccination$ AS vac
	ON (dea.date=vac.date)
	AND (dea.location = vac.location) 
WHERE dea.continent IS NOT NULL  -- AND dea.location='Malaysia' AND new_vaccinations IS NOT NULL


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Create view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeath$ AS dea
JOIN PortfolioProject..covidvaccination$ AS vac
	ON (dea.date=vac.date)
	AND (dea.location = vac.location) 
WHERE dea.continent IS NOT NULL  -- AND dea.location='Malaysia' AND new_vaccinations IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated