# This is where all the global variables go. We need a mapping from
# what the column names are in our CSVs to a more understandable
# set of names. So, this is what the dictionary translate does.

library(dict)
library(purrr)

stats <- c(
  "g", "gs", "mp", "fg", "fga", "fg_pct", "fg2", "fg2a", "fg2_pct", "fg3", "fg3a",
  "fg3_pct", "ft", "fta", "ft_pct", "orb", "drb", "trb", "ast", "stl", "blk", "tov", "pf", "pts"
)

stats_english <- c(
  "Games", "Games Started", "Minutes Played", "Field Goals", "Field Goal Attempts",
  "Field Goal Percentage", "2-Point Field Goals", "2-Point Field Goal Attempts", "2-Point Field Goal Percentage",
  "3-Point Field Goals", "3-Point Field Goal Attempts", "3-Point Field Goal Percentage",
  "Free Throws", "Free Throw Attempts", "Free Throw Percentage", "Offensive Rebounds", "Defensive Rebounds",
  "Total Rebounds", "Assists", "Steals", "Blocks", "Turnovers", "Personal Fouls", "Points")

stats_per_g <- c(
  "g", "gs", "mp_per_g", "fg_per_g", "fga_per_g", "fg_pct", "fg2_per_g", "fg2a_per_g",
  "fg2_pct", "fg3_per_g", "fg3a_per_g", "fg3_pct", "ft_per_g", "fta_per_g", "ft_pct",
  "orb_per_g", "drb_per_g", "trb_per_g", "ast_per_g", "stl_per_g", "blk_per_g", "tov_per_g",
  "pf_per_g", "pts_per_g"
)

stats_per_g_english <- c("Games", "Games Started", map_chr(stats_english[3:24], ~paste(.x, "Per Game")))

positions <- c("C", "SG", "PF", "PG", "SF")

positions_english <- c("Center", "Shooting Guard", "Power Forward", "Point Guard", "Small Forward")

translate <- dict(
  init_keys = c(stats_english, positions_english, stats_per_g_english),
  init_values = c(stats, positions, stats_per_g)
)


