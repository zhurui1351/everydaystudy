library(ggplot2)
shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      textInput("title", label="标题", value = ""),
      br(),
      textInput("tag", label="标签", value = ""),
      br(),
      # HTML('<textarea id="content" rows="10"  value = ""></textarea>'),
      tags$textarea(id="content", rows=10,""),
      br(),
      actionButton("goButton", "添加"),
      br(),
      selectInput("select", label = h3("搜索"), 
                  choices = list("按标题搜索" = 1, "按标签搜索" = 2,
                                 "按内容搜索" = 3,'未复习'=4), selected = 1),
      textInput("keyword", label="关键字", value = ""),
      actionButton("searchButton", "搜索")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("知识列表",DT::dataTableOutput("titlelist"), tags$textarea(id="selected", rows=10,cols=80,textOutput("selectedcontent")),
                 actionButton("update", "更新"),
                 actionButton("delete", "删除")
        ),
        tabPanel("复习",  tags$textarea(id="selected", rows=10,cols=80,textOutput("selectedcontent"))),
        tabPanel("统计分析", textOutput("selectedcontent"))
      )
    )
  )
))
