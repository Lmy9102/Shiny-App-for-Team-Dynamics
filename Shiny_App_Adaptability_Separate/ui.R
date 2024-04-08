library(shiny)
library(plotly)

# Define UI for application
ui <- fluidPage(
  titlePanel("Team Configuration Transition Simulator"),
  sidebarLayout(
    sidebarPanel(
      h3("Starting Configuration"),
      sliderInput("decision_start", "Decision-Making Continuum (Centralized <---> Decentralized):", min = 0, max = 1, value = 0),
      sliderInput("reward_start", "Reward System Continuum (Competition <---> Cooperation):", min = 0, max = 1, value = 0),
      
      h3("Ending Configuration"),
      sliderInput("decision_end", "Decision-Making Continuum (Centralized <---> Decentralized):", min = 0, max = 1, value = 1),
      sliderInput("reward_end", "Reward System Continuum (Competition <---> Cooperation):", min = 0, max = 1, value = 1),
      
      actionButton("simulate", "Simulate Transition")
    ),
    mainPanel(plotlyOutput("timePlot"))
  )
)