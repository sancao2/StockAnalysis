library(DBI)
library(RMySQL)

# make sure packages are installed prior to loading them
library(PerformanceAnalytics)
library(zoo)
library(boot)
library(tseries)


#con <- dbConnect(MySQL(),
#                 user="####",password="####",dbname="test")
#table.names=dbListTables(con)
#fields.names=dbListFields(con,"hi")
#dbSendQuery(con,'SET NAMES utf8') # 注意该行代码是告诉通过什么字符集来获取数据库字段，gbk或者utf8与你当初设置保持一致。
#res=dbSendQuery(con,"select * from hi order by age")
#dat=fetch(res)
#dat
#dbSendQuery(con,"insert into hi values(1,'阿明','男',28)")
#res=dbSendQuery(con,"select * from hi order by age")
#dat=fetch(res)
#dat
#dbDisconnect(con) 


options(digits=4, width=70)

stockCodes <- read.csv("D:\\Desktop\\stockCode_sz_.csv",
                       sep=",", header=F, 
                       col.name=c("code", "pinyin"),
                       encoding="GBK")
#iconvlist()
#iconv(stockCodes,"GBK","UTF-8")
#深交所代码,从第二行开始读起

con <- dbConnect(MySQL(),
                 user="####",password="####",dbname="SCHEMA_CHINASTOCKS")
table.names=dbListTables(con)
fields.names=dbListFields(con,"TABLE_CHINASTOCKS")
dbSendQuery(con,'SET NAMES utf8') # 注意该行代码是告诉通过什么字符集来获取数据库字段，gbk或者utf8与你当初设置保持一致。
res=dbSendQuery(con,"select * from TABLE_CHINASTOCKS")
dat=fetch(res)
dat


for(i in 2:length(stockCodes[,1]))
{
  #stockName <- iconv(stockCodes[2,2],"GBK","UTF-8")
  insertSQL <- paste("insert into TABLE_CHINASTOCKS (CODE, YAHOO_NAME) values('",
                      as.character(stockCodes[i,1]), #code
                      "\',\'", #SQL varchar's sep
                      paste(as.character(stockCodes[i,1]), ".sz", sep=""), #yahoo_name
                      "')",
                      sep="")
  #insertSQL
  dbSendQuery(con,insertSQL)  
}
res=dbSendQuery(con,"select * from TABLE_CHINASTOCKS")
dat=fetch(res)
dat

dbDisconnect(con) 



con <- dbConnect(MySQL(),
                 user="####",password="####",dbname="SCHEMA_CHINASTOCKS")

for(i in 253:length(stockCodes[,1])){
  
#for(i in 2:3){
 #i=2   
  yahooCode = paste(as.character(stockCodes[i,1]), ".sz", sep="")
  stock <- get.hist.quote(instrument=yahooCode, start="2003-11-01",
                          end="2013-11-21", quote=c("AdjClose"),
                          provider="yahoo", origin="1970-01-01",
                          compression="d", retclass="zoo")
  #rm(stock)
  index(stock) <- as.Date.character(index(stock))
  #index(stock)[3]
  #stock[2]
  for(j in 1:length(stock)){
#  j=1
  insertSQL <- paste("insert into TABLE_STOCK_INFO (CODE, DATE, ADJCLOSE) values('",
                        as.character(stockCodes[i,1]), #code
                        "\',\'", #SQL varchar's sep
                        index(stock)[j], #date
                        "\',\'", #SQL varchar's sep
                        stock[j], #adjclose
                        "')",
                        sep="")
    insertSQL  
    dbSendQuery(con,insertSQL)
   }  
}


insertSQL

#dbClearResult(dbListResults(con)[[1]])
dbDisconnect(con) 
