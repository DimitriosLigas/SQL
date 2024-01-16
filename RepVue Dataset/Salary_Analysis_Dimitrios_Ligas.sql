-- **********************************************************************************************--
-- Examine the trend in the average earnings by year and role
SELECT YEAR(m.RatingEffectiveDate) AS 'Year',
        m.Role, 
        AVG(CAST(HighestPotentialEarningsValue AS FLOAT))AS 'Average Earnings'
FROM RepVue_Salary_Data AS s
INNER JOIN RepVue_Meta_Data AS m
ON s.RepVue_ID = m.RepVue_ID
GROUP BY YEAR(m.RatingEffectiveDate), m.Role
ORDER BY YEAR(m.RatingEffectiveDate), m.Role;

-- It seems that for most of the roles the average yearly earnings are monotonically increasing with the years

-- **********************************************************************************************--
--  Examine the yearly change in the average percentage of quota by company
-- We create a CTE and then join the table on itself to compute the yearly change in the % of quota
-- grouped by company and year
WITH temp_table AS 
(
SELECT m.CompanyName, YEAR(RatingEffectiveDate) AS 'Year',
        AVG(CAST(s.PercentageTeamHittingQuota AS FLOAT)) AS "Avg_Quota"
FROM RepVue_Meta_Data AS m
INNER JOIN RepVue_Salary_Data AS s
ON m.RepVue_ID = s.RepVue_ID
GROUP BY m.CompanyName, YEAR(RatingEffectiveDate)
)

SELECT tt.CompanyName, tt.Year AS 'Year t',
       tt.Avg_Quota AS 'Avg Quota t',
       tt_prev.Year AS 'Year t -1', 
       tt_prev.Avg_Quota AS 'Avg Quota t-1',
       (tt.Avg_Quota / tt_prev.Avg_Quota) - 1 AS 'YOY Perc Quota Change'
FROM temp_table AS tt
INNER JOIN (
    SELECT * 
    FROM temp_table AS tt
) AS tt_prev
ON tt.CompanyName = tt_prev.CompanyName
AND tt.Year = tt_prev.Year + 1
ORDER BY tt.CompanyName;

--*****************************************************************************************************************--
-- In this Query we examine the yearly percentage change in the offers made that included equity grouped by company
-- We also investigate whether there exist any relationship with the yearly percentage change in the reviews at that company
-- We usse the ame CTE created in Query 2

WITH temp_table AS
(
SELECT *, 
CASE -- Transform the categorical variable to int so that we can count the offer with equity
WHEN s.OfferIncludeEquity != 'None' THEN 1
WHEN s.OfferIncludeEquity = 'None' THEN 0
ELSE s.OfferIncludeEquity
END AS OfferIncludeEquity_num
FROM RepVue_Salary_Data AS s
WHERE s.OfferIncludeEquity IS NOT NULL
),

temp_table_2 AS
(
SELECT m.CompanyName, COUNT(m.CompanyName) AS "Number_of_Reviews",
       YEAR(m.RatingEffectiveDate) AS 'Year',
       SUM(tt.OfferIncludeEquity_num) AS 'Number_Offers_Equity'
FROM temp_table AS tt
INNER JOIN RepVue_Meta_Data AS m
ON tt.RepVue_ID = m. RepVue_ID
GROUP BY m.CompanyName, YEAR(m.RatingEffectiveDate)
)

SELECT tt2.CompanyName, 
       tt2.Year AS 'Year_t',
       (CAST(tt2.Number_of_Reviews AS FLOAT) / tt3.Number_of_Reviews) - 1 AS 'Yearly_%_Change_Reviews',
       CASE -- handle possible division with 0
       WHEN tt3.Number_Offers_Equity != 0 THEN (CAST(tt2.Number_Offers_Equity AS FLOAT) / tt3.Number_Offers_Equity) - 1 
       ELSE 0
       END AS 'YOY_%_Change_Equity_Offers'
FROM temp_table_2 AS tt2
INNER JOIN (
    SELECT * 
    FROM temp_table_2 AS tt2
) AS tt3
ON tt2.Year = tt3.Year + 1 AND tt2.CompanyName = tt3.CompanyName
ORDER BY tt2.CompanyName, tt2.Year;

-- It appears that there exists a strong positive association between the yearly change
-- in the % of reviews received and the % change in the offeres made that included equity