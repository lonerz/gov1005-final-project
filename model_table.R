# This file is used to create the modelling table found in General findings
# Most of the functions are taken directly from server.R
# If you are going to run this, make sure to have all variables from server.R and global.R

# This is the model code directly from server.R. Read the comments there to see how this works.

get_model_results <- function(position, stat)
{
  positions <-
    joined_college_stats_nba_position %>%
    mutate(pos_binary = as.factor(ifelse(pos == translate[[position]], "1", "0"))) %>%
    filter(!is.na(get(translate[[stat]])))
  
  logistic_reg() %>%
    set_engine("glm") %>%
    fit(pos_binary ~ get(translate[[stat]]), data = positions) %>%
    predict(new_data = positions, type = "prob") %>%
    mutate(pred_binary = as.factor(ifelse(.pred_1 > mean(.pred_1), "1", "0"))) %>%
    bind_cols(positions) %>%
    metrics(truth = pos_binary, estimate = pred_binary) %>%
    select(.metric, .estimate) %>%
    mutate(.estimate = 100 * .estimate)
}

# Make a table lol, just defines a table with column names and row names and initializes
# everything to "0%"

init_table <- function() {
  m = matrix(rep(0, length(positions_english) * length(stats_per_g_english)), ncol = length(positions_english))
  colnames(m) <- positions_english
  rownames(m) <- stats_per_g_english
  as.table(m)
}

accuracy_table <- init_table()
kappa_table <- init_table()

# We then run our model 120 times and pull out the estimate for each metric

for (position in positions_english) {
  for (stat in stats_per_g_english) {
    results <- get_model_results(position, stat)
    accuracy_table[stat, position] <- round(results %>% filter(.metric == "accuracy") %>% pluck(".estimate"), digits = 2)
    kappa_table[stat, position] <- round(results %>% filter(.metric == "kap") %>% pluck(".estimate"), digits = 2)
  }
}

# We spread the values by the Position they play to create a 2-way table

accuracy_df <- as_tibble(accuracy_table, .name_repair = "unique") %>%
  spread(key = ...2, value = n) %>%
  rename("College Statistic" = ...1)

kappa_df <- as_tibble(kappa_table, .name_repair = "unique") %>%
  spread(key = ...2, value = n) %>%
  rename("College Statistic" = ...1)

# Write the values to disk so we don't need to run this code more than once
# and so our shiny app can use it!

write_rds(accuracy_df, "nba_college_stat_analysis/accuracy_df.rds")
write_rds(kappa_df, "nba_college_stat_analysis/kappa_df.rds")
