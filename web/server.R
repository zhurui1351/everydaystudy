# Define server logic for random distribution application
shinyServer(function(input, output) {
  output$title <- DT::renderDataTable({ 
   
    input$goButton
    if(isolate(input$content) != "")
    {
      isolate(writeTologger(input$title,input$tag,input$content))
      
    }
    data = getLog()
    print(input$title_rows_selected)
    datatable(data, options = list(
      pageLength = 3),selection = c("single"))
  })
 
  
})
