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
        p(
          "For example, the mean season total 3-point field goals over all players is increasing each season quite dramatically.",
          "The 3-point shot has really evolved in basketball over the last 30 years. Just look at Steph Curry!"
        )
      ),

      # Plot the general trend for selected statistic

      mainPanel(
        plotlyOutput("generalTrend.statPlot", height = "500px"),
        br(),

        # Nasty syntax here because of link: https://stackoverflow.com/questions/39132318/shiny-nesting-a-link-within-a-paragraph-has-unwanted-whitespace

        h6(
          "*Notice a large dip in many statistics during the NBA season 1998-1999. This was the ",
          a(href = "https://en.wikipedia.org/wiki/1998%E2%80%9399_NBA_season", "1999 NBA lockout", .noWS = "outside"),
          "."
        )
      )
    ),
    tabPanel(
      "Player Position by Season",
      h3("How many players of each position are drafted each year?"),
      br(),
      
      # Get the player position to plot
      
      sidebarPanel(
        selectInput(
          inputId = "generalTrend.position",
          label = "Player Position:",
          choices = positions_english,
          selected = "Point Guard"
        ),
        p("The graph shows the number of players that got drafted as the selected position over every draft season from 1980."),
        p("There are no obvious trends here, except that Shooting Guards have recently become more popular whereas Small Forwards are on the decline.")
      ),
      
      # Plot the trend for selected player position
      
      mainPanel(
        plotlyOutput("generalTrend.positionPlot", height = "400px"),
        br()
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
        p(
          "The boxplot shows the distribution of the selected college player statistic depending on if that player ended up playing the selected NBA position or not.",
          "This can give you a good sense if your model is going to do well or not."
        ),
        p(
          "For example, for college player statistic 'Blocks Per Game', it seems like players that ended up playing Center in the NBA had relatively higher number of blocks than a non-Center player.",
          "This makes sense because Centers are usually tallest and thus block more people!"
        )
      ),

      # Plot the boxplot for the position vs. stat

      mainPanel(
        plotlyOutput("positionModel.plotly", height = "300px"),
        h4("How good is the model?"),
        p("Data visualization aside, I created a practical model that takes as input the player's college player statistic (like Blocks Per Game) and predicts if that player played a certain NBA position (like Center)."),
        p(
          "To see if a model is good (accurate), we can calculate its performance in two ways.",
          "One is ", strong("accuracy", .noWS = "outside"), ": what percentage of players did the model predict their NBA positions correctly?",
          "And the other is", strong("Kappa"), "(kap for short): how much better is our model than a model that just randomly guesses?"
        ),
        DTOutput("positionModel.accuracy"),
        br(),
        h6(
          "*I used a logistic regression to predict player's NBA position from a player's college player statistic.",
          "You can read more about the Kappa coefficient metric ", a("here", href = "https://en.wikipedia.org/wiki/Cohen%27s_kappa", .noWS = "outside"), "."
        )
      )
    ),
    tabPanel(
      "General Findings",
      br(),
      p("These tables give the accuracy and kappa metric for every possible combination of position and college statistic for modeling, where the row names are the explanatory variable and the column names are the dependent variables. Some notable results about my model:"),
      tags$ul(
        tags$li(
          "For point guards, one of the best ways to predict if someone is going to become a point guard in the NBA is to look at their assists per game college statistic.",
          "This makes sense because as the person who handles the ball, the point guard is usually the one pass to the shooter or the center."
        ),
        tags$li(
          "For centers, one of the better explanatory variables is blocks per game and 3-Point Field Goal Percentage Per Game.",
          "The latter is interesting because my model also takes into account if a player is bad at doing something.",
          "Centers rarely shoot threes and thus aren't very good at it, so it makes sense that it can be an identifier of a center."
        ),
        tags$li(
          "My model isn't the best as you can tell from the kappa metric, where the best is around 63%, even though accuracy goes up to approximately 80%.",
          "Maybe this model can be improved by using multiple college statistics or segmenting the data by year and training separate models for different sets of years, since trends are very much based on year!"
        )
      ),
      p(
        "These are just some basic observations. Using the tables below, you can compare which college statistic is the best of predicting a specific position.",
        "However, you can also see what position a college statistic is best at predicting. You'll find some interesting things! (Use the search bar for easy navigation.)"
      ),
      h3("Accuracy Percentage of Model Table"),
      DTOutput("positionModel.accuracyTable"),
      br(),
      h3("Kappa Percentage of Model Table"),
      DTOutput("positionModel.kappaTable")
    )
  )
)

#################
### Fun facts ###
#################

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
