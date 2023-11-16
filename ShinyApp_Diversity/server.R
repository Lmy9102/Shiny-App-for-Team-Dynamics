library(shiny)
library(ggplot2)
library(plotly)

# Set up the server logic to process input and generate the plot.
server1 <- function(input, output) {
  
  # Reactive data frame to store the history of team composition
  history <- reactiveVal(data.frame(Diversity = numeric(), Performance = numeric(), Composition = character()))
  
  # Update history whenever inputs change
  observeEvent(list(input$member1, input$member2, input$member3, input$member4, input$member5), {
    team <- c(input$member1, input$member2, input$member3, input$member4, input$member5)
    diversity <- length(unique(team))
    
    # Use a logarithmic function for performance calculation
    performance <- 50 * log1p(diversity - 1)
    composition <- paste(sort(unique(team)), collapse = ", ")
    
    # Update the history
    new_history <- rbind(history(), data.frame(Diversity = diversity, Performance = performance, Composition = composition))
    history(new_history)
  })
  
  # Generate the plot with a dotted line
  output$performancePlot <- renderPlotly({
    data <- history()
    
    # Create ggplot
    p <- ggplot(data, aes(x = Diversity, y = Performance, group = 1)) +
      geom_line(aes(text = Composition), linetype = "dotted") +
      geom_point(aes(text = Composition)) +
      labs(title = "Team Performance vs Functional Expertise Diversity",
           x = "Diversity of Functional Expertise",
           y = "Team Performance") +
      theme_minimal()
    
    # Convert to plotly
    ggplotly(p, tooltip = "text")
  })
}


