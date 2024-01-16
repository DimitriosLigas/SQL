-- SELECT * 
-- FROM wrds_fundamentals_quarterly AS A
-- INNER JOIN Quarter_Mapping AS B
-- ON A.datafqtr = B.Current_Quarter



DECLARE @tic VARCHAR(250) = 'CRM';
SELECT F.tic, M.Next_Quarter, F_next.saleq
FROM wrds_fundamentals_quarterly AS F
INNER JOIN Quarter_Mapping AS M 
ON M.Current_Quarter = F.datafqtr
INNER JOIN wrds_fundamentals_quarterly AS F_next 
ON F_next.tic = f.tic AND F_next.datafqtr = M.Next_Quarter
WHERE F.tic = @tic;