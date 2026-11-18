-- Q4: The passing era -- has the NFL really become a passing league?
-- League-wide pass rate and EPA (expected points added) per dropback vs per rush,
-- by season, from nflverse play-by-play data.
-- epa_per_dropback vs epa_per_rush shows *why* teams pass more: it works better.

SELECT
    season,
    COUNT(*) AS scrimmage_plays,
    ROUND(AVG(CASE WHEN pass_attempt = 1 THEN 1.0 ELSE 0.0 END), 3) AS pass_rate,
    ROUND(AVG(CASE WHEN pass_attempt = 1 THEN epa END), 3) AS epa_per_dropback,
    ROUND(AVG(CASE WHEN rush_attempt = 1 THEN epa END), 3) AS epa_per_rush
FROM pbp
WHERE pass_attempt = 1 OR rush_attempt = 1
GROUP BY season
ORDER BY season;
