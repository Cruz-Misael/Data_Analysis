
--1 Select all columns for customers who are part of the Joel team.
SELECT * FROM dados
WHERE team_name = '[ADV] Time Joel'



--2 Find all active wallets and sort them by total_position in descending order.
SELECT * FROM dados
WHERE status = 'TRUE'
ORDER BY posicao_total DESC



--3 Only select client id, team and total position for clients with a tier of '+1MM'.
SELECT client_id, team_name, posicao_total FROM dados
WHERE tier = '+1MM'



--4 Calculate the total position_total for each team.
SELECT team_name, SUM(posicao_total) AS sum_posicao_total from dados
GROUP BY team_name



--5 Select the client_id and team_name for clients whose total_position is above the total_position average.
SELECT client_id, team_name FROM [IgnitionOEE].[dbo].[dados]
WHERE posicao_total < (SELECT AVG(posicao_total) FROM [IgnitionOEE].[dbo].[dados])



--6 Select all customers who are registered in April 2024.
SELECT client_id FROM dados
WHERE MONTH(date) = 4 AND YEAR(DATE) = 2024



--7 Select all customers who have registered in the last 2 months. The last 2 months need to be flexible and 'pace' with time.
SELECT * FROM dados
WHERE date >= DATEADD(MONTH, -2, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)) AND date <= EOMONTH(GETDATE())
ORDER BY date DESC



--8 Using a CTE, calculate the difference between total_position and quota_position for each customer, and then filter the results to show only those with a difference greater than 100,000.
WITH ClientDifference AS (
    SELECT client_id, posicao_total, posicao_cotizado, (posicao_total - posicao_cotizado) AS diferenca
    FROM dados
)
SELECT client_id, posicao_total, posicao_cotizado, diferenca
FROM ClientDifference
WHERE diferenca > 100000;



--9 Sort the customers within each team_name based on their total_position from highest to lowest. Tip: use the RANK function.
WITH ClientClassification AS (
    SELECT client_id, team_name, posicao_total,
           RANK() OVER (PARTITION BY team_name ORDER BY posicao_total DESC) AS ranking
    FROM dados
)
SELECT client_id, team_name, posicao_total, ranking
FROM ClientClassification
ORDER BY team_name, ranking;



--10 Using multiple CTEs, first calculate the total position for each team_name, then find the team with the maximum total position.
WITH PositionByTeam AS (
    SELECT team_name, SUM(posicao_total) AS posicao_total_equipe
    FROM dados
    GROUP BY team_name
),
MaximumTeam AS (
    SELECT team_name, posicao_total_equipe,
           RANK() OVER (ORDER BY posicao_total_equipe DESC) AS ranking
    FROM PositionByTeam
)
SELECT team_name, posicao_total_equipe
FROM MaximumTeam
WHERE ranking = 1;


