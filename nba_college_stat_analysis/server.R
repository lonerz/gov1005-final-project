library(shiny)
library(cowplot)
library(ggthemes)
library(tidyverse)
library(yardstick)
library(plotly)
library(DT)

# Import the lovely RDS files I created with csv_to_rds.R

college_totals_stats <- read_rds("college_totals_stats.rds")
college_per_game_stats <- read_rds("college_per_game_stats.rds")

nba_per_game_stats <- read_rds("nba_per_game_stats.rds")
nba_per_game_stats_wo_tot <- read_rds("nba_per_game_stats_wo_tot.rds")

nba_total_stats <- read_rds("nba_total_stats.rds")
nba_total_stats_wo_tot <- read_rds("nba_total_stats_wo_tot.rds")

joined_college_stats_nba_position <- read_rds("joined_college_stats_nba_position.rds")
nba_positions <- read_rds("nba_positions.rds")

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
        filter(season >= "1980-81") %>%
        group_by(season) %>%
        summarize(var_avg = mean(get(translate[[input$generalTrend.stat]]), na.rm = TRUE)) %>%
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
        yaxis = list(title = paste("Mean  Total Season", input$generalTrend.stat))
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

  #################
  ### Fun facts ###
  #################

  output$funFacts.diffTeams <- renderDT({

    # We want to compute the number of players that played on the most number of teams in a single
    # season. We remove rows that have TOT as the team_id (these are aggregates). Then we just group by
    # the name/season and count the number of rows. However, Manute Bol has double the number of rows for
    # each season (mistake in the data), so we get rid of this error by dividing by 2.

    nba_total_stats %>%
      filter(team_id != "TOT") %>%
      group_by(slug, season, name) %>%
      summarize(diff_teams = length(unique(team_id))) %>%
      ungroup() %>%
      mutate(diff_teams = ifelse(slug == "bolma01", diff_teams / 2, diff_teams)) %>%
      arrange(desc(diff_teams)) %>%
      head(30) %>%
      select(name, season, diff_teams) %>%
      datatable(
        colnames = c("Name", "Season", "Number of Different Teams"),
        rownames = FALSE,
        options = list(dom = "tp", pageLength = 5)
      )
  })

  output$funFacts.diffPositions <- renderDT({

    # This is super similar to above. We want the number of unique positions one played
    # not in one season, but across all seasons. We also add draft year to differentiate
    # people with the same name.

    nba_positions %>%
      filter(team_id != "TOT") %>%
      group_by(slug, name, draft_year) %>%
      summarize(diff_positions = length(unique(pos))) %>%
      ungroup() %>%
      arrange(desc(diff_positions)) %>%
      head(30) %>%
      select(name, draft_year, diff_positions) %>%
      datatable(
        colnames = c("Name", "Draft Year", "Number of Different Positions"),
        rownames = FALSE,
        options = list(dom = "tp", pageLength = 5)
      )
  })
})
