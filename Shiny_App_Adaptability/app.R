library(shiny)
library(plotly)

# Define UI for application
ui <- fluidPage(
  titlePanel("Team Configuration Transition Simulator"),
  sidebarLayout(
    sidebarPanel(
      h3("Starting Configuration"),
      sliderInput("structure_start", "Team Structure Continuum (Specialist <---> Generalist):", min = 0, max = 1, value = 0),
      sliderInput("decision_start", "Decision-Making Continuum (Centralized <---> Decentralized):", min = 0, max = 1, value = 0),
      sliderInput("reward_start", "Reward System Continuum (Competition <---> Cooperation):", min = 0, max = 1, value = 0),
      
      h3("Ending Configuration"),
      sliderInput("structure_end", "Team Structure Continuum (Specialist <---> Generalist):", min = 0, max = 1, value = 1),
      sliderInput("decision_end", "Decision-Making Continuum (Centralized <---> Decentralized):", min = 0, max = 1, value = 1),
      sliderInput("reward_end", "Reward System Continuum (Competition <---> Cooperation):", min = 0, max = 1, value = 1),
      
      actionButton("simulate", "Simulate Transition")
    ),
    mainPanel(plotlyOutput("timePlot"))
  )
)

# Define server logic
server <- function(input, output) {
  transitionHistory <- reactiveVal(data.frame(Transition = integer(), Time = numeric(), Start = character(), End = character()))
  
  observeEvent(input$simulate, {
    # A scoring function to evaluate adaptability time required for transition
    calculateTime <- function(start, end) {
      # Calculate distance between configurations
      distance <- sum(abs(start - end))
      
      # Base time based on distance
      baseTime <- distance * 2
      
      # Check if transitioning from beyond 0.5 to below 0.5
      if (all(start > 0.5) && all(end < 0.5)) {
        return(baseTime * 0.5) # Faster transition
      }
      
      # Check if transitioning from below 0.5 to beyond 0.5
      if (all(start < 0.5) && all(end > 0.5)) {
        return(baseTime * 1.5) # Slower transition
      }
      
      # Check for the special cases
      if (all(start == 0.5) && all(end == 0.5)) {
        return(0) # No transition time needed
      } else if (all(start == c(0, 0, 0)) && all(end == c(1, 1, 1))) {
        return(10) # Max transition time
      } else if (all(start == c(1, 1, 1)) && all(end == c(0, 0, 0))) {
        return(9) # Second longest transition time
      }
      
      # General case based on distance
      return(baseTime)
    }
    
    # Calculate the total transition time
    totalTime <- calculateTime(
      c(input$structure_start, input$decision_start, input$reward_start),
      c(input$structure_end, input$decision_end, input$reward_end)
    )
    
    # Format the configuration as text
    startConfig <- paste0("Structure: ", round(input$structure_start, 2), 
                          ", Decision: ", round(input$decision_start, 2), 
                          ", Reward: ", round(input$reward_start, 2))
    endConfig <- paste0("Structure: ", round(input$structure_end, 2), 
                        ", Decision: ", round(input$decision_end, 2), 
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
    
    # Generate a line plot to show the history of transition times
    p <- plot_ly(data, x = ~Transition, y = ~Time, type = 'scatter', mode = 'lines+markers',
                 text = ~paste("Start: ", Start, "<br>End: ", End), hoverinfo = 'text')
    
    p <- p %>% layout(title = "History of Adaptability Time Required",
                      xaxis = list(title = "Simulation Number"),
                      yaxis = list(title = "Time (arbitrary units)"))
    
    return(p)
  })
}

shinyApp(ui = ui, server = server)
