library(shiny)
library(cowplot)
library(ggthemes)
library(tidyverse)
library(yardstick)
library(plotly)

# Import the lovely RDS files I created with csv_to_rds.R

college_totals_stats <- read_rds("college_totals_stats.rds")
college_per_game_stats <- read_rds("college_per_game_stats.rds")

nba_per_game_stats <- read_rds("nba_per_game_stats.rds")
nba_per_game_stats_wo_tot <- read_rds("nba_per_game_stats_wo_tot.rds")

nba_total_stats <- read_rds("nba_total_stats.rds")
nba_total_stats_wo_tot <- read_rds("nba_total_stats_wo_tot.rds")

joined_college_stats_nba_position <- read_rds("joined_college_stats_nba_position.rds")

############################################################################################

shinyServer(function(input, output) {

  ######################
  ### General trends ###
  ######################

  output$generalTrend.plot <- renderPlotly({

    # Given total stats from NBA or NCAA, we can compute the mean total for the specific statistic
    # input$generalTrend.stat for each player who played by season. We replace NAs with 0 because
    # our data is taken so that if there's an empty field is usually just 0

    average_total_stats <- function(total_stats) {
      total_stats %>%
        group_by(season) %>%
        summarize(var_avg = mean(get(input$generalTrend.stat), na.rm = TRUE)) %>%
        replace_na(replace = list(var_avg = 0))
    }
    
    # Now, let us plot NBA and NCAA line trends on the same graph. Binding rows allows us to get
    # everything in one tibble and then plotly allows us to do the rest pretty easily.

    bind_rows(
      "NCAA" = average_total_stats(college_totals_stats),
      "NBA" = average_total_stats(nba_total_stats_wo_tot), .id = "league"
    ) %>%
      group_by(league) %>%
      plot_ly(x = ~season, y = ~var_avg, color = ~league, type = "scatter", mode = "lines+markers") %>%
      layout(
        xaxis = list(title = "Season"),
        yaxis = list(title = paste("Average Player", input$generalTrend.stat, ""))
      ) %>%
      config(displayModeBar = FALSE)
  })

  ######################
  ### Position model ###
  ######################

  positionModel.positions <- reactive({
    joined_college_stats_nba_position %>%
      mutate(pos_binary = as.factor(ifelse(pos == input$positionModel.position, "1", "0"))) %>%
      filter(!is.na(get(input$positionModel.stat)))
  })

  output$positionModel.plot <- renderPlot({
    ggplot(positionModel.positions(), aes(x = pos_binary, y = get(input$positionModel.stat))) +
      geom_boxplot()
  })

  output$positionModel.accuracy <- renderTable({
    model <- glm(data = positionModel.positions(), formula = pos_binary ~ get(input$positionModel.stat), family = "binomial")

    pred <- positionModel.positions() %>%
      mutate(prediction = predict(model, type = "response")) %>%
      mutate(pred_binary = as.factor(ifelse(prediction > mean(prediction), "1", "0")))

    metrics(pred, pos_binary, pred_binary)
  })
})
