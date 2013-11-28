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

# function to compute Value-at-Risk
# note: default values are selected for 
# the probability level (p) and the initial
# wealth (w). These values can be changed
# when calling the function. Highlight the entire
# function, right click and select run line or selection
Value.at.Risk <- function(x,p=0.05,w=100000) {
  x <- as.matrix(x)
  q <- mean(x) + sd(x)*qnorm(p)
  VaR <- (exp(q) - 1)*w
  VaR
}

i
for(i in 1539:length(stockCode[,'CODE'])){
  #i <- 1
  if (i == 604 | i == 758 | i == 1505 | i == 1539)
    next
  querySQL <- paste("SELECT DATE, ADJCLOSE FROM TABLE_STOCK_INFO WHERE CODE = '",
                    stockCode[i,'CODE']
                    ,"'",
                    sep="")
  res<-dbSendQuery(con, querySQL)
  stockInfo<-fetch(res, n=-1)
  stockInfo
  
  stockZoo <- zoo(stockInfo[,'ADJCLOSE'], 
                  as.Date(stockInfo[,'DATE']))
  plot(stockZoo)
  
  #monthly return 
  stockReturn <- diff(log(stockZoo), lag=20)
  stockReturn
  
  #
  # Create timePlots of data
  #
  
  #plot(stockReturn)
  #legend(x="topleft", legend=stockCode[1,'CODE'], lty=1:3, col=1:3, lwd=2)
  #abline(h=0)
  #title("monthly cc returns")
  
  #
  # Create matrix of return data and compute pairwise scatterplots
  #
  ret.mat <- coredata(stockReturn)
  head(ret.mat)
  ret.mat
  
  #
  # Compute estimates of CER model parameters
  #
  muhat.vals <- mean(ret.mat)
  muhat.vals
  sigmahat.vals <- sd(ret.mat)
  sigmahat.vals
  
  #
  # compute approx 95% confidence intervals
  #
  mu.lower <- muhat.vals - 2*sigmahat.vals
  mu.upper <- muhat.vals + 2*sigmahat.vals
  cbind(mu.lower,mu.upper)
  
  
  # 5% and 1% VaR estimates based on W0 = 100000
  
  VaR05 <- Value.at.Risk(ret.mat,p=0.05,w=100000)
  VaR05
  VaR01 <- Value.at.Risk(ret.mat,p=0.01,w=100000)
  VaR01
  
  updateSQL <- paste("UPDATE TABLE_CHINASTOCKS SET VaR05 = ",VaR05,                   
                             ", VaR01 = ",VaR01,
                             ", mu = ", muhat.vals,
                             ", sd = ", sigmahat.vals,
                             ", muUpper = ", mu.upper,
                             ", muLower = ", mu.lower,
                             " WHERE CODE = ", stockCode[i,'CODE'],
                    sep="")
dbSendQuery(con, updateSQL)
}
#
# month rolling estimates of mu and sd
#
ret.mat
# rolling analysis for A600085
roll.mu = rollapply(ret.mat,
                            FUN=mean, width = 2*51*5, align="right")
roll.mu

roll.sd = rollapply(ret.mat,
                  FUN=sd, width = 2*51*5, align="right")

roll.sd

plot(merge(roll.mu, roll.sd, ret.mat),
     main="2 year rolling mean & sd", ylab="Percent daily", lwd=2)

abline(h=0)
legend(x="bottomleft", legend=c("Rolling means","Rolling sds", "A600085 returns"), 
       col=c("blue"), lwd=2)

dbClearResult(dbListResults(con)[[1]])


dbDisconnect(con)
