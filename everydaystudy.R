require('shiny')
require('stringr')
require('DT')
sourceDir <- function(path, trace = TRUE, ...) {
  for (nm in list.files(path, pattern = "[.][RrSsQq]$")) {
    if(trace) cat(nm,":")
    source(file.path(path, nm), ...)
    if(trace) cat("\n")
  }
}
currentwd = getwd()
setwd("d:/tradingSystem/Rcode/code/everydaystudy")
sourceDir("helper",encoding='utf-8')
runApp("web")
setwd(currentwd)

