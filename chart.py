import duckdb
import matplotlib.pyplot as plt
from pathlib import Path

BASE = Path(__file__).resolve().parent
con = duckdb.connect((BASE / "nfl.duckdb").as_posix())

df = con.sql((BASE / "queries" / "q4_passing_era.sql").read_text()).df()

plt.plot(df["season"], df["epa_per_dropback"], label="EPA per dropback")
plt.plot(df["season"], df["epa_per_rush"], label="EPA per rush")
plt.xlabel("Season")
plt.ylabel("EPA per play")
plt.title("Passing got more efficient, rushing didn't")
plt.legend()
plt.savefig(BASE / "passing_era.png")
