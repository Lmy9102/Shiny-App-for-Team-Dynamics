library(shiny)
library(ggplot2)
library(plotly)
library(DT)

# Define UI
ui <- fluidPage(
  titlePanel("Conflict and Team Performance"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Select Conflict Levels"),
      selectInput("task_early", "Early Stage Task Conflict", choices = c("Low", "Medium", "High")),
      selectInput("rel_early", "Early Stage Relationship Conflict", choices = c("Low", "Medium", "High")),
      selectInput("task_middle", "Middle Stage Task Conflict", choices = c("Low", "Medium", "High")),
      selectInput("rel_middle", "Middle Stage Relationship Conflict", choices = c("Low", "Medium", "High")),
      selectInput("task_late", "Late Stage Task Conflict", choices = c("Low", "Medium", "High")),
      selectInput("rel_late", "Late Stage Relationship Conflict", choices = c("Low", "Medium", "High")),
      actionButton("simulate", "Simulate Performance")
    ),
    
    mainPanel(
      DTOutput("conflictTable"),
      uiOutput("conflictNote"),
      uiOutput("performanceNote"),
      plotlyOutput("performancePlot")
    )
  )
)


