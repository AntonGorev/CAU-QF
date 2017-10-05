
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

if(t == 0){
  write.csv(t(c(VAR_forecast, gamboost_forecast_y, gamboost_forecast)), "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv")
}else{
  forecast_result = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv")
  write.csv(rbind(forecast_result[-1], c(VAR_forecast, gamboost_forecast_y, gamboost_forecast)),
            "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv")
}






loggdptsFULL_diff_df = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/loggdptsFULL_diff_df.csv", header = TRUE)[2:3]

#forecast_results = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv", header = TRUE)[-1]


# Print results
# Just for output h_num viable is introduced (h_num = 1 corresponds to h=1, h_num=3 to h=4, etc)
h_num = 1
d = 2
start_point = 211 + h_num - d # 144 is for 2000 Q1
df_var_boost_forecast = data.frame(loggdptsFULL_diff_df[start_point:(start_point+(dim(forecast_result)[1])-1),2] , 
                                   forecast_result)
forecast_ts = ts(df_var_boost_forecast, start=c(2016, 4), frequency = 4)

# x = matrix(c(log(gdpdfFull[143:144,2]), log(gdpdfFull[143:144,2]), log(gdpdfFull[143:144,2]), log(gdpdfFull[143:144,2])), ncol=4)
component = log(gdpdfFull[start_point:(start_point + d - 1), 2])
x = matrix(c(component, component, component, component), ncol=4)
undiff = diffinv(forecast_ts, differences = 2, xi=x)
colnames(undiff) = c("true GDP", "VAR", "VAR + GAMboost(Full)","VAR + GAMboost(Y)")
print(exp(undiff))

rm(list=ls())
