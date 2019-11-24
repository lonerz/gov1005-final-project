######################################################################
## This is my scratchwork and how I came up with many of my ideas.  ##
## It is not perfect and all over the place because that is how my  ##
## brain works! I also didn't care to comment anything because      ##
## if I used it in the app, I commented it there. Enjoy!            ##
######################################################################

library(readr)
library(cowplot)
library(tidyverse)

college_totals_stats <- read_csv("final_csv/college_totals_stats.csv")
college_per_game_stats <- read_csv("final_csv/college_per_game_stats.csv")

nba_per_game_stats <- read_csv("final_csv/nba_per_game_stats.csv")
nba_per_game_stats_wo_tot <- read_csv("final_csv/nba_per_game_stats_wo_tot.csv")

nba_total_stats <- read_csv("final_csv/nba_total_stats.csv")
nba_total_stats_wo_tot <- read_csv("final_csv/nba_total_stats_wo_tot.csv")

nba_positions <- read_csv("final_csv/nba_positions.csv")
nba_single_position <- read_csv("final_csv/nba_single_position.csv")

# https://stats.idre.ucla.edu/r/codefragments/looping_strings/
# https://www.r-bloggers.com/applying-an-operation-to-a-list-of-variables/

############################################
##############  General trends stuff ######
############################################

# college

# [1] "name"         "slug"         "college_slug" "draft_year"   "draft_pick"   "season"      
# [7] "school_name"  "conf_abbr"    "g"            "gs"           "mp"           "fg"          
# [13] "fga"          "fg_pct"       "fg2"          "fg2a"         "fg2_pct"      "fg3"         
# [19] "fg3a"         "fg3_pct"      "ft"           "fta"          "ft_pct"       "orb"         
# [25] "drb"          "trb"          "ast"          "stl"          "blk"          "tov"         
# [31] "pf"           "pts"  

# nba

#  [1] "name"       "slug"       "draft_year" "draft_pick" "season"     "age"        "team_id"   
# [8] "lg_id"      "pos"        "g"          "gs"         "mp"         "fg"         "fga"       
# [15] "fg_pct"     "fg3"        "fg3a"       "fg3_pct"    "fg2"        "fg2a"       "fg2_pct"   
# [22] "efg_pct"    "ft"         "fta"        "ft_pct"     "orb"        "drb"        "trb"       
# [29] "ast"        "stl"        "blk"        "tov"        "pf"         "pts" 


# g, gs, mp, fg, fga, fg_pct, fg2, fg2a, fg2_pct, fg3, fg3a, fg3_pct,
# ft, fta, ft_pct, orb, drb, trb, ast, stl, blk, tov, pf, pts

var = "pts"

a <- college_totals_stats %>%
  group_by(season) %>%
  summarize(var_avg = mean(get(var), na.rm = TRUE)) %>%
  replace_na(replace = list(var_avg = 0)) %>%
  ggplot() +
  geom_point(aes(x = season, y = var_avg))

b <- nba_total_stats_wo_tot %>%
  group_by(season) %>%
  summarize(var_avg = mean(get(var), na.rm = TRUE)) %>%
  replace_na(replace = list(var_avg = 0)) %>%
  ggplot() +
  geom_point(aes(x = season, y = var_avg))

plot_grid(a, b, nrow = 2, ncol = 1)

##########################################################
################ Tryna do some modelling #################
##########################################################

stats_per_g <- c("g", "gs", "mp_per_g", "fg_per_g", "fga_per_g", "fg_pct", "fg2_per_g", "fg2a_per_g", "fg2_pct", "fg3_per_g", "fg3a_per_g",
           "fg3_pct", "ft_per_g", "fta_per_g", "ft_pct", "orb_per_g", "drb_per_g", "trb_per_g", "ast_per_g", "stl_per_g", "blk_per_g", "tov_per_g", "pf_per_g", "pts_per_g")

average_college_per_game_stats <- college_per_game_stats %>%
  select(-name, -college_slug, -season, -school_name, -conf_abbr) %>%
  group_by(slug) %>%
  summarise_all(partial(mean, na.rm = TRUE))

joined_college_stats_nba_position <- average_college_per_game_stats %>%
  left_join(nba_single_position, by = "slug") %>%
  filter(!is.na(pos))

## Try for center position first

library(yardstick)

pos_char = "C"
stat = "blk_per_g"

position <- joined_college_stats_nba_position %>%
  mutate(pos_binary = as.factor(ifelse(pos == pos_char, "1", "0"))) %>%
  filter(!is.na(get(stat)))

ggplot(position, aes(x = pos_binary, y = get(stat))) +
  geom_boxplot()

model <- glm(data = position, formula = pos_binary ~ get(stat), family = "binomial")

pred <- position %>%
  mutate(prediction = predict(model, type = "response")) %>%
  mutate(pred_binary = as.factor(ifelse(prediction > mean(prediction), "1", "0")))

metrics(pred, pos_binary, pred_binary)

###############################################
################ Fun factssss #################
###############################################






