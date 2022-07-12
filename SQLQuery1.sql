select *from ..CovidDeaths
Where continent is not null
order by 3,4



--select *from ..CovidVaccinations
--order by 3,4

--Select data that we are going to be using

select Location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

--select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as case_ratio
--from PortfolioProject..CovidDeaths
--where location like '%states%'
--order by 1,2

select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as case_ratio
from PortfolioProject..CovidDeaths
where location='Turkey'
order by 1,2

--Looking at Total Cases vs Population
select Location, date, total_cases, population, (total_cases/population)*100 as case_ratio_population
from PortfolioProject..CovidDeaths
where location='Turkey'
order by 1,2

--Looking at countries with highest infection rate compared to population

select Location, population,MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentInfectedPopulation
from PortfolioProject..CovidDeaths
--where location='Turkey'
group by population, location
order by PercentInfectedPopulation desc
--showing countries with highest death count  per population


--Lets break thisgs down by continent




--showing continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group By date
order by 1,2


--Looking at total population vs vaccinations


select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
order by 2,3

--USE CTE
with popvsvac(continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--order by 2,3
)

select*, (RollingPeopleVaccinated/Population)*100 as RollingpeopvacRate
from popvsvac



--TEMP TABLE
 
 create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )




 insert into #PercentPopulationVaccinated

 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated