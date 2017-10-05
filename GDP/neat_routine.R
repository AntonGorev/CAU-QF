
#Reading data
source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/init_data.R")

# Preparing and cleaning data
source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/prepare_data.R")


# Variable Selection
source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/variable_selection.R")


# Vector autoregression
source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/VAR_etc.R")

# Gamboost
source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/gamboost_gdp.R")

if(b == 0){
  write.csv(t(c(VAR_forecast, gamboost_forecast_y, gamboost_forecast)), "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv")
}else{
  forecast_result = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv")
  write.csv(rbind(forecast_result[-1], c(VAR_forecast, gamboost_forecast_y, gamboost_forecast)),
            "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv")
}
