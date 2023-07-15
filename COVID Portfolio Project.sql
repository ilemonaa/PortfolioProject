--Select Data That We Are Going To Use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Total Deathsyou contract covid in each country
--Shows likelihood of dying if 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeath
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population 
-- Shows What Population Has Gotten Covid
SELECT Location, date,population, total_cases, (total_cases/population)*100 as PercentageOfCovidInPopulation
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2 

--Highest Infection Rates Internationally compared to  Population

SELECT continent, location, population, MAX(total_cases)as InfectionCount, MAX((total_cases/population))*100 as PercentageOfCovidInPopulation
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP  BY continent, location, population
ORDER BY  PercentageOfCovidInPopulation desc


--Showing the countries with the highest death count per population

SELECT continent, Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP  BY continent, location
ORDER BY  TotalDeathCount desc

--Let's break things down by continent


--Showing continents with highest

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP  BY continent
ORDER BY  TotalDeathCount desc


--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deathhs, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--TOTAL WORLD DEATH PERCENTAGE

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deathhs, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--LOOKING AT TOTAL POPULATION VS VACCINNATION

SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccines as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

--ROLLING COUNT

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentage
From PopvsVac


--TEMP TABLES
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as percentage
From #PercentPopulationVaccinated

--Creating view to store for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	--order by 2,3
