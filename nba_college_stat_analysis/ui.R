library(shiny)
library(shinythemes)
library(markdown)
library(plotly)
library(DT)

######################
### General trends ###
######################

generalTrends <- tabPanel(
  "General Trends",
  tabsetPanel(
    tabPanel(
      "Player Statistics by Season",
      h3("What are some player statistics trends over seasons?"),
      br(),

      # Get statistic name to plot general trend

      sidebarPanel(
        selectInput(
          inputId = "generalTrend.stat",
          label = "Player Statistic:",
          choices = stats_english,
          selected = "3-Point Field Goals"
        ),
        h5("The graph shows the average/mean of player season totals for the selected player statistic over every season from 1980."),
        h5("For example, the mean season total 3-point field goals over all players is increasing each season quite dramatically. The 3-point shot has really evolved in basketball over the last 30 years. Just look at Steph Curry!")
      ),

      # Plot the general trend for selected statistic

      mainPanel(
        plotlyOutput("generalTrend.plot", height = "500px"),
        br(),

        # Nasty syntax here because of link: https://stackoverflow.com/questions/39132318/shiny-nesting-a-link-within-a-paragraph-has-unwanted-whitespace

        h6(
          "*Notice a large dip in many statistics during the NBA season 1998-1999. This was the ",
          a(href = "https://en.wikipedia.org/wiki/1998%E2%80%9399_NBA_season", "1999 NBA lockout", .noWS = "outside"),
          "."
        )
      )
    )
  )
)

######################
### Position model ###
######################

positionModel <- tabPanel(
  "NBA Position Model",
  tabsetPanel(
    tabPanel(
      "Try it Yourself!",
      h3("Can we predict a player's NBA position from one of their college statistics?"),

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
          label = "College Statistic:",
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

######################
### Fun facts ###
######################

funFacts <- tabPanel(
  "Fun Facts!",
  br(),
  p("Here are some fun facts that I encountered while playing around with this dataset!"),
  h2("Ooooh, Pick Me, Pick Me! 🙋"),
  p("The only player to be drafted 'twice' into the NBA was ", a(href = "https://en.wikipedia.org/wiki/Manute_Bol#Early_basketball_career", "Manute Bol", .noWS = "outside"), "."),
  h2("The Nomad.. 🚶"),
  p("The following players played on the most number of different teams in one single season:"),
  DTOutput("funFacts.diffTeams"),
  h2("The One Man Team 💪"),
  p("The following players played the most number of different positions in their career:"),
  DTOutput("funFacts.diffPositions")
)

shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  # shinythemes::themeSelector(),
  br(),
  navbarPage(
    "Dunk on Some Stats",
    tabPanel(
      "Introduction",
      includeMarkdown("about.md")
    ),
    generalTrends,
    positionModel,
    funFacts
  )
))
