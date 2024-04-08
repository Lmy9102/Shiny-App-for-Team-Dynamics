


library(shiny)
library(ggplot2)
library(plotly)
library(DT)


# Define server logic
server <- function(input, output, session) {
  conflictHistory <- reactiveVal(data.frame())
  performanceHistory <- reactiveVal(data.frame())
  specialConfigs <- reactiveVal(list(high = NULL, low = NULL))
  
  observeEvent(input$simulate, {
    configNum <- nrow(conflictHistory()) + 1
    configLabel <- paste("Configuration", configNum)
    
    earlyConflict <- paste(input$rel_early, input$proc_early, input$task_early, sep = ", ")
    middleConflict <- paste(input$rel_middle, input$proc_middle, input$task_middle, sep = ", ")
    lateConflict <- paste(input$rel_late, input$proc_late, input$task_late, sep = ", ")
    
    newConflictEntry <- data.frame(
      Configuration = configLabel,
      Early = earlyConflict,
      Middle = middleConflict,
      Late = lateConflict
    )
    
    # Performance logic
    performance <- "medium"  # Default performance level
    performanceScore <- sample(50:75, 1)  # Random fluctuation within medium range
    if (earlyConflict == "Low, Low, Moderate" && middleConflict == "Moderate, Moderate, High" && lateConflict == "High, High, High") {
      performance <- "high"
      performanceScore <- 100
      newConflictEntry$Configuration <- paste(configLabel, "(High)")
      currentConfigs <- specialConfigs()
      currentConfigs$high <- paste(configLabel, "(High) The conflict configuration observed in high-performing teams.")
      specialConfigs(currentConfigs)
    } else if (earlyConflict == "Low, Moderate, Moderate" && middleConflict == "High, Low, Moderate" && lateConflict == "High, Moderate, High") {
      performance <- "low"
      performanceScore <- 20
      newConflictEntry$Configuration <- paste(configLabel, "(Low)")
      currentConfigs <- specialConfigs()
      currentConfigs$low <- paste(configLabel, "(Low) The conflict configuration observed in low-performing teams.")
      specialConfigs(currentConfigs)
    }
    
    newPerformanceEntry <- data.frame(
      Config = newConflictEntry$Configuration,
      Performance = performance,
      PerformanceScore = performanceScore
    )
    performanceHistory(rbind(performanceHistory(), newPerformanceEntry))
    conflictHistory(rbind(conflictHistory(), newConflictEntry))
  })
  
  
  # Table: Conflict History
  output$conflictTable <- renderDT({
    datatable(conflictHistory(), options = list(pageLength = 5, dom = 't'), rownames = FALSE)
  }, server = FALSE)
  
  
  # Note below the conflict table
  output$conflictNote <- renderUI({
    if (nrow(conflictHistory()) > 0) {
      tags$p("The configuration of team conflict level follows the sequence of relationship, process, task conflict.")
    }
  })
  
  # Performance Note
  output$performanceNote <- renderUI({
    specialNotes <- specialConfigs()
    divs <- vector("list", length(specialNotes))
    if (!is.null(specialNotes$high)) {
      divs[[length(divs) + 1]] <- tags$p(specialNotes$high)
    }
    if (!is.null(specialNotes$low)) {
      divs[[length(divs) + 1]] <- tags$p(specialNotes$low)
    }
    do.call(tagList, divs)
  })
  
  # Performance Plot (Placeholder)
  output$performancePlot <- renderPlotly({
    data <- performanceHistory()
    
    if (nrow(data) == 0) {
      return()
    }
    
    # Convert 'high', 'medium', 'low' to numerical values
    data$PerformanceNum <- ifelse(data$Performance == "high", 100,
                                  ifelse(data$Performance == "medium", 50, 20))
    
    p <- ggplot(data, aes(x = Config, y = PerformanceScore)) +
      geom_point() +
      geom_line(aes(group = Config), linetype = "dotted") +
      scale_y_continuous(breaks = c(20, 50, 100), labels = c("Low", "Moderate", "High")) +
      labs(title = "Team Performance vs. Configuration",
           x = "Configuration", y = "Performance Level") +
      theme_minimal() +
      theme(legend.position = "none")
    
    ggplotly(p, tooltip = "x")
  })
}

