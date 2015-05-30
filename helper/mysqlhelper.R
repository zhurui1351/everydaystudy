library(RMySQL)
writeTologger <- function(title,tag,text)
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  dbSendQuery(conn,'SET NAMES utf8')
 # sql = paste("insert into sortalltest(text) values('",iconv(text,from='UTF-8',to='GBK'),"')",sep="")
print(title)
title =  gsub(' ','',title)
tag =  gsub(' ','',tag)
 sql = paste("insert into mylog(title,tag,content,date) values(","'1',","'2',","'3',","now())",sep="")
 sql =str_replace(sql,'1',title)
 sql = str_replace(sql,'2',tag)
 sql = str_replace(sql,'3',text)
 
 print(sql)
  dbGetQuery(conn,sql)
  dbDisconnect(conn)
}