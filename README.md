# OWID-Covid-DataExploration-and-DataVisualization
Performing Data Exploration and Data Visualization  on OWID-Covid Dataset


## Dataset

Download the updated OWID-COVID Dataset from [here](https://ourworldindata.org/covid-deaths)

i downloaded the data updated to March 28, 2022
I divided the dataset into 2 excel files, one for death related data and next for vaccination related data.
 


## Data Exploration using Microsoft Server Management Studio

Create a new database and import the excel files into 2 tables.
I explored the data by looking at the data as a whole, as well as looking at data based on different continents, sorting by highest average infection and death rates and more.

### For example:

showing countries with highest death count per population
```sql

Select location,max(cast(total_deaths as int)) as TotalDeathCount, max(population) as Population, 
 Max((cast(total_deaths as int)/population))*100 as Death_rate
From OWID-Database..CovidDeaths$
where continent is not null
Group by location, population
Order by Death_rate desc
```

## Data Visualization in Tableau 

First, Connect tableau desktop to Microsoft SQL Server. i have created 2 dashboards (deaths, health) and attached it onto a story.

[Click here](https://public.tableau.com/app/profile/saurav.adhikari2682/viz/OWID-CovidDeathDataVisualization/CovidDeaths) to see the Covid-Death Dashboards



