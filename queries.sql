/* Report queries for the COVID-19 vaccination database (SQLite 3.25 or later).

   Vaccination figures are cumulative running totals reported on irregular
   dates, so monthly figures use the last value each country reported in
   that month, not a sum or an arbitrary day. */


-- Query 1: cumulative doses administered per country at the end of two months
-- (August and September 2021), and the difference between them.
-- Countries that did not report a total in both months are excluded.
WITH MonthEnd AS (
    SELECT iso_code,
           strftime('%Y-%m', date) AS month,
           total_vaccinations,
           ROW_NUMBER() OVER (PARTITION BY iso_code, strftime('%Y-%m', date)
                              ORDER BY date DESC) AS rn
    FROM CountryVaccination
    WHERE total_vaccinations IS NOT NULL
)
SELECT m1.month              AS "Observation Month 1 (OM1)",
       c.name                AS "Country Name (CN)",
       m1.total_vaccinations AS "Administered Vaccines on OM1 (VOM1)",
       m2.month              AS "Observation Month 2 (OM2)",
       m2.total_vaccinations AS "Administered Vaccines on OM2 (VOM2)",
       m1.total_vaccinations - m2.total_vaccinations AS "Difference of totals (VOM1 - VOM2)"
FROM MonthEnd m1
JOIN MonthEnd m2 ON m2.iso_code = m1.iso_code
                AND m2.month = '2021-09'
                AND m2.rn = 1
JOIN Country c ON c.iso_code = m1.iso_code
WHERE m1.month = '2021-08'
  AND m1.rn = 1
ORDER BY c.name;


-- Query 2: countries whose cumulative doses at the end of a month were above
-- the average for that month, across all countries reporting in that month.
WITH MonthEnd AS (
    SELECT iso_code,
           strftime('%Y-%m', date) AS month,
           total_vaccinations,
           ROW_NUMBER() OVER (PARTITION BY iso_code, strftime('%Y-%m', date)
                              ORDER BY date DESC) AS rn
    FROM CountryVaccination
    WHERE total_vaccinations IS NOT NULL
),
LastInMonth AS (
    SELECT iso_code, month, total_vaccinations
    FROM MonthEnd
    WHERE rn = 1
),
MonthlyAverage AS (
    SELECT month, AVG(total_vaccinations) AS avg_total
    FROM LastInMonth
    GROUP BY month
)
SELECT c.name               AS "Country Name",
       l.month              AS "Month",
       l.total_vaccinations AS "Cumulative Doses"
FROM LastInMonth l
JOIN MonthlyAverage a ON a.month = l.month
JOIN Country c ON c.iso_code = l.iso_code
WHERE l.total_vaccinations > a.avg_total
ORDER BY l.month, l.total_vaccinations DESC;


-- Query 3: vaccine manufacturers and the countries using each.
SELECT cm.manufacturer_name AS "Vaccine Type",
       c.name               AS "Country"
FROM CountryManufacturer cm
JOIN Country c ON c.iso_code = cm.iso_code
ORDER BY cm.manufacturer_name, c.name;


-- Query 4: total doses administered per country (latest reported total),
-- with the data source for each, largest first.
WITH Latest AS (
    SELECT iso_code,
           total_vaccinations,
           ROW_NUMBER() OVER (PARTITION BY iso_code ORDER BY date DESC) AS rn
    FROM CountryVaccination
    WHERE total_vaccinations IS NOT NULL
)
SELECT c.name               AS "Country Name",
       c.source_website     AS "Source Name (URL)",
       l.total_vaccinations AS "Total Administered Vaccines"
FROM Latest l
JOIN Country c ON c.iso_code = l.iso_code
WHERE l.rn = 1
ORDER BY l.total_vaccinations DESC;


-- Query 5: people fully vaccinated at the end of each month in 2022 and 2023,
-- for the United States, Wales, Canada and Denmark.
-- A blank cell means the country reported no figure that month.
WITH MonthEnd AS (
    SELECT iso_code,
           strftime('%Y-%m', date) AS month,
           people_fully_vaccinated,
           ROW_NUMBER() OVER (PARTITION BY iso_code, strftime('%Y-%m', date)
                              ORDER BY date DESC) AS rn
    FROM CountryVaccination
    WHERE people_fully_vaccinated IS NOT NULL
      AND iso_code IN ('USA', 'OWID_WLS', 'CAN', 'DNK')
      AND date BETWEEN '2022-01-01' AND '2023-12-31'
)
SELECT month AS "Date Range (Months)",
       MAX(CASE WHEN iso_code = 'USA'      THEN people_fully_vaccinated END) AS "United States",
       MAX(CASE WHEN iso_code = 'OWID_WLS' THEN people_fully_vaccinated END) AS "Wales",
       MAX(CASE WHEN iso_code = 'CAN'      THEN people_fully_vaccinated END) AS "Canada",
       MAX(CASE WHEN iso_code = 'DNK'      THEN people_fully_vaccinated END) AS "Denmark"
FROM MonthEnd
WHERE rn = 1
GROUP BY month
ORDER BY month;
