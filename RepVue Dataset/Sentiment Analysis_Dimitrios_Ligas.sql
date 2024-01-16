
--**********************************************************************************************--
-- Query 1: Examine whether there exists a trend in the average professional development ratings
-- grouped by roles and year.

SELECT m.Role, 
YEAR(m.RatingEffectiveDate) AS 'Year',
AVG(CAST(S.ProfessionalDevelopment AS FLOAT)) AS 'Avg_Professional_Development'
FROM RepVue_Sentiment_Data AS s
INNER JOIN RepVue_Meta_Data AS m
ON s.RepVue_ID = m.RepVue_ID
GROUP BY m.Role, YEAR(m.RatingEffectiveDate)
ORDER BY m.Role, YEAR(m.RatingEffectiveDate);

-- Interestingly, for most roles there seems to exist a negative trend 
--in the average professional development ratings.

--**********************************************************************************************--
-- Query 2: Examine the yearly change in the average professional development ratings 
-- by US & Non-US countries. To do so, we create a CTE and merge on itself.

WITH temp_table AS 
(
SELECT m.Country, 
       AVG(CAST(s.ProfessionalDevelopment AS float)) AS 'Avg_Professional_Development',
       YEAR(m.RatingEffectiveDate) AS 'Year'
FROM RepVue_Sentiment_Data AS s
INNER JOIN RepVue_Meta_Data AS m
ON s.RepVue_ID = m.RepVue_ID
GROUP BY m.Country, YEAR(m.RatingEffectiveDate)
)

SELECT tt.Country,
       tt.Year AS 'Year_t',
       tt.Avg_Professional_Development AS 'Avg_Development_t',
       tt2.Avg_Professional_Development AS 'Avg_Development_t-1',
       (tt.Avg_Professional_Development / tt2.Avg_Professional_Development - 1) AS 'Yearly_Perc_Change_Prof_Dev'
FROM temp_table AS tt
INNER JOIN (
    SELECT *
    FROM temp_table AS tt
) AS tt2
ON tt.Country = tt2.Country AND tt.[Year] = tt2.[Year] + 1
ORDER BY tt.Country, tt.Year;

-- The trend in the yearly % change in the average professional development ratings 
--looks similar for both US and Non-US countries. 

--**********************************************************************************************************--
-- Query 3: Examine whether there exists a relationship between the yearly change in the average development
-- ratings and the yearly change in the average culture and leadership ratings, grouped by country.
-- We use the same CTE created in query 2.

WITH temp_table AS 
(
SELECT m.Country, 
       AVG(CAST(s.CultureandLeadership AS FLOAT)) AS 'Avg_Culture_Leadership',
       AVG(CAST(s.ProfessionalDevelopment AS float)) AS 'Avg_Professional_Development',
       YEAR(m.RatingEffectiveDate) AS 'Year'
FROM RepVue_Sentiment_Data AS s
INNER JOIN RepVue_Meta_Data AS m
ON s.RepVue_ID = m.RepVue_ID
GROUP BY m.Country, YEAR(m.RatingEffectiveDate)
)

SELECT tt.Country,
       tt.Year AS 'Year_t',
       (tt.Avg_Professional_Development / tt2.Avg_Professional_Development - 1) AS 'Yearly_Perc_Change_Prof_Dev',
       (tt.Avg_Culture_Leadership / tt2.Avg_Culture_Leadership - 1) AS 'Yearly_Perc_Change_Cultue_Leadership'
FROM temp_table AS tt
INNER JOIN (
    SELECT *
    FROM temp_table AS tt
) AS tt2
ON tt.Country = tt2.Country AND tt.[Year] = tt2.[Year] + 1
ORDER BY tt.Country, tt.Year;

-- There seems to exist a positive association between the yearly % change of the average 
-- professional development ratings and the yearly % change of the average culture/leadership ratings.



