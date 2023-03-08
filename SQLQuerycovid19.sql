select *
from [Portfolio Project]..CovidDeaths
order by 3,4

--select *
--from [Portfolio Project]..CovidVaccinations
--order by 3,4

--select data we are cameing to use 
select location,date,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths
order by 1,2

-- looking at total cases vs death cases
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathprecentage
from [Portfolio Project]..CovidDeaths
order by 1,2

--looking at total cases vs death cases in egypt
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathprecentage
from [Portfolio Project]..CovidDeaths
where location like '%Egypt%'
order by 1,2

--looking at total cases vs population in egypt
select location, date, population, total_cases, (total_cases/population)*100 as infaction
from [Portfolio Project]..CovidDeaths
where location like '%Egypt%'
order by 1,2

-- to visulaze the infaction in whole world and get a map on power pi
select location, date, population, total_cases, (total_cases/population)*100 as infaction
from [Portfolio Project]..CovidDeaths
order by 1,2

--looking to contery with the highest ifection rate compered to population
select location, population, max(total_cases) as thehighest, max((total_cases/population))*100 as infaction
from [Portfolio Project]..CovidDeaths
group by location, population
order by infaction desc

--looking to contery with the highest death rate compered to population
select location, population, max(total_deaths) as thehighestdeaths, max((total_deaths/population))*100 as infaction
from [Portfolio Project]..CovidDeaths
group by location, population
order by infaction desc

--looking to contery with the highest death rate
select location, max(cast(total_deaths as int)) as thehighestdeath
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by thehighestdeath desc

--LET'S BREAKING THINGS DOWN BY loctation
select location, max(cast(total_deaths as int)) as thehighestdeath
from [Portfolio Project]..CovidDeaths
where continent is null
group by location
order by thehighestdeath desc

--join two tables
select *
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

--looking at total population vs vaccination by date and location
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location 
order by dea.location,dea.date) as sum_new_vaccination
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
and vac.new_vaccinations is not null
order by 2,3

--use CTE
with popVSvac (continant,location,data,population,new_vaccinations,sum_new_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location 
order by dea.location,dea.date) as sum_new_vaccination
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
and vac.new_vaccinations is not null
)
select *,(sum_new_vaccination/population)*100 as new_vaccination_precentage
from popVSvac

--temp table
create table #precentagepopulationvaccinated
(
continant nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
sum_new_vaccination numeric,
)
insert into #precentagepopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location 
order by dea.location,dea.date) as sum_new_vaccination
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null
and vac.new_vaccinations is not null
select *,(sum_new_vaccination/population)*100 as new_vaccination_precentage
from #precentagepopulationvaccinated

--global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathPersentage
from [Portfolio Project]..CovidDeaths
where continent  is not null
order by 1,2

--LET'S BREAKING THINGS DOWN BY continent
select continent, max(cast(total_deaths as int)) as thehighestdeath
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by thehighestdeath desc


--creat a veiw to store date for visaulization
create view precentagepopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location 
order by dea.location,dea.date) as sum_new_vaccination
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent  is not null

select *
from precentagepopulationvaccinated