--What is the Primary_Key that is shared between the 3 RepVue tables?
--Primary Keys need to be NOT NULL and are UNIQUE
--We are treating each review as a unique entry

/* The Primary Unique Key is the 'RepVue_ID' Feature' */

--Working with the Meta_Data

--Question #1
--What are the CompanyNames and CompanyIDs that do not have tickers?
--We need to create tickers if possible to get earnings, return, sales data, ect
--Please take a look at the 8 companies we do not have tickers for and think about how we can handle this

SELECT DISTINCT CompanyName
FROM RepVue_Meta_Data
WHERE Ticker IS NULL;

--Question #2
--How many Users (UserHash) leave multiple reviews?
SELECT COUNT(multiple_user) AS 'users_with_multiple_reviews'
FROM (
    SELECT UserHash AS 'multiple_user', COUNT(UserHash) AS 'user_counts'
    FROM RepVue_Meta_Data
    GROUP BY UserHash
    HAVING COUNT(UserHash) > 1
 ) AS subquery ;


--Order the table so the user with the most reviews are at the top
SELECT UserHash, COUNT(UserHash) AS 'Reviews_Count'
FROM RepVue_Meta_Data
GROUP BY UserHash
HAVING COUNT(UserHash) > 1
ORDER BY COUNT(UserHash) DESC;


--Question #3
--Which companies have the most reviews?

SELECT TOP 10 CompanyName, COUNT(DISTINCT UserHash) AS 'Unique_Reviews'
FROM RepVue_Meta_Data
GROUP BY CompanyName
ORDER BY Unique_Reviews DESC; 


--Question #4
--Which companies have the lowest average RepVueScore

SELECT TOP 10 CompanyName, AVG(RepVueScore) AS 'average_score'
FROM RepVue_Meta_Data
GROUP BY CompanyName
ORDER BY average_score ASC;

--Question #5
--Install the SandDance for Azure Data Studio Exention
--Create a scatter plot from the below query


--Working with the Meta_Data and Salary_Data

--Question #6
--Select * and INNER JOIN the primary keys on the Meta_Data and Salary_Data tables
--be sure to create aliases for the tables

SELECT *
FROM RepVue_Meta_Data AS M
INNER JOIN RepVue_Salary_Data AS S
ON M.RepVue_ID = S.RepVue_ID;


--Question #6
--Using the above join, select only the rows with RepVue_Meta_Data.RatingVerifiedStatus='Verified'

SELECT *
FROM RepVue_Meta_Data AS M
INNER JOIN RepVue_Salary_Data AS S
ON M.RepVue_ID = S.RepVue_ID
WHERE M.RatingVerifiedStatus = 'Verified';


--Question #7
--Does Tenure length have an impact on the average earnings AVG(OTEValue)?
--What about on the MIN(), MAX()?
--We need to use two different table to get this 
--Think about how should we handle the values that look too low?

SELECT CASE
    WHEN Tenure = 'Less than 1 year' THEN 1
    WHEN Tenure = '1 to 2 years' THEN 2
    WHEN Tenure = '2 to 3 years' THEN 3
    WHEN Tenure = 'More than 3 years' THEN 4
    END AS 'Numeric_Tenure',
AVG(OTEValue) AS 'average_ote',
MIN(OTEValue) AS 'min_ote',
MAX(OTEValue) AS 'max_ote'
FROM RepVue_Meta_Data AS M
INNER JOIN RepVue_Salary_Data AS S
ON M.RepVue_ID = S.RepVue_ID
WHERE Tenure IS NOT NULL
GROUP BY Tenure
ORDER BY average_ote;

/*Cleasrly there is a positive linear relationship between the Tenure length and the Average earning 

The relationship for the Minimum Earnings is also positive, but does not look linear.
Lastly, the relationship for the Maximum Earnings is not clear. */

SELECT Tenure, MIN(OTEValue), MAX(OTEValue)
FROM RepVue_Meta_Data as M
INNER JOIN RepVue_Salary_Data AS S
ON M.RepVue_ID = S.RepVue_ID
WHERE Tenure IS NOT NULL
GROUP BY Tenure;

--Question #8
--Update one of the first two queries in 'Session_3/Class.sql'
--Please change the columns that we are looking at and perform another simple calculation that makes sense
--Add a comment beside your calc with a simple explenation
--First Two Queries you can choose from are:
----Incentive Compensation Rating vs Contract Structure Screenshot 
----Create a scatter plot to show earnings ratio to leads/market_fit

--Query Chosen: Incentive Compensation Rating vs Contract Structure Screenshot
SELECT SAL.OTEValue - SAL.BaseCompValue AS 'Implied_Comp'
-- Below we display the ration of the Incentive Compensation over the Base compentation--
    , CAST(SENT.IncentiveCompensation AS numeric) / CAST(SENT.BaseComp AS numeric) AS 'incentive_comp_over_base'
FROM RepVue_Salary_Data AS SAL
INNER JOIN RepVue_Sentiment_Data AS SENT
ON SAL.RepVue_ID=SENT.RepVue_ID
WHERE SAL.BaseCompValue > 0 AND SAL.OTEValue > 0 AND SENT.BaseComp != 0 AND SENT.BaseComp IS NOT NULL;

