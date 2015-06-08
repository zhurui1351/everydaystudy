require(dplyr)
freqByweek <- function()
{
  data = getLog()
  x = data[,'date']
  data$week = strftime(x,'%W')
  data$month = strftime(x,'%m')
  data$year = strftime(x,'%Y')
  
  groupdata=group_by(data,week,year)
  count_n = summarise(groupdata,n=n())
  plot(paste(count_n$year,count_n$week,sep=''),count_n$n,type='l',xlab='周',ylab='新增知识点')
}

freqByTag <- function()
{
  data = getLog()
  mytags = data[,'tag']
  mytags = unlist(strsplit(mytags,split=',',fixed=T))
  ftags = as.factor(mytags)
  barplot(table(ftags))
}
