library(shiny)
library(plotly)

# Define server logic
server <- function(input, output) {
  transitionHistory <- reactiveVal(data.frame(Transition = integer(), Time = numeric(), Start = character(), End = character()))
  
  observeEvent(input$simulate, {
    # A scoring function to evaluate adaptability time required for transition
    calculateTime <- function(decision_start, decision_end, reward_start, reward_end) {
      # Calculate distance between configurations
      decisionDistance <- abs(decision_start - decision_end)
      rewardDistance <- abs(reward_start - reward_end)
      
      # Base time based on distance
      baseTime <- (decisionDistance + rewardDistance) * 2
      
      # Initialize multipliers
      decisionMultiplier <- 1
      rewardMultiplier <- 1
      compoundingMultiplier <- 1
      
      # Decision transition multipliers
      if (decision_start > 0.5 && decision_end <= 0.5) {
        decisionMultiplier <- 1 # More time for centralized to decentralized
      } else if (decision_start <= 0.5 && decision_end > 0.5) {
        decisionMultiplier <- 1.5 # Less time for decentralized to centralized
      }
      
      # Reward transition multipliers
      if (reward_start > 0.5 && reward_end <= 0.5) {
        rewardMultiplier <- 1 # More time for competition to cooperation
      } else if (reward_start <= 0.5 && reward_end > 0.5) {
        rewardMultiplier <- 1.5 # Less time for cooperation to competition
      }
      
      # Compounding effect if both decision and reward are changing as specified
      if ((decision_start > 0.5 && decision_end <= 0.5) && (reward_start > 0.5 && reward_end <= 0.5)) {
        compoundingMultiplier <- 1.1 # Compounding effect
      }
      
      # Apply the multipliers to the base time
      totalTime <- baseTime * decisionMultiplier * rewardMultiplier * compoundingMultiplier
      return(totalTime)
    }
    
    # Calculate the total transition time
    totalTime <- calculateTime(
      input$decision_start,
      input$decision_end,
      input$reward_start,
      input$reward_end
    )
    
    # Format the configuration as text
    startConfig <- paste0("Decision: ", round(input$decision_start, 2), 
                          ", Reward: ", round(input$reward_start, 2))
    endConfig <- paste0("Decision: ", round(input$decision_end, 2), 
                        ", Reward: ", round(input$reward_end, 2))
    
    # Update history
    currentHistory <- transitionHistory()
    newEntry <- data.frame(
      Transition = nrow(currentHistory) + 1,
      Time = totalTime,
      Start = startConfig,
      End = endConfig
    )
    transitionHistory(rbind(currentHistory, newEntry))
  })
  
  # Render the transition time graphically with Plotly
  output$timePlot <- renderPlotly({
    data <- transitionHistory()
    
    if (nrow(data) == 0) {
      return(ggplotly(ggplot() + theme_void()))
    }
    
    p <- plot_ly(data, x = ~Transition, y = ~Time, type = 'scatter', mode = 'lines+markers',
                 text = ~paste("Start: ", Start, "<br>End: ", End), hoverinfo = 'text')
    
    p <- p %>% layout(title = "History of Adaptability Time Required",
                      xaxis = list(title = "Simulation Number"),
                      yaxis = list(title = "Time (arbitrary units)"))
    
    return(p)
  })
}

