
Select *
From PortfolioProject..CovidDeaths$
order by 3,4


/*Select *
From PortfolioProject..CovidVaccinations$
order by 3,4*/

--Selecting data that will be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likely hood of dying of COVID in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


--Looking at total cases vs population
--Shows what percentage of the population got COVID

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like'%states%'
order by 1,2



--Looking at countries with highest infection rate compared to population

Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like'%states%'
Group by location, population
order by PercentPopulationInfected desc


--Showing the countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc


--Breaking down by continent


--Showing the continents with the highest death count per popluation

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc



--GLOBAL Numbers


--Global total death percentage per day

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--where location like '%states%'
Where continent is not null
Group by date
order by 1,2




--Looking at total population vs vacciantion

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccianted
--, (RollingPeopleVaccianted/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE
--Around the one hour mark

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccianted)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccianted
--, (RollingPeopleVaccianted/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccianted/population)*100
From PopvsVac



--TEMP TABLE


Drop Table if exists #PercentPopulationVaccianted
Create Table #PercentPopulationVaccianted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacciantions numeric,
RollingPeopleVaccianted numeric
)

Insert into #PercentPopulationVaccianted
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccianted
--, (RollingPeopleVaccianted/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccianted/population)*100
From #PercentPopulationVaccianted



-- Creating View to store data for visualizations

Create View PercentPopulationVaccianted as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccianted
--, (RollingPeopleVaccianted/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccianted