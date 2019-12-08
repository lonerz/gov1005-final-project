library(shiny)
library(cowplot)
library(ggthemes)
library(tidyverse)
library(yardstick)
library(plotly)
library(DT)
library(tidymodels)
library(scales)

# Import the lovely RDS files I created with csv_to_rds.R

college_totals_stats <- read_rds("college_totals_stats.rds")
college_per_game_stats <- read_rds("college_per_game_stats.rds")

nba_per_game_stats <- read_rds("nba_per_game_stats.rds")
nba_per_game_stats_wo_tot <- read_rds("nba_per_game_stats_wo_tot.rds")

nba_total_stats <- read_rds("nba_total_stats.rds")
nba_total_stats_wo_tot <- read_rds("nba_total_stats_wo_tot.rds")

joined_college_stats_nba_position <- read_rds("joined_college_stats_nba_position.rds")
nba_positions <- read_rds("nba_positions.rds")

accuracy_df <- read_rds("accuracy_df.rds")
kappa_df <- read_rds("kappa_df.rds")

############################################################################################

shinyServer(function(input, output) {

  ######################
  ### General trends ###
  ######################

  output$generalTrend.statPlot <- renderPlotly({

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
        yaxis = list(title = paste("Average Total Season", input$generalTrend.stat))
      ) %>%
      config(displayModeBar = FALSE)
  })

  colorForPosition <- function(position) {
    # The order: c("Point Guard", "Center", "Shooting Guard", "Power Forward", "Small Forward")
    colors <- c("rgb(141, 160, 203)", "rgb(102, 194, 165)", "rgb(166, 216, 84)", "rgb(252, 141, 98)", "rgb(231, 138, 195)")
    colors[which(positions_english == position)]
  }

  output$generalTrend.positionPlot <- renderPlotly({
    nba_single_position %>%

      # Filter by the specific position chosen by the user

      filter(pos == translate[[input$generalTrend.position]]) %>%

      # Then we group by draft_year (and position if we are plotting everything) and count
      # the number of people who played that position for that draft year

      group_by(pos, draft_year) %>%
      summarize(pos_count = n()) %>%

      # Finally, we plot just like above

      plot_ly(
        x = ~draft_year,
        y = ~pos_count,
        color = ~pos,
        type = "scatter",
        mode = "lines+markers",
        line = list(color = colorForPosition(input$generalTrend.position)),
        marker = list(color = colorForPosition(input$generalTrend.position))
      ) %>%
      layout(
        xaxis = list(title = "Draft Class"),
        yaxis = list(title = paste("Number of ", input$generalTrend.position, "s Drafted", sep = ""))
      ) %>%
      config(displayModeBar = FALSE)
  })


  ######################
  ### Position model ###
  ######################

  # The whole point of this boxplot is to provide a visualization to understand the distribution
  # of the selected player statistic depending on if the player ended up playing that position in
  # the NBA or not. I'll break down the code line-by-line (-ish).

  output$positionModel.plotly <- renderPlotly({
    joined_college_stats_nba_position %>%

      # We don't want players who didn't have that player statistic. Older years, they did
      # not keep track of certain statistics, so we will not penalize players who don't
      # have that statistic by just removing them.

      filter(!is.na(get(translate[[input$positionModel.stat]]))) %>%

      # We create a "Position" and "Not a Position" binary factor. It just compares every player
      # and sees if that player's NBA position is equal to the one selected by the user.

      mutate(pos_binary = ifelse(pos == translate[[input$positionModel.position]],
        input$positionModel.position,
        paste("Not a", input$positionModel.position)
      )) %>%

      # Finally, the plotting. Nothing special here. We want the distribution of the player
      # statistic by the player position, so we set those to the y-axis and x-axis respectively.
      # Color it up and make it into a box plot. The special x-axis layout is to make sure
      # that the boxplot will always show "Not a Position" and then "Position" on the x-axis.

      plot_ly(
        x = ~pos_binary,
        y = ~ get(translate[[input$positionModel.stat]]),
        color = ~pos_binary,
        type = "box"
      ) %>%
      layout(
        title = paste("Distribution of", input$positionModel.stat, "By Player Position"),
        xaxis = list(
          title = "",
          categoryorder = "array",
          categoryarray = c(paste("Not a", input$positionModel.position), input$positionModel.position)
        ),
        yaxis = list(title = input$positionModel.stat)
      ) %>%
      hide_legend() %>%
      config(displayModeBar = FALSE)
  })

  # Visualizing is one thing. We should actually create a model out of this to predict a player's NBA
  # position from their college basketball player statistics. I'll break down the following again
  # line-by-line (-ish).

  output$positionModel.accuracy <- renderDT({

    # We first clean our data (really similarly to above). Take out the players who don't have that
    # specific college player statistic. Then we create a binary factor to represent if the player
    # ended up playing that NBA position or not.

    positions <-
      joined_college_stats_nba_position %>%
      mutate(pos_binary = as.factor(ifelse(pos == translate[[input$positionModel.position]], "1", "0"))) %>%
      filter(!is.na(get(translate[[input$positionModel.stat]])))

    # Then we actually create our logistic regression (fancy for predicting 0s and 1s given an input).
    # We want to explain the NBA position (pos_binary) with the college stat (input$positionModel.stat).

    logistic_reg() %>%
      set_engine("glm") %>%
      fit(pos_binary ~ get(translate[[input$positionModel.stat]]), data = positions) %>%

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
      mutate(.estimate = percent(.estimate, accuracy = 0.01)) %>%
      datatable(
        colnames = c("Metric", "Estimate"),
        rownames = FALSE,
        options = list(
          dom = "t",
          columnDefs = list(list(className = "dt-center", targets = "_all"))
        )
      )
  })
  
  output$positionModel.accuracyTable <- renderDT({
    accuracy_df %>%
      datatable(options = list(dom = "ftp"))
  })

  output$positionModel.kappaTable <- renderDT({
    kappa_df %>%
      datatable(options = list(dom = "ftp"))
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
        options = list(
          dom = "tp",
          pageLength = 5,
          columnDefs = list(list(className = "dt-center", targets = "_all"))
        )
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
        options = list(
          dom = "tp",
          pageLength = 5,
          columnDefs = list(list(className = "dt-center", targets = "_all"))
        )
      )
  })
})
