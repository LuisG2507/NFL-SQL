import duckdb
from pathlib import Path

BASE = Path(__file__).resolve().parent
DATA = (BASE / "data").as_posix()
con = duckdb.connect((BASE / "nfl.duckdb").as_posix())

con.sql(f"CREATE OR REPLACE TABLE games AS FROM read_parquet('{DATA}/games.parquet')")
con.sql(f"CREATE OR REPLACE TABLE draft_picks AS FROM read_csv('{DATA}/draft_picks.csv')")
con.sql(f"CREATE OR REPLACE TABLE pbp AS FROM read_parquet('{DATA}/play_by_play_*.parquet')")

result = con.sql((BASE / "queries" / "q1_wins_by_decade.sql").read_text())
result.show()