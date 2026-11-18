-- Q3b: The Rams' rolling 5-season regular-season win percentage, 2000-2026.
-- Same team_games logic as q3_franchise_win_pct.sql; split out so each
-- question stays one file, one idea.

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
SELECT
    season,
    ROUND(SUM(wins) OVER w / SUM(games) OVER w, 3) AS rolling_5yr_win_pct
FROM team_season
WHERE team = 'LA'
WINDOW w AS (ORDER BY season ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
ORDER BY season;
