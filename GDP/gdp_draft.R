library(tseries)
library(forecast)
library(mboost)
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
library(dynlm)
library(DescTools)
library(tsDyn)

# test model loop n=1 (p - manually), n=2 (p - AIC)
testres = list()
for(n in 1:2){          
  
  # Reading data
  source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/init_data.R")
  
  # Preparing and cleaning data
  source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/prepare_data.R")
  
  horizont = c(1, 2, 4)   # Forecasting horizon
  
  Final_Results = list()


  for(h in horizont){
  
  adl_gamboost_forecast = NULL
  start_year = 1999
  start_Q = 4
      
    if(h == 1 | h == 2 | h == 4){
      current_Q = start_Q - (h - 1)
      year = start_year
    }else{
      current_Q = start_Q - (h/2 - 1)
      year = start_year - 1
    }
    
    for( t in 0 : 1 ){   # set 67 for full test set
      
      # Build autoregressive model and boost it
      source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/build_model.R")
      
      adl_gamboost_forecast = rbind(adl_gamboost_forecast, result_df)
      
      rm(list=setdiff(ls(), c( "n","t", "horizont", "h", "Selected_diff", "gdpdfFull", 
                              "quarterlyFull", "quarterlyts", "d", "gdp_d", "work_data_diff", "work_data_diff_ts", 
                              "q", "year", "current_Q", "adl_gamboost_forecast", "Final_Results", 
                              "start_Q", "start_year", "testres", "p_AIC")))
    }
    
    names(adl_gamboost_forecast) = c("True", "Gamboost", "SqError_boosting", "AR(1)", "SqError_AR(1)")
    adl_gamboost_forecast_ts = ts(adl_gamboost_forecast, start=c(2000, 1), frequency = 4)
    
    Final_Results[[paste("h", h, sep = '')]] = adl_gamboost_forecast_ts
    
    MSE_adl_gamboost = mean( adl_gamboost_forecast[,3] )
    MSE_AR1 = mean( adl_gamboost_forecast[,5] )
    MSEs = data.frame(MSE_adl_gamboost, MSE_AR1)
    colnames(MSEs) = c("MSE_boosting","MSE_AR(1)")
    
    Final_Results[[paste("MSE", h, sep = '')]] = MSEs
    
    Final_Results[[paste("TheilU", h, sep = '')]] = TheilU(adl_gamboost_forecast[,1], adl_gamboost_forecast[,2], type = 2)
    
    rm(list=setdiff(ls(), c( "n","horizont", "h", "Selected_diff", "gdpdfFull", "quarterlyFull", "quarterlyts", "d",
                             "gdp_d", "work_data_diff", "work_data_diff_ts", "Final_Results", "testres", "p_AIC")))
    
  }
  
  testres[[n]] = Final_Results[c('MSE1', 'TheilU1', 'MSE2', 'TheilU2', 'MSE4', 'TheilU4', 'MSE8', 'TheilU8')]
  rm(list=setdiff(ls(), c("testres", "n")))
}

sink("/Users/antongorev/Dropbox/Study/Seminar/my tests/testres_df5.txt")
for(i in 1:n){
  print(testres[[i]])
  print("#########################")
}
#lapply(testres, print)
sink()

########## Testing model #############

source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/model_tests/DMtest.R")

loss_diff = adl_gamboost_forecast[,5]-adl_gamboost_forecast[,3]    # loss-differential series (boost-AR)
DMtest(loss_diff, h)                                               # custom Diebold-Mariano test
dm.test(adl_gamboost_forecast[,5], adl_gamboost_forecast[,3], h=h, power=2) # {forecast} package method

