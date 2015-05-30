# Define server logic for random distribution application
shinyServer(function(input, output) {
  output$title <- renderTable({ 
    input$goButton
    if(isolate(input$content) != "")
    {
      isolate(writeTologger(input$title,input$tag,input$content))
      
    }
    getLog()
  })
 
  
})
