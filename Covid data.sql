Select * 
From PortfolioProject..CovidDeath
Where Continent is not null
Order by 3,4

Select * 
From PortfolioProject..CovidVaccinations
Where Continent is not null
Order by 3,4



--Select the data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
Where Continent is not null
order by 1,2

-- Looking at Totalcases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where location like '%states%'
and Continent is not null
order by 1,2

-- Looking at Totalcases vs Population
-- Shows What Percentage of Population got covid 

Select Location, date, Population, total_cases, (cast(total_cases as float)/Population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeath
Where location like '%states%'
and Continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(cast(total_cases as float)/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
--Where location like '%India%'
Where Continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%India%'
Where Continent is not null
Group by Location
order by TotalDeathCount desc


-- Lets break things down by Continent 
-- Showing Continents with Highest deaths count per population

Select Continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
--Where location like '%India%'
Where Continent is not null
Group by Continent
order by TotalDeathCount desc


-- Global Numbers 

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/(NULLIF((SUM(new_cases)),0))*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is not null
Group By date
order by 2

SET ANSI_WARNINGS OFF
GO

-- To find total worlds death percentage

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/(NULLIF((SUM(new_cases)),0))*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
Where continent is not null
order by 2


-- Location at Toatal Population vs Vaccanation (Convert or Cast is same, just format is different)
-- --Cannot get %RollingPeoplVaccinated with this method, we need to use other methods for this task)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date =vac.date
 where dea.continent is not null
-- and dea.location like '%albania%'
 order by 2,3



  --First Method (to get %RollingPeoplVaccinated)
 -- USE CTE 

 With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
 as 
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date =vac.date
 where dea.continent is not null
-- and dea.location like '%albania%'
 --order by 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100 as "%RollingVaccination"
 From PopvsVac


 --Second Method (to get %RollingPeoplVaccinated) 

 Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_Vaccination numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date =vac.date
 where dea.continent is not null
-- and dea.location like '%albania%'
 order by 2,3


 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated



 --Creating view to store data for later visualization 

 Create View PercentPopulationVaccinated as
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date =vac.date
 where dea.continent is not null
-- order by 2,3



Select * 
From PercentPopulationVaccinated