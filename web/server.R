# Define server logic for random distribution application

shinyServer(function(input, output,session) {
  var<- reactiveValues()
  var$mydata = getLog()
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
    datatable(var$mydata[,2:4], options = list(
      pageLength = 3,searching=FALSE),selection = c("single"),colnames = c('日期', '标题', '标签'))
  })
  
  observe({
    data = var$mydata
    s=input$titlelist_rows_selected
    updateTextInput(session,"selected",value=data[s,5])
    })
  observeEvent(input$goButton, {
    if(isolate(input$content) != "")
    {
      isolate(writeTologger(input$title,input$tag,input$content))      
    }
    data = getLog()
    var$mydata = data
  })
observeEvent(input$searchButton, {
  data = data.frame(1,1,1,1,1,1)
  var$mydata = data
})
})
