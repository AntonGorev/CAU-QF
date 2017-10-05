library(tseries)
library(forecast)
library(mboost)

# VAR ONLY FOR GDP

# Part 1
############## Preparing data sets (reading, aggregating, etc.) ##############
gdpdfFull = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/gdp1964.csv", header = TRUE)
gdpdfFull$date = as.Date(gdpdfFull$date, "%d/%m/%y")
h = 1 # Horizont (one quarter)
gdpdf = gdpdfFull[1 : (dim(gdpdfFull)[1]-(68-h)), ]

loggdpts = ts(log(gdpdf[(1:(dim(gdpdf)[1]-h)), 2]), start=c(1964, 1), frequency = 4, names = "logGDP")
loggdpts_boost = ts(log(gdpdf[(1:(dim(gdpdf)[1]-h-1)), 2]), start=c(1964, 1), frequency = 4, names = "logGDP")
tail(loggdpts_boost)
plot.ts(loggdpts)

Box.test(loggdpts, lag = 20, type = "Ljung-Box")
adf.test(loggdpts, k = 0)

#d = ndiffs(loggdpts, alpha = 0.05, test = c("adf"))
gdplog_diff = diff(loggdpts, differences = 1)
gdplog_diff_boost = diff(loggdpts_boost, differences = 1)
plot.ts(gdplog_diff)

Box.test(gdplog_diff, lag = 20, type = "Ljung-Box")
adf.test(loggdpts, alternative = "stationary")

# Lag optimisation
# VARsel = VARselect(gdp_diff, lag.max = 40, type = "both")
VARsel = VARselect(loggdpts, lag.max = 40, type = "none")
#p_order = VARsel$selection[1]
p_order = 20 # temporary

# Vector autoregression with lags set according to results of lag optimisation. 
# var = VAR(gdp_diff, p=p_order)
# my_arima_boost = arima(gdplog_diff_boost, order=c(2,0,0))
# my_arima = arima(gdplog_diff, order=c(2,0,0))

my_ar_boost = ar(gdplog_diff_boost, aic = TRUE)
my_ar = ar(gdplog_diff, aic = TRUE)

#Forecasting
# forecast_arima_boost = forecast(my_arima_boost, h = h)
# forecast_arima = forecast(my_arima, h = h)

pred_ar_boost = predict(my_ar_boost, n.ahead = 1, ci = 0.95, dumvar = NULL)
pred_ar = predict(my_ar, n.ahead = h, ci = 0.95, dumvar = NULL)
print(pred_ar_boost$pred)
print(pred_ar$pred)

boost_gdp_log_diff = data.frame(date=as.Date(as.yearqtr(time(gdplog_diff))), gdplog_diff)
#boost_gdp_log_diff = boost_gdp_log_diff[ (dim(boost_gdp_log_diff)[1]-p_order) :
#                                           dim(boost_gdp_log_diff)[1], ]


colnames(boost_gdp_log_diff) = c("date", "logGDPdiff")

y_t_AR = as.vector(pred_ar_boost$pred)
y_t_h_AR = as.vector(pred_ar$pred)


# Fit GAMBoost
gamboost()


j = 1
fcst = NULL   # variable for storing forecast
while(j <= h){
  Y_hat_boost = rep(y_t_h_AR[j], dim(boost_gdp_log_diff)[1])  # use Y horisont for result
  
  boost_gdp_log_diff$y_resid = 
    boost_gdp_log_diff$logGDPdiff[dim(boost_gdp_log_diff)[1]] - y_t_AR[j] # create residual column to reress then (y_t = model_t)
  
  v = 0.01
  
  
  
  for(t in 1:100){
    fit = lm(y_resid~bs(logGDPdiff),data = boost_gdp_log_diff)
    pred_boost = predict(fit, newdata = boost_gdp_log_diff)
    boost_gdp_log_diff$y_resid = boost_gdp_log_diff$y_resid - v*pred_boost
    Y_hat_boost = cbind(Y_hat_boost, v*pred_boost) 
  }
  
  fcst[j] = sum(Y_hat_boost[dim(Y_hat_boost)[1], ])
  
  j = j + 1
}

fcst_df = data.frame(y_t_AR, fcst)
fcst_ts = ts(fcst_df, start=c(2000, 1), frequency = 4)
x = matrix(c(loggdpts[144], loggdpts[144]), ncol = 2)
undiff = diffinv(fcst_ts, differences = 1, xi=x)
undiff = data.frame(date=as.Date(as.yearqtr(time(fcst_ts))), log(gdpdf[ dim(gdpdf)[1], 2]), undiff)
colnames(undiff) = c("date","true GDP", "fcst AR", "frcst Boost")
exp(undiff[,2:4])

# names(fcst) = c("2000 Q1", "2000 Q2", "2000 Q3", "2000 Q4")
print(fcst)
result = data.frame(gdpdf[145, ], exp(fcst))
print(result)




dream_vars = c("logGDP", "PCEPI", "RPI", "IPFINAL", "IPBUSEQ", "IPMAT", "IPDMAT", 
               "IPNMAT","IPFPNSS","IPFUELN","TCU","MCUMFN","CLF16OV","CE16OV","UNRATE",
               "UEMPMEAN","UEMPLT5","UEMP5TO14","UEMP15OV","UEMP15T26","UEMP27OV","PAYEMS",
               "USPRIV","CES1021000001","USCONS")