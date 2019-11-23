library(shiny)
library(shinythemes)
library(markdown)

stats <- c("g", "gs", "mp", "fg", "fga", "fg_pct", "fg2", "fg2a", "fg2_pct", "fg3", "fg3a",
           "fg3_pct", "ft", "fta", "ft_pct", "orb", "drb", "trb", "ast", "stl", "blk", "tov", "pf", "pts")

generalTrends <- tabPanel(
  "General Trends",
  tabsetPanel(
    tabPanel(
      "Trends by Season",
      h3("What are some trends for the NBA and NCAA over seasons?"),

      # Get statistic name to plot general trend
      sidebarPanel(
        selectInput(
          inputId = "stat",
          label = "Statistic:",
          choices = stats,
          selected = "fg3"
        )
      ),

      # Plot the general trend for selected statistic
      mainPanel(
        plotOutput("generalTrends")
      )
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
    tabPanel(
      "NBA Position Model"
    ),
    tabPanel(
      "Fun Facts!"
    ),
    tabPanel(
      "About",
      includeMarkdown("about.md")
    )
  )
))
