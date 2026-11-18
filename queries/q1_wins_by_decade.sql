-- Q1: Which franchise won the most regular-season games in each decade?
-- Data: nflverse games (schedules), 2000-2026. Ties count as half a win.
-- Note: team codes change when franchises relocate (STL->LA, SD->LAC, OAK->LV),
-- so we map them to one canonical code per franchise first.
-- Note: the 2020s only cover 2020-2026, so compare ranks within each decade, not raw totals.

WITH team_games AS (
    SELECT
        season,
        CASE away_team
            WHEN 'STL' THEN 'LA'
            WHEN 'SD'  THEN 'LAC'
            WHEN 'OAK' THEN 'LV'
            ELSE away_team
        END AS team,
        CASE
            WHEN away_score > home_score THEN 1.0
            WHEN away_score = home_score THEN 0.5
            ELSE 0.0
        END AS win_equiv
    FROM games
    WHERE game_type = 'REG' AND season >= 2000

    UNION ALL

    SELECT
        season,
        CASE home_team
            WHEN 'STL' THEN 'LA'
            WHEN 'SD'  THEN 'LAC'
            WHEN 'OAK' THEN 'LV'
            ELSE home_team
        END AS team,
        CASE
            WHEN home_score > away_score THEN 1.0
            WHEN home_score = away_score THEN 0.5
            ELSE 0.0
        END AS win_equiv
    FROM games
    WHERE game_type = 'REG' AND season >= 2000
),
by_decade AS (
    SELECT
        team,
        (season // 10) * 10 AS decade,
        SUM(win_equiv) AS decade_wins
    FROM team_games
    GROUP BY team, decade
)
SELECT
    decade,
    team,
    decade_wins,
    RANK() OVER (PARTITION BY decade ORDER BY decade_wins DESC) AS decade_rank
FROM by_decade
ORDER BY decade, decade_rank;
