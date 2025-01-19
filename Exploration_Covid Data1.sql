


-- looking for total casez vs total deaths-----------------------------------------------------------------------------------------------------------------------------

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from [Portfolio project1]..[covid deaths]
where location like 'India'
order by 1,2

-- total cases vs population
-- % of people contracted covid

Select location, date, total_cases,population, 
(CONVERT(float, total_cases)/ population) * 100 AS 'contraction %'
from [Portfolio project1]..[covid deaths]
where location like 'India'
order by 3,5

-- Highest infection rate---------------------------------------------------------------------------------------------------------------------------------------

Select location, MAX(total_cases) as "Highest infection cases",population, 
(CONVERT(float, MAX(total_cases)/ convert(float,population))) * 100 AS 'Max contraction %'
from [Portfolio project1]..[covid deaths]
group by location,population 
order by [Max contraction %] desc


-- Highest death count per population for each country------------------------------------------------------------------------------------------------------------

UPDATE [Portfolio project1]..[covid deaths] 
SET continent = NULLIF(continent, '')

Select location, MAX(cast(total_deaths as int)) as "total death count"
from [Portfolio project1]..[covid deaths]
where continent IS NOT NULL
group by location
order by [total death count] desc

-- Based On Continent-----------------------------------------------------------------------------------------------------------------------------------------------

Select continent, MAX(cast(total_deaths as int)) as "total death count"
from [Portfolio project1]..[covid deaths]
where continent IS NOT NULL
group by continent
order by [total death count] desc

---Global Deaths % BY DATE-------------------------------------------------------------------

SELECT convert(datetime, date, 103), sum(cast(new_cases as int)) as new_cases, sum(cast(new_deaths as int)) as new_deaths, 
sum(cast(new_deaths as float))/ sum(NULLIF(cast(new_cases as float), 0)) *100  AS 'Global Death %'
FROM [Portfolio project1]..[covid deaths]
where continent is not null
group by date 
order by [Global Death %] desc

---- Joining Deaths and Vaccination table----------------------------------------------------------------------------------

select * from [Portfolio project1]..[covid deaths] as deaths
join [Portfolio project1]..[covid vaccinations] as vaccine on
deaths.continent = vaccine.continent and deaths.date = vaccine.date

---- Looking at total population vs Vaccination----------------------------------------------------------------------------------


select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint))
OVER(Partition by dea.Location Order by dea.location, convert(datetime, dea.date, 103)) as total_vaccinated
from [Portfolio project1]..[covid deaths] as dea
join [Portfolio project1]..[covid vaccinations] as vac
on dea.iso_code = vac.iso_code and dea.date = vac.date
where dea.continent is not null
order by dea.location, convert(datetime, dea.date, 103) -- Had to convert as my date column is a VARCHAR



---- Using CTE for total population vs Vaccination----------------------------------------------------------------------------------

With Pop_vs_Vac(continent,location,date,population,new_vaccinations,total_vaccinated) as
(select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint))
OVER(Partition by dea.Location Order by dea.location, convert(datetime, dea.date, 103)) as total_vaccinated
from [Portfolio project1]..[covid deaths] as dea
join [Portfolio project1]..[covid vaccinations] as vac
on dea.iso_code = vac.iso_code and dea.date = vac.date
where dea.continent is not null
--order by dea.location, convert(datetime, dea.date, 103)
)
select *,(total_vaccinated/cast(population as float)*100) as "% people vaccinated"
from Pop_vs_Vac
