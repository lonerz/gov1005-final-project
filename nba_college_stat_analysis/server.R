library(shiny)
library(cowplot)
library(ggthemes)
library(tidyverse)
library(yardstick)

college_totals_stats <- read_rds("college_totals_stats.rds")
college_per_game_stats <- read_rds("college_per_game_stats.rds")

nba_per_game_stats <- read_rds("nba_per_game_stats.rds")
nba_per_game_stats_wo_tot <- read_rds("nba_per_game_stats_wo_tot.rds")

nba_total_stats <- read_rds("nba_total_stats.rds")
nba_total_stats_wo_tot <- read_rds("nba_total_stats_wo_tot.rds")

joined_college_stats_nba_position <- read_rds("joined_college_stats_nba_position.rds")

shinyServer(function(input, output) {

  ######################
  ### General trends ###
  ######################

  output$generalTrend.plot <- renderPlot({
    college_plot <- college_totals_stats %>%
      group_by(season) %>%
      summarize(var_avg = mean(get(input$generalTrend.stat), na.rm = TRUE)) %>%
      replace_na(replace = list(var_avg = 0)) %>%
      ggplot() +
      geom_point(aes(x = season, y = var_avg)) +
      labs(title = "NCAA") +
      theme_few()

    nba_plot <- nba_total_stats_wo_tot %>%
      group_by(season) %>%
      summarize(var_avg = mean(get(input$generalTrend.stat), na.rm = TRUE)) %>%
      replace_na(replace = list(var_avg = 0)) %>%
      ggplot() +
      geom_point(aes(x = season, y = var_avg)) +
      labs(title = "NBA") +
      theme_few()

    plot_grid(college_plot, nba_plot, nrow = 2, ncol = 1)
  })

  ##########################
  ### Position modelling ###
  ##########################

  positionModel.positions <- reactive({
    cat("computing positions\n")

    joined_college_stats_nba_position %>%
      mutate(pos_binary = as.factor(ifelse(pos == input$positionModel.position, "1", "0"))) %>%
      filter(!is.na(get(input$positionModel.stat)))
  })

  output$positionModel.plot <- renderPlot({
    cat("try rendering?\n")

    ggplot(positionModel.positions(), aes(x = pos_binary, y = get(input$positionModel.stat))) +
      geom_boxplot()
  })
  
  output$positionModel.accuracy <- renderTable({
    cat("accuracy?\n")

    model <- glm(data = positionModel.positions(), formula = pos_binary ~ get(input$positionModel.stat), family = "binomial")
    
    pred <- positionModel.positions() %>%
      mutate(prediction = predict(model, type = "response")) %>%
      mutate(pred_binary = as.factor(ifelse(prediction > mean(prediction), "1", "0")))
    
    metrics(pred, pos_binary, pred_binary)
  })
})
