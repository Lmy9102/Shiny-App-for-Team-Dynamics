library(shiny)

# Create a user interface with inputs for team member expertise and an output area for the plot.
ui1 <- fluidPage(
  titlePanel("Functional Expertise Diversity and Team Performance"),
  sidebarLayout(
    sidebarPanel(
      selectInput("member1", "Team Member 1", choices = c("Engineering", "Project Management", "Accounting", "Finance", "Computer Science")),
      selectInput("member2", "Team Member 2", choices = c("Engineering", "Project Management", "Accounting", "Finance", "Computer Science")),
      selectInput("member3", "Team Member 3", choices = c("Engineering", "Project Management", "Accounting", "Finance", "Computer Science")),
      selectInput("member4", "Team Member 4", choices = c("Engineering", "Project Management", "Accounting", "Finance", "Computer Science")),
      selectInput("member5", "Team Member 5", choices = c("Engineering", "Project Management", "Accounting", "Finance", "Computer Science"))
    ),
    mainPanel(plotlyOutput("performancePlot"))
  )
)