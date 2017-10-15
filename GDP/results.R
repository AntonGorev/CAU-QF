# These dataframe is created just in sake of transparent analisys,
#  it was useful for me to compare different data_objects
# gdpdfFull = read.csv('/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/gdp1964.csv', header = TRUE)
# loggdptsFULL = ts(log(gdpdfFull[2]), start=c(1964, 1), frequency = 4, names = "logGDP") # For testing purpose
# loggdptsFULL_diff_df = data.frame(date=as.Date(as.yearqtr(time(diff(loggdptsFULL, differences = 1)))), 
#                                  diff(loggdptsFULL, differences = 1))
write.csv(loggdptsFULL_diff_df, "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/loggdptsFULL_diff_df.csv")

loggdptsFULL_diff_df = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/loggdptsFULL_diff_df.csv", header = TRUE)[2:3]

# Print results
# Just for output h_num viable is introduced (h_num = 1 corresponds to h=1, h_num=3 to h=4, etc)
h_num = 1
start_point = 144 + h_num - gdp_d # 144 is for 2000 Q1
df_var_boost_forecast = data.frame(loggdptsFULL_diff_df[start_point:(start_point+(dim(forecast_result)[1])-1),2] , 
                                   forecast_result)
forecast_ts = ts(df_var_boost_forecast, start=c(2000, 1), frequency = 4)

undiff_df = NULL
gdpFullDiff_undiff = diff(log(gdpdfFull[,2]), differences = 1)

component = gdpFullDiff_undiff[start_point:(start_point + (dim(df_var_boost_forecast)[1]-1))]
x = matrix(c(component, component, component), ncol=3)

for(i in 1:dim(df_var_boost_forecast)[1]){
  temp_ts = ts(df_var_boost_forecast[i,], start=c(2000, 1), frequency = 4)
  #a = as.matrix(x[i:(i+(d-1)), ])
  a = matrix(x[i:(i+(gdp_d-1)), ], ncol=3)
  undiff_ts = diffinv(temp_ts, differences = gdp_d, xi = a)
  undiff_df = rbind(undiff_df, undiff_ts[(gdp_d+1),])
}

undiff_df = cbind(undiff_df, 
                  (undiff_df[,1]-undiff_df[,2])^2, 
                  (undiff_df[,1]-undiff_df[,3])^2)

MSE_var = mean(undiff_df[,4])
MSE_gamboost_y = mean(undiff_df[,5])

undiff_ts = ts(undiff_df, start=c(2000, 1), frequency = 4)
colnames(undiff_ts) = c("true GDP", "VAR", "VAR + GAMboost(Y)", "SqE VAR", "SqE GAMBoost(Y)")
write.csv(undiff_ts, "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/log_diff_d1.csv")
print(undiff_ts)

MSEs = c(MSE_var, MSE_gamboost_y)
names(MSEs) = c("MSE_VAR", "MSE_GAMBoost(Y)")

print(MSEs)


