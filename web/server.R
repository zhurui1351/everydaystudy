# Define server logic for random distribution application
shinyServer(function(input, output) {
  output$text1 <- renderText({ 
    input$goButton
    if(isolate(input$content) != "")
    {
      isolate(writeTologger(input$title,input$tag,input$content))
      
    }
    isolate(input$content)
  })
})
