library(mAr) # Multivariate AutoRegressive analysis
library(zoo) # Year/Quarter
library(caret)
library(corrplot)
library(forecast)
library(vars)
library(splines)

library(ggplot2)
library(TTR)
library(gbm)

horizont = c(1,2,4,8)   # Forecasting horizon
#VAR_forecast = NULL
#gamboost_forecast = NULL
#gamboost_forecast_y = NULL

#forecast_result = NULL

horizont = c(1)
h =1 ##########
#while( dim(gdpdf)[1] <= (dim(gdpdfFull)[1] - h) ){
for(h in horizont){
  t = 0
  j = 0
  
  while( j <= (150 - h) ){
    
    # Reading Data
    source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/init_data.R")
    
    # Preparing and cleaning data
    source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/prepare_data.R")
    
    
    # Variable Selection
    source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/variable_selection.R")
    
    # Correlation Filtering
    # source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/correlation_filtering.R")
    
    # Vector autoregression
    source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/VAR_etc.R")
    
    # Gamboost
    source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/gamboost_gdp.R")
    
    if(t == 0){
      write.csv(t(c(VAR_forecast, gamboost_forecast_y, gamboost_forecast)), "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv")
    }else{
      forecast_result = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv")
      write.csv(rbind(forecast_result[-1], c(VAR_forecast, gamboost_forecast_y, gamboost_forecast)),
                "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv")
    }

    j = dim(gdpdf)[1]
    t = t + 1
    
    rm(list=setdiff(ls(), c("t", "j", "horizont", "h")))
  }
}

# Results
source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/results.R") # from 2000 Q1

# testing results
h_num = 1
start_point = dim(gdpdf)[1] + h_num - d
df_var_boost_forecast = data.frame(loggdptsFULL_diff_df[start_point:(start_point+length(VAR_forecast)-1),2] ,as.vector(VAR_forecast), 
                                   as.vector(gamboost_forecast), as.vector(gamboost_forecast_y))
forecast_ts = ts(df_var_boost_forecast, start=c(2011, 3), frequency = 4)

component = log(gdpdfFull[start_point:(start_point + d - 1), 2])
x = matrix(c(component, component, component, component), ncol=4)
undiff = diffinv(forecast_ts, differences = 2, xi=x)
colnames(undiff) = c("true GDP", "VAR", "VAR + GAMboost(Full)","VAR + GAMboost(Y)")
exp(undiff)