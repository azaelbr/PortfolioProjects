-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- shows likelyhood of dying if you contract covid in your country

Select Location, Date, total_cases, total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN NULL -- Avoid division by zero
        ELSE (CAST(total_deaths AS FLOAT) / total_cases) * 100
    END as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'brazil' and continent is not null
order by 1, 2

-- looking at total cases vs population

Select Location, Date, population, total_cases,  
    CASE 
        WHEN total_cases = 0 THEN NULL -- Avoid division by zero
        ELSE (total_cases / CAST(population AS FLOAT)) * 100
    END as InfectedPercentage
from PortfolioProject..CovidDeaths
where location = 'brazil' and continent is not null
order by 1, 2


-- looking at countries with highest infection rate compared to population

Select
	Location,
	population,
	MAX(total_cases) AS HighestInfectionCount,  
    CASE 
        WHEN MAX(total_cases) = 0 THEN NULL -- Avoid division by zero
        ELSE (MAX(total_cases) / CAST(population AS FLOAT)) * 100
    END as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location, population
order by 4 desc

-- showing countries with highest death count per population

Select
	Location,
	MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select
	location,
	MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--continue the class at 39:48 / 1:17:08

-- GLobal Numbers

Select
	--Date,
	SUM(new_cases) AS TotalCases,
	SUM(new_deaths) AS TotalDeaths,
		CASE
			WHEN SUM(new_cases) = 0 then null
			WHEN SUM(new_deaths) = 0 then null			
			ELSE SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100
		END as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2

--looking for total population vs vaccnations

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as New_Vac_PerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, New_Vac_PerDay)
as
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as New_Vac_PerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (CAST(New_Vac_PerDay AS FLOAT) / Population)*100
FROM PopvsVac
where location = 'Brazil'

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date DATETIME,
Population numeric,
New_Vaccinations numeric,
New_Vac_PerDay numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as New_Vac_PerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

SELECT *, (CAST(New_Vac_PerDay AS FLOAT) / Population)*100 as Percentage
FROM #PercentPopulationVaccinated
where location = 'Brazil'


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date) as New_Vac_PerDay
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
from PercentPopulationVaccinated