######################################################################
## This is my scratchwork and how I came up with many of my ideas.  ##
## It is not perfect and all over the place because that is how my  ##
## brain works! I also didn't care to comment anything because      ##
## if I used it in the app, I commented it there. Enjoy!            ##
######################################################################

library(readr)
library(cowplot)
library(tidyverse)
library(plotly)
library(tidymodels)

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

var <- "pts"

a <- college_totals_stats %>%
  group_by(season) %>%
  summarize(var_avg = mean(get(input$generalTrend.stat), na.rm = TRUE)) %>%
  ungroup() %>%
  replace_na(replace = list(var_avg = 0)) %>%
  ggplot(aes(x = season, y = var_avg, group = 1)) +
  geom_point() +
  geom_line(alpha = 0.5) +
  labs(
    title = "NCAA",
    x = "Season",
    y = paste("Average", input$generalTrend.stat)
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle = 60, hjust = 1),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 15)
  )

b <- nba_total_stats_wo_tot %>%
  group_by(season) %>%
  summarize(var_avg = mean(get(input$generalTrend.stat), na.rm = TRUE)) %>%
  replace_na(replace = list(var_avg = 0)) %>%
  ungroup() %>%
  ggplot(aes(x = season, y = var_avg, group = 1)) +
  geom_point() +
  geom_line(alpha = 0.5) +
  labs(
    title = "NBA",
    x = "Season",
    y = paste("Average", input$generalTrend.stat)
  ) +
  theme_classic() +
  theme(
    axis.text.x = element_text(angle = 60, hjust = 1),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 15)
  )

plot_grid(a, b, nrow = 2, ncol = 1)

test1 <- college_totals_stats %>%
  group_by(season) %>%
  summarize(var_avg = mean(get(var), na.rm = TRUE)) %>%
  replace_na(replace = list(var_avg = 0))

test2 <- nba_total_stats_wo_tot %>%
  group_by(season) %>%
  summarize(var_avg = mean(get(var), na.rm = TRUE)) %>%
  replace_na(replace = list(var_avg = 0))

positions_by_draft_year <- nba_single_position %>%
  group_by(pos, draft_year) %>%
  summarize(pos_count = n()) %>%
  group_by(pos) %>%
  plot_ly(x = ~draft_year, y = ~pos_count, color = ~pos, type = "scatter", mode = "lines+markers")

##########################################################
################ Tryna do some modelling #################
##########################################################

stats_per_g <- c(
  "g", "gs", "mp_per_g", "fg_per_g", "fga_per_g", "fg_pct", "fg2_per_g", "fg2a_per_g", "fg2_pct", "fg3_per_g", "fg3a_per_g",
  "fg3_pct", "ft_per_g", "fta_per_g", "ft_pct", "orb_per_g", "drb_per_g", "trb_per_g", "ast_per_g", "stl_per_g", "blk_per_g", "tov_per_g", "pf_per_g", "pts_per_g"
)

average_college_per_game_stats <- college_per_game_stats %>%
  select(-name, -college_slug, -season, -school_name, -conf_abbr) %>%
  group_by(slug) %>%
  summarise_all(partial(mean, na.rm = TRUE))

joined_college_stats_nba_position <- average_college_per_game_stats %>%
  left_join(nba_single_position, by = "slug") %>%
  filter(!is.na(pos))

## Try for center position first

library(yardstick)

pos_char <- "C"
stat <- "blk_per_g"

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


model1 <- logistic_reg() %>%
  set_engine("glm") %>%
  fit(pos_binary ~ get(stat), data = position)

pred1 <- model1 %>%
  predict(new_data = position, type = "class") %>%
  bind_cols(position)

metrics(pred1, pos_binary, .pred_class)


stats_per_g <- c(
  "g", "gs", "mp_per_g", "fg_per_g", "fga_per_g", "fg_pct", "fg2_per_g", "fg2a_per_g",
  "fg2_pct", "fg3_per_g", "fg3a_per_g", "fg3_pct", "ft_per_g", "fta_per_g", "ft_pct",
  "orb_per_g", "drb_per_g", "trb_per_g", "ast_per_g", "stl_per_g", "blk_per_g", "tov_per_g",
  "pf_per_g", "pts_per_g"
)

positions <- c("PG", "C", "SG", "PF", "SF")

get_model_results <- function(position, stat)
{
  positions <-
    joined_college_stats_nba_position %>%
    mutate(pos_binary = as.factor(ifelse(pos == translate[[position]], "1", "0"))) %>%
    filter(!is.na(get(translate[[stat]])))
  
  logistic_reg() %>%
    set_engine("glm") %>%
    fit(pos_binary ~ get(translate[[stat]]), data = positions) %>%
    
    # Then, we actually use the model we created to predict our original values. The reason
    # why I use probability instead of the built-in prediction is that I don't need to be 50% certain
    # that a player played a certain position in the NBA. I just need to be MORE certain that that
    # player played a certain position over others. That is why I use probability and compare that
    # probability to the mean of all probabilities: mean(.pred1)
    
    predict(new_data = positions, type = "prob") %>%
    mutate(pred_binary = as.factor(ifelse(.pred_1 > mean(.pred_1), "1", "0"))) %>%
    bind_cols(positions) %>%
    
    # Finally, we use the metrics function to compute accuracy and kappa metrics. And display them
    # as percentages, so they are easier to understand in a nice datatable.
    
    metrics(truth = pos_binary, estimate = pred_binary) %>%
    select(.metric, .estimate) %>%
    mutate(.estimate = percent(.estimate, accuracy = 0.01))
}

# Make a table lol

init_table <- function() {
  m = matrix(rep("0%", length(positions_english) * length(stats_per_g_english)), ncol = length(positions_english))
  colnames(m) <- positions_english
  rownames(m) <- stats_per_g_english
  as.table(m)
}

accuracy_table <- init_table()
kappa_table <- init_table()

for (position in positions_english) {
  for (stat in stats_per_g_english) {
    results <- get_model_results(position, stat)
    accuracy_table[stat, position] <- results %>% filter(.metric == "accuracy") %>% pluck(".estimate")
    kappa_table[stat, position] <- results %>% filter(.metric == "kap") %>% pluck(".estimate")
  }
}

accuracy_df <- as_tibble(accuracy_table, .name_repair = "unique") %>%
  spread(key = ...2, value = n)

###############################################
################ Fun factssss #################
###############################################

# Drafted twice

nba_total_stats_wo_tot %>%
  group_by(slug) %>%
  mutate(unique_draft_years = length(unique(draft_year))) %>%
  arrange(desc(unique_draft_years)) %>%
  head(1) %>%
  pluck("name")

# most teams in one season

nba_total_stats %>%
  group_by(slug, season, name) %>%
  summarize(diff_teams = n()) %>%
  ungroup() %>%
  mutate(diff_teams = ifelse(slug == "bolma01", diff_teams / 2, diff_teams) - 1) %>%
  arrange(desc(diff_teams))

# most number of positions

nba_positions %>%
  filter(team_id != "TOT") %>%
  group_by(slug, name) %>%
  summarize(diff_positions = length(unique(pos))) %>%
  ungroup() %>%
  arrange(desc(diff_positions))
