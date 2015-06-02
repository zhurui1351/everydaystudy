require('shiny')
require('stringr')
require('DT')
options(shiny.trace=F)
sourceDir <- function(path, trace = TRUE, ...) {
  for (nm in list.files(path, pattern = "[.][RrSsQq]$")) {
    if(trace) cat(nm,":")
    source(file.path(path, nm), ...)
    if(trace) cat("\n")
  }
}
currentwd = getwd()
setwd("C:/R/code/everydaystudy")
sourceDir("helper")
runApp("web")
setwd(currentwd)




