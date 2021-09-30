-- For Tableau

-- 1. new death cases vs new cases
SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..coviddeath$
WHERE continent IS NOT NULL
ORDER BY 1,2


-- 2. Total death count per location
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeath$
Where continent is null 
-- excluded non-location, european union is part of europe
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3. the percentage of population infected
Select 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount,  
	MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..coviddeath$
Group by Location, Population
Order by PercentPopulationInfected desc

-- 4. 
Select 
	Location, 
	Population,date, 
	MAX(total_cases) as HighestInfectionCount,  
	Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..coviddeath$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


-- 1.
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeath$ AS dea
Join PortfolioProject..covidvaccination$ AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3

-- 2. new death cases vs new cases
Select 
	SUM(new_cases) as total_cases, 
	SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..coviddeath$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- 3. Total death count per location
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeath$
Where continent is null 
-- excluded non-location, european union is part of europe
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 4. the percentage of population infected
Select 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount,  
	MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..coviddeath$
Group by Location, Population
Order by PercentPopulationInfected desc


-- 5. total cases total deaths based on location,date, population
Select Location, date, population, total_cases, total_deaths
From PortfolioProject..coviddeath$
--Where location like '%states%'
where continent is not null 
order by 1,2

-- 6. RollingPeopleVaccinated vs population
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

-- 7. 
Select 
	Location, 
	Population,date, 
	MAX(total_cases) as HighestInfectionCount,  
	Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..coviddeath$
Group by Location, Population, date
order by PercentPopulationInfected desc

