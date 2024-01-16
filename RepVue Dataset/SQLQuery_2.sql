--Join the ARK_Holdings on the tickers
SELECT *
FROM ARK_Holdings 
INNER JOIN ARK_Tickers
ON ARK_Holdings.ticker = ARK_Tickers.ticker;

--INNER JOIN WITH ALIASING--
SELECT *
FROM ARK_Holdings AS H
INNER JOIN ARK_Tickers AS T
ON H.ticker = T.ticker;




--Select all the distinct sectors and fund combinations 
SELECT DISTINCT sector, fund
FROM ARK_Holdings AS H
INNER JOIN 
ARK_Tickers AS T
ON H.ticker = T.ticker;


--Order the above by fund
SELECT DISTINCT sector, fund
FROM ARK_Holdings AS H
INNER JOIN 
ARK_Tickers AS T
ON H.ticker = T.ticker
ORDER BY fund ASC;


--Which tickers do not have the sector field populated?
SELECT COUNT(H.ticker)
FROM ARK_Holdings AS H
INNER JOIN ARK_Tickers AS T
ON H.ticker = T.ticker
WHERE sector IS NULL;

--Alternatively--
SELECT ticker
FROM ARK_Tickers
WHERE sector IS NULL;


--Which sectors are present in each fund?  
SELECT DISTINCT H.fund, sector
FROM ARK_Holdings AS H
INNER JOIN ARK_Tickers AS T
ON H.ticker = T.ticker
ORDER BY H.fund ASC;


--Use ISNULL() to populate the null values with 'Not_Identified'
 SELECT DISTINCT H.fund, ISNULL(T.sector, 'Not_Identified') AS sector
 FROM ARK_Holdings AS H
 INNER JOIN ARK_Tickers AS T
 ON H.ticker = T.ticker;


--Count the number of observations on the ARK_Holdings table for each fund and country
SELECT T.country AS country, H.fund, COUNT(H.ticker) AS 'Total Observations'
FROM ARK_Holdings AS H
INNER JOIN ARK_Tickers AS T
ON H.ticker = T.ticker
GROUP BY H.fund, T.country
ORDER BY country ASC;


--Add a column that shows the total observations for the fund
SELECT fund, COUNT(ticker) AS 'Total_Observations'
FROM ARK_Holdings
GROUP BY fund
ORDER BY Total_Observations DESC;




--Cast the COUNT() field as FLOAT and divide the two to get a percentage of each funds observations by country
-- We do this by writing a SubQuery(Nested Query) to calculate the total number of observations for each fund 
-- and then join this information with the original query

--General Syntax for Subqueries--
/*
SELECT column1, column2, ...
FROM table_name
WHERE column_name OPERATOR (SELECT column_name FROM table_name WHERE condition) AS subquery;
*/

SELECT T.country AS country, 
                    H.fund, 
                    CAST(Sub.Total_Fund_Count AS FLOAT) AS 'Total_Fund Count',
                    CAST(COUNT(H.ticker) AS FLOAT) AS 'Fund_Count',
                    CAST(COUNT(H.ticker) AS FLOAT) / Total_Fund_Count AS 'Country_Count_Percentage'
FROM ARK_Holdings AS H
INNER JOIN ARK_Tickers AS T
ON H.ticker = T.ticker
INNER JOIN (
    SELECT H2.fund, COUNT(H2.ticker) AS 'Total_Fund_Count'
    FROM ARK_Holdings AS H2
    GROUP BY H2.fund) AS Sub
ON Sub.fund = H.fund
GROUP BY H.fund, T.country, Sub.Total_Fund_Count
ORDER BY country ASC;


