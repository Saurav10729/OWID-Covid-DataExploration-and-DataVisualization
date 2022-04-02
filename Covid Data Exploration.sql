SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4


--Select the data we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- looking at Total Cases v Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Nepal'
ORDER BY 1,2


-- looking at Total Cases v Population

 select location, date, total_cases, population, (total_cases/population)*100 as Infected_Popn_Percentage
 from PortfolioProject..CovidDeaths$
 --where location = 'nepal'
 order by 1,2

--which countries have highest infection rate with respect to total population
Select location, max(population) as PeakPopulation, max(total_cases) as PeakInfectionCount, Max((total_cases/population))*100 as Infection_rate
From PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%states%'
Group by location, population
Order by Infection_rate desc


-- showing countries with highest death count per population

Select location,max(cast(total_deaths as int)) as TotalDeathCount, max(population) as Population, Max((cast(total_deaths as int)/population))*100 as Death_rate
From PortfolioProject..CovidDeaths$
where continent is not null
--and location like '%asia%'
Group by location, population
Order by Death_rate desc

--looking at death count of countries in NorthAmerica
Select location, MAX(cast(total_deaths as int)) from PortfolioProject..CovidDeaths$
Where continent = 'north america'
Group by location
Order by location


-- Breakdown the data by Continents

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount, max(cast(total_deaths as int)/population) as Death_rate 
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Continents with highest death counts

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount, max(cast(total_deaths as int)/population) as Death_rate 
From PortfolioProject..CovidDeaths$
where continent is not null
--and location like '%state%'
Group by continent
Order by TotalDeathCount desc


-- GLOBAL DATA

--looking at Daily count of Cases V Deaths
Select date, SUM(new_cases)as TotalDailyCases, SUM(cast(new_deaths as int)) as TotalDailyDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_Percent
from PortfolioProject..CovidDeaths$
-- where location like '%nepal%'
where continent is not null
Group by date
order by 1,2 


-- looking at Total Count without Date Grouping
Select  SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_Percent
from PortfolioProject..CovidDeaths$
-- where location like '%nepal%'
where continent is not null
-- Group by date
order by 1,2 


-- JOINING Both CovidDeath and CovidVaccination Table

-- looking at total Population v Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.date) as CumulativeVaccinationCount
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Using CTE to utilize newly created column 'CumulativeVaccinationCount'
with PopnVsVac(Continent, Location, date, population, new_vaccinations, CumulativeVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.date) as CumulativeVaccinationCount
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
Select *, (CumulativeVaccinationCount/population)*100 
From PopnVsVac
order by Location,date



-- TEMP TABLE so we can utilize the column 'CumulativeVaccinationCount' more than once

Drop Table If Exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
CumulativeVaccinationCount numeric,
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.date) as CumulativeVaccinationCount
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (CumulativeVaccinationCount/population)*100 as VaccinationRate_Rolling 
from #PercentagePopulationVaccinated
order by Location,date 


-- creating views for Tableau Visualizations

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, 
dea.date) as CumulativeVaccinationCount
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3


-- viewing the data in the above created view.
Select * 
From PercentagePopulationVaccinated 
Where continent = 'asia'
