library(readr)

college_totals_stats <- read_csv("final_csv/college_totals_stats.csv")
college_per_game_stats <- read_csv("final_csv/college_per_game_stats.csv")

nba_per_game_stats <- read_csv("final_csv/nba_per_game_stats.csv")
nba_per_game_stats_wo_tot <- read_csv("final_csv/nba_per_game_stats_wo_tot.csv")

nba_total_stats <- read_csv("final_csv/nba_total_stats.csv")
nba_total_stats_wo_tot <- read_csv("final_csv/nba_total_stats_wo_tot.csv")

write_rds(college_totals_stats, "nba_college_stat_analysis/college_totals_stats.rds")
write_rds(college_per_game_stats, "nba_college_stat_analysis/college_per_game_stats.rds")
write_rds(nba_per_game_stats, "nba_college_stat_analysis/nba_per_game_stats.rds")
write_rds(nba_per_game_stats_wo_tot, "nba_college_stat_analysis/nba_per_game_stats_wo_tot.rds")
write_rds(nba_total_stats, "nba_college_stat_analysis/nba_total_stats.rds")
write_rds(nba_total_stats_wo_tot, "nba_college_stat_analysis/nba_total_stats_wo_tot.rds")

## do some more work for joined NBA positions and college stat table

nba_single_position <- read_csv("final_csv/nba_single_position.csv")
write_rds(nba_single_position, "nba_college_stat_analysis/nba_single_position.rds")

stats_per_g <- c(
  "g", "gs", "mp_per_g", "fg_per_g", "fga_per_g", "fg_pct", "fg2_per_g", "fg2a_per_g",
  "fg2_pct", "fg3_per_g", "fg3a_per_g", "fg3_pct", "ft_per_g", "fta_per_g", "ft_pct",
  "orb_per_g", "drb_per_g", "trb_per_g", "ast_per_g", "stl_per_g", "blk_per_g", "tov_per_g",
  "pf_per_g", "pts_per_g"
)

# Compute the average per_game stats for each player. So group by the slug (unique identifier)
# for each player and then use summarise_all to summarize all the columns

average_college_per_game_stats <- college_per_game_stats %>%
  select(-name, -college_slug, -season, -school_name, -conf_abbr) %>%
  group_by(slug) %>%
  summarise_all(partial(mean, na.rm = TRUE))

# Join the college stats with NBA positions based on slug (unique indentifier)

joined_college_stats_nba_position <- average_college_per_game_stats %>%
  left_join(nba_single_position, by = "slug") %>%
  filter(!is.na(pos))

write_rds(joined_college_stats_nba_position, "nba_college_stat_analysis/joined_college_stats_nba_position.rds")

nba_positions <- read_csv("final_csv/nba_positions.csv")
write_rds(nba_positions, "nba_college_stat_analysis/nba_positions.rds")
