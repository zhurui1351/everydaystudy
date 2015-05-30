shinyUI(fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      textInput("title", label="标题", value = ""),
      br(),
      textInput("tag", label="标签", value = ""),
      br(),
      HTML('<textarea id="content" rows="10"  value = ""></textarea>'),
      br(),
      actionButton("goButton", "添加")
      
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("文章列表", textOutput("text1")),
        tabPanel("总结", verbatimTextOutput("summary")),
        tabPanel("统计分析", tableOutput("table"))
      )
    )
  )
))