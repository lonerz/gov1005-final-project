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
