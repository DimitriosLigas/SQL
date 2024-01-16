--*****************************************************************************************************--
SELECT m.Role, AVG(CAST(s.HighestPotentialEarningsValue AS FLOAT)) AS 'Avg_Earnings',
       MIN(CAST(s.HighestPotentialEarningsValue AS FLOAT)) AS 'Min_Earnings', 
       MAX(CAST(s.HighestPotentialEarningsValue AS FLOAT)) AS 'Max_Earnings'
FROM RepVue_Salary_Data AS s
INNER JOIN RepVue_Meta_Data AS m
ON s.RepVue_ID = m.RepVue_ID
GROUP BY m.Role;


--********************************************************************************************************--
-- I would like to get the Cummulative_Sales for WDAY, update the below so we only get the results for WDAY
-- Why is this a left join?
-- Cumulative Sum 1
SELECT q.tic, q.datadate, q.saleq, SUM(q.saleq) AS Cummulative_Sales
FROM wrds_fundamentals_quarterly AS q
LEFT JOIN wrds_fundamentals_quarterly AS  q_cum ON q.tic = q_cum.tic 
AND q_cum.datadate <= q.datadate
WHERE q.tic = 'WDAY'
GROUP BY q.tic, q.datadate, q.saleq
ORDER BY q.tic, q.datadate;

-- Cumulative Sum 2
SELECT q.tic , q.datadate, q.saleq,
SUM(q.saleq) OVER(ORDER BY q.datadate) AS 'Cumulative Salse'
FROM wrds_fundamentals_quarterly AS q;



--********************************************************************************************************--
-- Count the number of reviews by Division for WorkDay
-- This can all be done the RepVue_Meta_Data table
SELECT COUNT(RepVue_ID) AS 'Number_of_Reviews', Division
FROM RepVue_Meta_Data
WHERE Ticker = 'WDAY' AND Division IS NOT NULL
GROUP BY Division;


-- Create a temporary table for the above query that counted the number of reviews by Division for WorkDay
-- This was the temporary table I created
-- I LEFT JOIN'ed the temp_table on its self so that the value is null if there are less than 5 reviews

WITH temporary_table AS (
                        SELECT CompanyName, Division, COUNT(RepVue_ID) AS 'Number_Reviews'
                        FROM WolfPackMasterDB..RepVue_Meta_Data
                        WHERE CompanyName='Workday' AND Division IS NOT NULL
                        GROUP BY CompanyName, Division
                        )
SELECT *
FROM temporary_table t 
    LEFT JOIN temporary_table t2 ON t.CompanyName=t2.CompanyName 
                                    AND t.Division=t2.Division 
                                    AND t2.Number_Reviews > 5;




-- Update this join to an INNER JOIN
-- How does this change the results?
WITH temp_table AS
(
SELECT COUNT(RepVue_ID) AS 'Number_of_Reviews', Division
FROM RepVue_Meta_Data
WHERE Ticker = 'WDAY' AND Division IS NOT NULL
GROUP BY Division
)

SELECT *
FROM temp_table AS tt
INNER JOIN (
    SELECT *
    FROM temp_table AS tt
) AS tt2
ON tt.Division = tt2.Division
WHERE tt.Number_of_Reviews > 5
ORDER BY tt.Number_of_Reviews;



