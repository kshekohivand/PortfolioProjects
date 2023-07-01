SELECT *
FROM `PortfolioProject.covid_deaths_deduped`
ORDER BY 3,4;

-- Data selection for intended use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `PortfolioProject.covid_deaths_deduped`
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths and the likelihood of dying if you contract Covid-19 in your country. Here is France for example

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM `PortfolioProject.covid_deaths_deduped`
WHERE location like '%France%'
ORDER BY 1,2;

-- When did we observe the highest death percentage in France due to Covid-19 ?

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM `PortfolioProject.covid_deaths_deduped`
WHERE location like '%France%'
ORDER BY death_percentage DESC
LIMIT 1;

-- Looking at Total cases vs Population and the percentage of population infected by Covid-19

SELECT location, date, total_cases, population, (total_cases/population)*100 as infected_population_percentage
FROM `PortfolioProject.covid_deaths_deduped`
WHERE location like '%France%'
ORDER BY 1,2;

-- Retrieving when we observed the maximum percentage of people who contracted Covid-19

SELECT location, date, total_cases, population, (total_cases/population)*100 as infected_population_percentage
FROM `PortfolioProject.covid_deaths_deduped`
WHERE location like '%France%'
ORDER BY infected_population_percentage DESC
LIMIT 1;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as highest_infection_count, max(total_cases/population)*100 as infected_population_percentage
FROM `PortfolioProject.covid_deaths_deduped`
GROUP BY location, population
ORDER BY infected_population_percentage desc;

-- Showing countries with highest death count per population

SELECT location, MAX(total_deaths) as total_deaths_count
FROM `PortfolioProject.covid_deaths_deduped`
WHERE continent is not null
GROUP BY location
ORDER BY total_deaths_count desc;

-- Let's break things down by continent

-- Showing continents with the highest death count per population

SELECT continent, MAX(total_deaths) as total_deaths_count
FROM `PortfolioProject.covid_deaths_deduped`
WHERE continent is not null
GROUP BY continent
ORDER BY total_deaths_count desc;



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
FROM `PortfolioProject.covid_deaths_deduped`
WHERE continent is not null
ORDER BY 1,2;


-- I forgot to mention that I had to previously clean the covid_deaths table before querying. Here, we identify whether the covid_vaccications table contains duplicates. Fortunately, it does not

SELECT
  (SELECT count(1) FROM (SELECT DISTINCT * FROM `PortfolioProject.covid_vaccinations`)) as distinct_rows,
  (SELECT count(1) FROM `PortfolioProject.covid_vaccinations`) as total_rows;


-- Let's join these two tables together on location and date

SELECT *
FROM `PortfolioProject.covid_deaths_deduped` dea
JOIN `PortfolioProject.covid_vaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date;

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, SUM(dea.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated, 
-- (rolling_people_vaccinated/population)*100
FROM `PortfolioProject.covid_deaths_deduped` dea
JOIN `PortfolioProject.covid_vaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- USE CTE

WITH pop_vs_vac AS (
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    dea.new_vaccinations,
    SUM(dea.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
  FROM `PortfolioProject.covid_deaths_deduped` dea
  JOIN `PortfolioProject.covid_vaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM pop_vs_vac;


-- TEMP TABLE


CREATE TEMPORARY TABLE percent_population_vaccinated (
  continent STRING,
  location STRING,
  date DATE,
  population NUMERIC,
  new_vaccinations NUMERIC,
  rolling_people_vaccinated NUMERIC
);

INSERT INTO percent_population_vaccinated
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  dea.new_vaccinations,
  SUM(dea.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM `PortfolioProject.covid_deaths_deduped` dea
JOIN `PortfolioProject.covid_vaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (rolling_people_vaccinated/population)*100
FROM percent_population_vaccinated;



-- Creating view to store data for later visualizations

CREATE VIEW PortfolioProject.percent_population_vaccinated AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  dea.new_vaccinations,
  SUM(dea.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM `PortfolioProject.covid_deaths_deduped` dea
JOIN `PortfolioProject.covid_vaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM `PortfolioProject.percent_population_vaccinated`
