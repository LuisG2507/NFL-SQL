-- Q2: Do early draft picks buy wins?
-- There is no free NFL salary dataset, so draft capital is the stand-in:
-- for each team-season, count top-100 picks from the previous 3 drafts,
-- then correlate that with regular-season wins.
-- Data: nflverse draft_picks (1980+) + games (schedules), 2000-2026.
-- Note: draft_picks uses old PFR-style team codes (GNB, KAN, NWE, ...),
-- so we map them to the modern codes used in the games table.

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
    SELECT team, season, SUM(win_equiv) AS wins
    FROM team_games
    GROUP BY team, season
),
draft_cap AS (
    SELECT
        CASE team
            WHEN 'GNB' THEN 'GB'  WHEN 'KAN' THEN 'KC'
            WHEN 'NWE' THEN 'NE'  WHEN 'NOR' THEN 'NO'
            WHEN 'SFO' THEN 'SF'  WHEN 'TAM' THEN 'TB'
            WHEN 'SDG' THEN 'LAC'
            WHEN 'RAM' THEN 'LA'  WHEN 'STL' THEN 'LA' WHEN 'LAR' THEN 'LA'
            WHEN 'RAI' THEN 'LV'  WHEN 'OAK' THEN 'LV' WHEN 'LVR' THEN 'LV'
            WHEN 'PHO' THEN 'ARI'
            ELSE team
        END AS team,
        season AS draft_season,
        COUNT(*) AS top100_picks
    FROM draft_picks
    WHERE pick <= 100
    GROUP BY 1, 2
),
with_capital AS (
    SELECT
        ts.team,
        ts.season,
        ts.wins,
        COALESCE(SUM(dc.top100_picks) OVER (
            PARTITION BY ts.team
            ORDER BY ts.season
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ), 0) AS top100_last3
    FROM team_season ts
    LEFT JOIN draft_cap dc
        ON dc.team = ts.team AND dc.draft_season = ts.season
)
SELECT
    ROUND(CORR(top100_last3, wins), 3) AS correlation,
    COUNT(*) AS team_seasons,
    ROUND(AVG(CASE WHEN top100_last3 >= 9 THEN wins END), 2) AS avg_wins_high_capital,
    ROUND(AVG(CASE WHEN top100_last3 <= 4 THEN wins END), 2) AS avg_wins_low_capital
FROM with_capital;
