select * 
from PortfolioProject.dbo.CovidDeaths$

select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--select data that we are going to be using

select Location,date,total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at total cases VS total deaths
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at total cases vs population
select Location,date,population,total_cases,(total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--looking at countriess with highest infection rate compared to population
select Location,population,max(total_cases) as highestInfectionCount ,max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by Location,population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
--LET'S BREAK THINGS DOWN BY CONTINENET
select continent,max(cast(total_deaths as int )) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

select location ,max(cast(total_deaths as int )) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--showing continent with the highest death count per popoulation
select continent,max(cast(total_deaths as int )) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers
select date,sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where continent is not null
group by date
having SUM(new_cases) <> 0
order by 1,2

--Loking at total population vs vaccination
select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location,dea.Date)
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopvsVac (Continent , Location,Population,Date,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.population,dea.date,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location,dea.Date)
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE
Drop Table If exists #PercentPpopulationVaccinated
create table #PercentPpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPpopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location,dea.Date)
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPpopulationVaccinated


--creating view to store data for later 

create View PPV as

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over
(partition by dea.location order by dea.location,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from PortfolioProject.dbo.PPV

