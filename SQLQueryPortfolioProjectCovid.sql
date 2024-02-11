SELECT *
FROM [PortfolioProject].[dbo].[coviddeaths]
ORDER BY 3,4


--SELECT *
--FROM [PortfolioProject].[dbo].[Covid-Vaccinations]
--ORDER BY 3,4

-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..[coviddeaths]
order by 1,2

--Looking at Total_cases vs Total_deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[covid-deaths]
where location = 'india'
order by 1,2

--Looking at Total_cases vs Population
--Shows what percent of population got covid
select Location, date, total_cases, population, (total_cases/population)*100 
from PortfolioProject..[coviddeaths]
where location = 'india'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..[coviddeaths]
Group by Location, Population
order by 3 desc

--Showing countries with highest death count per population	

select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..[covid-deaths]
where continent is null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..[coviddeaths]
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continents with highest death counts per population

select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..[coviddeaths]
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) as Total_cases
from PortfolioProject..[coviddeaths]
--where continent is not null
--Group By new_cases, date
Order By 1 desc


-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..[coviddeaths] dea
join PortfolioProject..[CovidVaccinations] vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null and new_vaccinations is not null
group by dea.continent, dea.location, dea.population, new_vaccinations, dea.date
order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..[coviddeaths] dea
join PortfolioProject..[CovidVaccinations] vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null and new_vaccinations is not null and dea.location = 'india'
group by dea.continent, dea.location, dea.population, new_vaccinations, dea.date
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--create view
drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
sum(cast(new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..[coviddeaths] dea
join PortfolioProject..[CovidVaccinations] vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null and new_vaccinations is not null
group by dea.continent, dea.location, dea.population, new_vaccinations, dea.date
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
from PercentPopulationVaccinated











