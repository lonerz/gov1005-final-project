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
        p("The graph shows the average/mean of player season totals for the selected player statistic over every season from 1980."),
        p("For example, the mean season total 3-point field goals over all players is increasing each season quite dramatically. The 3-point shot has really evolved in basketball over the last 30 years. Just look at Steph Curry!")
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
      h3("Can we predict a player's NBA position from one of their college player statistics?"),
      br(),

      # Get statistic name and position of player

      sidebarPanel(
        selectInput(
          inputId = "positionModel.position",
          label = "NBA Position To Predict:",
          choices = positions_english,
          selected = "Center"
        ),
        selectInput(
          inputId = "positionModel.stat",
          label = "College Player Statistic:",
          choices = stats_per_g_english,
          selected = "Blocks Per Game"
        ),
        p("The boxplot shows the distribution of the selected college player statistic depending on if that player ended up playing the selected NBA position or not. This can give you a good sense if your model is going to do well or not."),
        p("For example, for college player statistic 'Blocks Per Game', it seems like players that ended up playing Center in the NBA had relatively higher number of blocks than a non-Center player. This makes sense because Centers are usually tallest and thus block more people!")
      ),

      # Plot the boxplot for the position vs. stat

      mainPanel(
        plotlyOutput("positionModel.plotly"),
        h4("How good is the model?"),
        p("Data visualization aside, I created a practical model that takes as input the player's college player statistic (like Blocks Per Game) and predicts if that player played a certain NBA position (like Center)."),
        p("To see if a model is good (accurate), we can calculate its performance in two ways. One is ", tags$b("accuracy", .noWS = "outside"), ": what percentage of players did the model predict their NBA positions correctly? And the other is", tags$b("Kappa"), "(kap for short): how much better is our model than a model that just randomly guesses?"),
        DTOutput("positionModel.accuracy"),
        br(),
        h6("*I used a logistic regression to predict player's NBA position from a player's college player statistic. You can read more about the Kappa coefficient metric ", a("here", href = "https://en.wikipedia.org/wiki/Cohen%27s_kappa", .noWS = "outside"), ".")
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
