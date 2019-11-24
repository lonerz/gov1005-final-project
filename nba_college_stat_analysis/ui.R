library(shiny)
library(shinythemes)
library(markdown)

stats <- c(
  "g", "gs", "mp", "fg", "fga", "fg_pct", "fg2", "fg2a", "fg2_pct", "fg3", "fg3a",
  "fg3_pct", "ft", "fta", "ft_pct", "orb", "drb", "trb", "ast", "stl", "blk", "tov", "pf", "pts"
)

stats_per_g <- c(
  "g", "gs", "mp_per_g", "fg_per_g", "fga_per_g", "fg_pct", "fg2_per_g", "fg2a_per_g",
  "fg2_pct", "fg3_per_g", "fg3a_per_g", "fg3_pct", "ft_per_g", "fta_per_g", "ft_pct",
  "orb_per_g", "drb_per_g", "trb_per_g", "ast_per_g", "stl_per_g", "blk_per_g", "tov_per_g",
  "pf_per_g", "pts_per_g"
)

positions <- c("C", "SG", "PF", "PG", "SF")

generalTrends <- tabPanel(
  "General Trends",
  tabsetPanel(
    tabPanel(
      "Trends by Season",
      h3("What are some trends for the NBA and NCAA over seasons?"),

      # Get statistic name to plot general trend

      sidebarPanel(
        selectInput(
          inputId = "generalTrend.stat",
          label = "Statistic:",
          choices = stats,
          selected = "fg3"
        )
      ),

      # Plot the general trend for selected statistic

      mainPanel(
        plotOutput("generalTrend.plot"),
        br(),
        p("Notice a large dip in many statistics during the NBA season 1998-1999. This was because of the 1999 NBA lockout. You can read more about it here: https://en.wikipedia.org/wiki/1998%E2%80%9399_NBA_season.")
      )
    )
  )
)

positionModel <- tabPanel(
  "NBA Position Model",
  tabsetPanel(
    tabPanel(
      "Try it Yourself!",
      h3("Can we predict a player's NBA position from one of their statistics?"),

      # Get statistic name and position of player

      sidebarPanel(
        selectInput(
          inputId = "positionModel.position",
          label = "Position:",
          choices = positions,
          selected = "C"
        ),
        selectInput(
          inputId = "positionModel.stat",
          label = "Statistic:",
          choices = stats_per_g,
          selected = "blk_per_g"
        )
      ),

      # Plot the boxplot for the position vs. stat

      mainPanel(
        plotOutput("positionModel.plot"),
        tableOutput("positionModel.accuracy")
      )
    ),
    tabPanel(
      "General Findings"
    )
  )
)

shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  # shinythemes::themeSelector(),
  br(),
  navbarPage(
    "Dunk on Some Stats",
    generalTrends,
    positionModel,
    tabPanel(
      "Fun Facts!"
    ),
    tabPanel(
      "About",
      includeMarkdown("about.md")
    )
  )
))
