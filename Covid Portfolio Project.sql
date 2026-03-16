select * from coviddeaths;

-- Removing blanks with NULLs in every column (so that it gets treated as null instead of a blank string) 
UPDATE coviddeaths
set 
iso_code = NULLIF(iso_code,''),
continent = NULLIF(continent,''),
location = NULLIF(location,''),
date = NULLIF(date,''),
population = NULLIF(population,''),
total_cases = NULLIF(total_cases,''),
new_cases = NULLIF(new_cases,''),
new_cases_smoothed = NULLIF(new_cases_smoothed,''),
total_deaths = NULLIF(total_deaths,''),
new_deaths = NULLIF(new_deaths,''),
new_deaths_smoothed = NULLIF(new_deaths_smoothed,''),
total_cases_per_million = NULLIF(total_cases_per_million,''),
new_cases_per_million = NULLIF(new_cases_per_million,''),
new_cases_smoothed_per_million = NULLIF(new_cases_smoothed_per_million,''),
total_deaths_per_million = NULLIF(total_deaths_per_million,''),
new_deaths_per_million = NULLIF(new_deaths_per_million,''),
new_deaths_smoothed_per_million = NULLIF(new_deaths_smoothed_per_million,''),
reproduction_rate = NULLIF(reproduction_rate,''),
icu_patients = NULLIF(icu_patients,''),
icu_patients_per_million = NULLIF(icu_patients_per_million,''),
hosp_patients = NULLIF(hosp_patients,''),
hosp_patients_per_million = NULLIF(hosp_patients_per_million,''),
weekly_icu_admissions = NULLIF(weekly_icu_admissions,''),
weekly_icu_admissions_per_million = NULLIF(weekly_icu_admissions_per_million,''),
weekly_hosp_admissions = NULLIF(weekly_hosp_admissions,''),
weekly_hosp_admissions_per_million = NULLIF(weekly_hosp_admissions_per_million,'');

-- Changing date column format from text to datetime 
update coviddeaths
set date = str_to_date(date,"%d/%m/%Y");

alter table coviddeaths
modify date datetime;

select * from coviddeaths
order by location, date;

-- Let's replace blanks with nulls in covidVaccination table too.
select * from covidvaccinations;

update covidvaccinations
set 
iso_code = nullif(iso_code,''),
continent = nullif(continent,''),
location = nullif(location,''),
date = nullif(date,''),
new_tests = nullif(new_tests,''),
total_tests = nullif(total_tests,''),
total_tests_per_thousand = nullif(total_tests_per_thousand,''),
new_tests_per_thousand = nullif(new_tests_per_thousand,''),
new_tests_smoothed = nullif(new_tests_smoothed,''),
new_tests_smoothed_per_thousand = nullif(new_tests_smoothed_per_thousand,''),
positive_rate = nullif(positive_rate,''),
tests_per_case = nullif(tests_per_case,''),
tests_units = nullif(tests_units,''),
total_vaccinations = nullif(total_vaccinations,''),
people_vaccinated = nullif(people_vaccinated,''),
people_fully_vaccinated = nullif(people_fully_vaccinated,''),
new_vaccinations = nullif(new_vaccinations,''),
new_vaccinations_smoothed = nullif(new_vaccinations_smoothed,''),
total_vaccinations_per_hundred = nullif(total_vaccinations_per_hundred,''),
people_vaccinated_per_hundred = nullif(people_vaccinated_per_hundred,''),
people_fully_vaccinated_per_hundred = nullif(people_fully_vaccinated_per_hundred,''),
new_vaccinations_smoothed_per_million = nullif(new_vaccinations_smoothed_per_million,''),
stringency_index = nullif(stringency_index,''),
population_density = nullif(population_density,''),
median_age = nullif(median_age,''),
aged_65_older = nullif(aged_65_older,''),
aged_70_older = nullif(aged_70_older,''),
gdp_per_capita = nullif(gdp_per_capita,''),
extreme_poverty = nullif(extreme_poverty,''),
cardiovasc_death_rate = nullif(cardiovasc_death_rate,''),
diabetes_prevalence = nullif(diabetes_prevalence,''),
female_smokers = nullif(female_smokers,''),
male_smokers = nullif(male_smokers,''),
handwashing_facilities = nullif(handwashing_facilities,''),
hospital_beds_per_thousand = nullif(hospital_beds_per_thousand,''),
life_expectancy = nullif(life_expectancy,''),
human_development_index = nullif(human_development_index,'');

-- Changing date column format from text/string to datetime in CovidVaccinations table
update covidvaccinations
set date = str_to_date(date, "%d/%m/%Y");

alter table covidvaccinations
modify date datetime;

select * from covidvaccinations order by location,date;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by location, date;

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like 'India'
order by location,date;

-- Looking at Total Cases vs Population
-- Shows what percentage of popultaion got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as CovidCasesPercentage
from coviddeaths
where location = 'India'
order by date;

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from coviddeaths 
group by location,population
order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count per Population
-- Note for me (Learning perspective): here unsigned is used as int, unsigned means only positive integers and signed means negative-positive integers
select location, max(cast(total_deaths as unsigned)) as TotalDeathCount 
from coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc;

select * from coviddeaths 
where continent is not null;

-- Let's break things down by continent
select continent, max(cast(total_deaths as unsigned)) as TotalDeathCount 
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Global Numbers
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from coviddeaths
where continent is not null
group by date
order by date;


-- Looking at Total Population vs Vaccination
select d.continent,d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
 from coviddeaths d 
 join covidvaccinations v 
 on d.location = v.location 
 and d.date = v.date
 where d.continent is not null
 order by location, date;
 
 -- USE CTE
 
 with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as 
 (
 select d.continent,d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
 from coviddeaths d 
 join covidvaccinations v 
 on d.location = v.location 
 and d.date = v.date
 where d.continent is not null
 )
 select *, (RollingPeopleVaccinated/Population)*100 
 from PopvsVac;


-- Temp Table method
Create temporary table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population int,
New_vaccinations int,
RollingPeopleVaccinated float
);

insert into PercentPopulationVaccinated
(
select d.continent,d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
 from coviddeaths d 
 join covidvaccinations v 
 on d.location = v.location 
 and d.date = v.date
 where d.continent is not null
 );
 
 select *, (RollingPeopleVaccinated/Population)*100 from PercentPopulationVaccinated;
 
 -- Creating View to store data for later visualizations
 
 Create View PercentPopulationVaccinated as
 select d.continent,d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
 from coviddeaths d 
 join covidvaccinations v 
 on d.location = v.location 
 and d.date = v.date
 where d.continent is not null;
 