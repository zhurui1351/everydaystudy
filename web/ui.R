
# Define UI for random distribution application 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("我的笔记"),
  
  # Sidebar with controls to select the random distribution type
  # and number of observations to generate. Note the use of the
  # br() element to introduce extra vertical spacing
  sidebarLayout(
    sidebarPanel(
      textInput("titile", label="标题", value = ""),
      br(),
      textInput("tag", label="标签", value = ""),
      br(),
      HTML('<textarea id="content" rows="10" ></textarea>')
     
    ),
    
    # Show a tabset that includes a plot, summary, and table view
    # of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", sliderInput("n", 
                                     "Number of observations:", 
                                     value = 500,
                                     min = 1, 
                                     max = 1000)),
        tabPanel("Summary", verbatimTextOutput("summary")),
        tabPanel("Table", tableOutput("table"))
      )
    )
  )
))
