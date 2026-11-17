/* Schema for the COVID-19 vaccination database (SQLite).
   Source data: Our World in Data COVID-19 vaccination dataset.
   Dates are stored as ISO 8601 text (YYYY-MM-DD); missing values are NULL. */

-- Country: one row per country, with the source of its vaccination figures
CREATE TABLE Country
(
iso_code VARCHAR (20) NOT NULL,
name VARCHAR(50),
source_name VARCHAR(100),
source_website VARCHAR(300),
PRIMARY KEY (iso_code)
);

-- Manufacturer: vaccine manufacturers
CREATE TABLE Manufacturer
(
manufacturer_name VARCHAR (100) NOT NULL,
PRIMARY KEY (manufacturer_name)
);

-- CountryVaccination: daily cumulative vaccination figures for each country
CREATE TABLE CountryVaccination
(
iso_code VARCHAR(10) NOT NULL,
date DATE NOT NULL,
total_vaccinations INTEGER (20),
people_vaccinated INTEGER (20), 
people_fully_vaccinated INTEGER (20), 
total_boosters INTEGER (20), 
total_vaccinations_per_hundred FLOAT (20), 
people_vaccinated_per_hundred FLOAT (20), 
people_fully_vaccinated_per_hundred FLOAT (20), 
total_boosters_per_hundred FLOAT (20), 
daily_vaccinations_per_million FLOAT (20), 
daily_people_vaccinated INTEGER (20), 
daily_people_vaccinated_per_hundred FLOAT (20),
PRIMARY KEY (iso_code, date),
FOREIGN KEY (iso_code) REFERENCES Country (iso_code)
);

-- VaccinationByManufacturer: cumulative doses by manufacturer, country and date
CREATE TABLE VaccinationByManufacturer
(
iso_code VARCHAR(20) NOT NULL,
date DATE NOT NULL,
manufacturer_name VARCHAR (100) NOT NULL,
total_vaccinations INTEGER (20),
PRIMARY KEY (iso_code, date, manufacturer_name),
FOREIGN KEY (iso_code) REFERENCES Country (iso_code),
FOREIGN KEY (manufacturer_name) REFERENCES Manufacturer (manufacturer_name) 
);

-- VaccinationByAgeGroup: vaccination coverage by age group, country and date
CREATE TABLE VaccinationByAgeGroup
(
iso_code VARCHAR(20) NOT NULL,
date DATE NOT NULL,
age_group VARCHAR (20) NOT NULL,
people_vaccinated_per_hundred FLOAT (20),
people_fully_vaccinated_per_hundred FLOAT (20),
people_with_boosters_per_hundred FLOAT (20),
PRIMARY KEY (iso_code, date, age_group),
FOREIGN KEY (iso_code) REFERENCES Country (iso_code)
);

-- State: United States states and territories
CREATE TABLE State
(
state VARCHAR (50) NOT NULL,
iso_code VARCHAR (20),
PRIMARY KEY (state),
FOREIGN KEY (iso_code) REFERENCES Country (iso_code)
);

-- VaccinationByUSState: daily cumulative vaccination figures for each US state
CREATE TABLE VaccinationByUSState
(
date DATE NOT NULL,
state VARCHAR(50) NOT NULL,  
total_vaccinations INTEGER (20),
total_distributed INTEGER (20),
people_vaccinated INTEGER (20),
people_fully_vaccinated_per_hundred FLOAT (20),
total_vaccinations_per_hundred FLOAT (20), 
people_fully_vaccinated INTEGER (20),
people_vaccinated_per_hundred FLOAT (20), 
distributed_per_hundred FLOAT (20), 
daily_vaccinations_per_million INTEGER (20),
share_doses_used FLOAT (20), 
total_boosters INTEGER (20),
total_boosters_per_hundred FLOAT (20),
PRIMARY KEY (date, state),
FOREIGN KEY (state) REFERENCES State (state)
);

-- CountryManufacturer: which manufacturers' vaccines each country uses
CREATE TABLE CountryManufacturer
(
iso_code VARCHAR (10) NOT NULL,
manufacturer_name VARCHAR (100) NOT NULL,
PRIMARY KEY (iso_code, manufacturer_name),
FOREIGN KEY (iso_code) REFERENCES Country (iso_code),
FOREIGN KEY (manufacturer_name) REFERENCES Manufacturer (manufacturer_name)
);
