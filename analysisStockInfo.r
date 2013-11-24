library(PerformanceAnalytics)
library(zoo)
library(boot)
library(tseries)

library(DBI)
library(RMySQL)

options(digits=4, width=70)

con <- dbConnect(MySQL(),
                 user="####",password="####",
                 dbname="SCHEMA_CHINASTOCKS")

res=dbSendQuery(con,"select CODE from TABLE_CHINASTOCKS")
stockCode=fetch(res, n=-1)
stockCode[1,'CODE']

dbClearResult(dbListResults(con)[[1]])


insertSQL=paste("SELECT DATE, ADJCLOSE FROM TABLE_STOCK_INFO WHERE CODE = '",
                stockCode[1,'CODE']
                ,"'",
                sep="")
res=dbSendQuery(con, insertSQL)
stockInfo=fetch(res, n=-1)
stockInfo

date <- 
stockZoo <- zoo(stockInfo[,'ADJCLOSE'], 
                as.Date(stockInfo[,'DATE']))
plot(stockZoo)



dbClearResult(dbListResults(con)[[1]])


dbDisconnect(con)
