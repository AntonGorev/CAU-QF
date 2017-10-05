
VARDiff_ts = ts(VARDiff_df, start=c(1964, (1+d)), frequency = 4)
# tail(VARDiff_ts)

###################### Fit VAR model ######################
# Lag optimisation
VARsel = VARselect(VARDiff_ts, lag.max = 40, type = "const")
VARsel
p_order = VARsel$selection[1]
#p_order = 14 # according to summary it is safe to take 14-n

# Vector autoregression with lags set according to results of lag optimisation.

var = VAR(VARDiff_ts, p=p_order, type = "const")
var_model_data_boost = var$varresult$logGDP$model   # Matrix which contains model variables and observations
var_boosting = data.frame(var_model_data_boost$y, var$varresult$logGDP$fitted.values)
colnames(var_boosting) = c("y_t", "y_t_hat")

# var_coef = var$varresult$logGDP$coefficients
var_datamat = var$datamat 

#Forecasting
prdVAR = predict(var, n.ahead = h, ci = 0.95, dumvar = NULL)
print(prdVAR$fcst$logGDP[h])
# VAR_forecast = cbind(VAR_forecast, prdVAR$fcst$logGDP[h]) 
VAR_forecast = prdVAR$fcst$logGDP[h] 
#plot(prdVAR, "single")

