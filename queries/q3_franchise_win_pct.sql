-- Q3: All-time franchise regular-season win percentage (2000-2026),
-- plus the Rams' rolling 5-season win percentage over time.
-- Data: nflverse games (schedules). Ties count as half a win.

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
team_season AS (
    SELECT team, season, SUM(win_equiv) AS wins, COUNT(*) AS games
    FROM team_games
    GROUP BY team, season
)

-- Part A: all-time franchise win percentage
SELECT
    team,
    ROUND(SUM(wins) / SUM(games), 3) AS win_pct,
    CAST(SUM(wins) AS INTEGER) AS wins,
    SUM(games) AS games
FROM team_season
GROUP BY team
ORDER BY win_pct DESC;
