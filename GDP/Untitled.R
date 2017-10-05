b=0
for(t in 0:30){
  h = 1
  source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/neat_routine.R")
  rm(list=setdiff(ls(), c("t", "b") ))
  b=b+1
}

gdpdfFull = read.csv('/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/gdp1964.csv', header = TRUE)

loggdptsFULL_diff_df = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/loggdptsFULL_diff_df.csv", header = TRUE)[2:3]

forecast_result = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/forecast_result.csv", header = TRUE)[-1]


# Print results
# Just for output h_num viable is introduced (h_num = 1 corresponds to h=1, h_num=3 to h=4, etc)
h_num = 1
d = 2
start_point = 144 + h_num - d # 144 is for 2000 Q1
df_var_boost_forecast = data.frame(loggdptsFULL_diff_df[start_point:(start_point+(dim(forecast_result)[1])-1),2] , 
                                   forecast_result)
forecast_ts = ts(df_var_boost_forecast, start=c(2000, 1), frequency = 4)

# x = matrix(c(log(gdpdfFull[143:144,2]), log(gdpdfFull[143:144,2]), log(gdpdfFull[143:144,2]), log(gdpdfFull[143:144,2])), ncol=4)
component = log(gdpdfFull[start_point:(start_point + dim(df_var_boost_forecast)[1]), 2])
x = matrix(c(component, component, component, component), ncol=4)

undiff_df = NULL
# for(i in 1:length(forecast_ts)){
for(i in 1:dim(df_var_boost_forecast)[1]){
  temp_ts = ts(df_var_boost_forecast[i,], start=c(2000, 1), frequency = 4)
  a = as.matrix(x[i:(i+1), ])
  undiff_ts = diffinv(temp_ts, differences = 2, xi = a)
  undiff_df = rbind(undiff_df, undiff_ts[(d+1),])
}

undiff_ts = ts(undiff_df, start=c(2000, 1), frequency = 4)
colnames(undiff_ts) = c("true GDP", "VAR", "VAR + GAMboost(Full)","VAR + GAMboost(Y)")
print(exp(undiff_ts))
