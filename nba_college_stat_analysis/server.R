library(shiny)
library(cowplot)
library(ggthemes)
library(tidyverse)

college_totals_stats <- read_rds("college_totals_stats.rds")
college_per_game_stats <- read_rds("college_per_game_stats.rds")

nba_per_game_stats <- read_rds("nba_per_game_stats.rds")
nba_per_game_stats_wo_tot <- read_rds("nba_per_game_stats_wo_tot.rds")

nba_total_stats <- read_rds("nba_total_stats.rds")
nba_total_stats_wo_tot <- read_rds("nba_total_stats_wo_tot.rds")

shinyServer(function(input, output) {
  output$generalTrends <- renderPlot({
    college_plot <- college_totals_stats %>%
      group_by(season) %>%
      summarize(var_avg = mean(get(input$stat), na.rm = TRUE)) %>%
      replace_na(replace = list(var_avg = 0)) %>%
      ggplot() +
      geom_point(aes(x = season, y = var_avg)) +
      labs(title = "NCAA") +
      theme_few()

    nba_plot <- nba_total_stats_wo_tot %>%
      group_by(season) %>%
      summarize(var_avg = mean(get(input$stat), na.rm = TRUE)) %>%
      replace_na(replace = list(var_avg = 0)) %>%
      ggplot() +
      geom_point(aes(x = season, y = var_avg)) +
      labs(title = "NBA") +
      theme_few()

    plot_grid(college_plot, nba_plot, nrow = 2, ncol = 1)
  })
})
