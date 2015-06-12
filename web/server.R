
# Define server logic for random distribution application
shinyServer(function(input, output,session) {
  var<- reactiveValues()
  var$mydata = getLog()
  var$flag = 1
  var$search = NULL
  #   mydata <- reactive({
  #     input$goButton
  #     if(isolate(input$content) != "")
  #     {
  #       isolate(writeTologger(input$title,input$tag,input$content))
  #       
  #     }
  #     data = getLog()
  #     data
  #   })
  output$titlelist = DT::renderDataTable({   
    datatable(var$mydata[,2:5], options = list(
      pageLength = 10,searching=FALSE),
      selection = c("single"), colnames=c('日期','标题','标签','复习次数')
      )
  })
  
  observe({
    data = var$mydata
    s=input$titlelist_rows_selected
    updateTextInput(session,"selected",value=data[s,'content'])
  })
  observeEvent(input$goButton, {
    if(isolate(input$content) != "")
    {
      isolate(writeTologger(input$title,input$tag,input$content))      
    }
    data = getLog() 
    var$mydata = data
    var$flag = 1
  })
  observeEvent(input$searchButton, {
    
    f = switch(input$select, 
               "1"= getSearchByTitle,
               "2" = getSearchByTag,
               "3" = getSearchByContent,
               "4" = getUnreviewd)
    keyword = isolate(input$keyword) 
    data = f(keyword)
    var$flag = 2
    var$mydata = data
    var$search = f
  })
  
  observeEvent(input$delete, {    
    s=isolate(input$titlelist_rows_selected)
    id = var$mydata[s,1]
    deleteByid(id);
    if(var$flag == 1)
      var$mydata = getLog()
    if(var$flag == 2)
      var$mydata = var$search(isolate(input$keyword))
    
  })
  
  observeEvent(input$update, {    
    s=isolate(input$titlelist_rows_selected)
    id = var$mydata[s,1]
    updateByid(id,isolate(input$selected));
    if(var$flag == 1)
      var$mydata = getLog()
    if(var$flag == 2)
      var$mydata = var$search(isolate(input$keyword))
    
  })
  
  observeEvent(input$review, {    
    s=isolate(input$titlelist_rows_selected)
    id = var$mydata[s,1]
    reviewByid(id);
    if(var$flag == 1)
      var$mydata = getLog()
    if(var$flag == 2)
      var$mydata = var$search(isolate(input$keyword))
  })
  output$freqByWeek <- renderPlot(
    freqByweek()
    )
  output$freqByTag <- renderPlot(
    freqByTag()
    )
})
