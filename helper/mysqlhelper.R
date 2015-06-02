library(RMySQL)
writeTologger <- function(title,tag,text)
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  dbSendQuery(conn,'SET NAMES utf8')
 # sql = paste("insert into sortalltest(text) values('",iconv(text,from='UTF-8',to='GBK'),"')",sep="")
 title =  gsub(' ','',title)
 tag =  gsub(' ','',tag)
 sql = paste("insert into mylog(title,tag,content,date) values(","'1',","'2',","'3',","now())",sep="")
 sql =str_replace(sql,'1',title)
 sql = str_replace(sql,'2',tag)
 sql = str_replace(sql,'3',text)
 dbGetQuery(conn,sql)
  dbDisconnect(conn)
}

getLog <- function()
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  #strange here because encoding in database is utf8
  dbSendQuery(conn,'SET NAMES utf8')
  sql = 'select id, date,title,tag,count,content  from mylog order by date desc'
  data = dbGetQuery(conn,sql)
  dbDisconnect(conn)
  data[,3] = iconv(data[,3],from='UTF-8',to='GBK')
  data[,4] = iconv(data[,4],from='UTF-8',to='GBK')
  data[,6] = iconv(data[,6],from='UTF-8',to='GBK')
  return(data)
  
}

getSearchByTitle <- function(keyword)
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  #strange here because encoding in database is utf8
  dbSendQuery(conn,'SET NAMES utf8')
  sql = "select id, date,title,tag,count,content  from mylog  where title like '%1%' order by date desc"
  sql =str_replace(sql,'1',keyword)
  data = dbGetQuery(conn,sql)
  dbDisconnect(conn)
  data[,3] = iconv(data[,3],from='UTF-8',to='GBK')
  data[,4] = iconv(data[,4],from='UTF-8',to='GBK')
  data[,6] = iconv(data[,6],from='UTF-8',to='GBK')
  return(data) 
}

getSearchByTag <- function(keyword)
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  #strange here because encoding in database is utf8
  dbSendQuery(conn,'SET NAMES utf8')
  sql = "select id, date,title,tag,count,content  from mylog  where tag like '%2%' order by date desc"
  sql =str_replace(sql,'2',iconv(keyword,from='UTF-8',to='GBK'))
  data = dbGetQuery(conn,sql) 
  dbDisconnect(conn)
  data[,3] = iconv(data[,3],from='UTF-8',to='GBK')
  data[,4] = iconv(data[,4],from='UTF-8',to='GBK')
  data[,6] = iconv(data[,6],from='UTF-8',to='GBK')
  return(data)
}

getSearchByContent <- function(keyword)
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  #strange here because encoding in database is utf8
  dbSendQuery(conn,'SET NAMES utf8')
  sql = "select id, date,title,tag,count,content  from mylog where content like '%3%' order by date desc "
  sql =str_replace(sql,'3',keyword)
  data = dbGetQuery(conn,sql)
  dbDisconnect(conn)
  data[,3] = iconv(data[,3],from='UTF-8',to='GBK')
  data[,4] = iconv(data[,4],from='UTF-8',to='GBK')
  data[,6] = iconv(data[,6],from='UTF-8',to='GBK')
  return(data)
}

deleteByid <- function(id)
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  #strange here because encoding in database is utf8
  dbSendQuery(conn,'SET NAMES utf8')
  sql = "delete from mylog where id = 1 "
  sql =str_replace(sql,'1',id)
  rs = dbGetQuery(conn,sql)
  dbDisconnect(conn)
}

updateByid <- function(id,content)
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  #strange here because encoding in database is utf8
  dbSendQuery(conn,'SET NAMES utf8')
  sql = " update mylog set content = '2' , date = now() where id = 1 "
  sql =str_replace(sql,'1',id)
  sql =str_replace(sql,'2',content)
  rs = dbGetQuery(conn,sql)
  
  dbDisconnect(conn)
}

getUnreviewd <- function(x)
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  #strange here because encoding in database is utf8
  dbSendQuery(conn,'SET NAMES utf8')
  sql = 'select id, date,title,tag,count,content  from mylog where count=0 order by date desc'
  data = dbGetQuery(conn,sql)
  dbDisconnect(conn)
  data[,3] = iconv(data[,3],from='UTF-8',to='GBK')
  data[,4] = iconv(data[,4],from='UTF-8',to='GBK')
  data[,6] = iconv(data[,6],from='UTF-8',to='GBK')
  return(data)
  
}

reviewByid <- function(id,content)
{
  conn <- dbConnect(MySQL(), dbname = "everydaystudy", username="zhurui", password="123456",host="127.0.0.1",port=3306)
  dbSendQuery(conn,'SET NAMES utf8')
  sql = " update mylog set count = count + 1 where id = param "
  sql =str_replace(sql,'param',id)
  rs = dbGetQuery(conn,sql)
  print(sql)
  dbDisconnect(conn)
}
