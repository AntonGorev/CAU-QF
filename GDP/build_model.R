p=p_AIC-1
if(n==1){ 
  p = rep(6,146) # it is p-1 in fact
}


adl_predictors = names(work_data_diff[,-1])
adl_formula = as.formula(paste("logGDP ~ L(logGDP,", h,":", h+p[1], ") +", 
                               paste("L(", adl_predictors, ",", h,":", h+p[-1], ")", 
                                     sep = '', 
                                     collapse = "+") ))

# Shift test and training periods
if( t != 0){
  q_t = current_Q + t
  q = q_t %% 4
  
  if(q == 1){
    year = year + 1
  }
  if(q == 0){
    q = 4
  }
}else{
  q = current_Q
}

adl_train = dynlm(formula = adl_formula, data = work_data_diff_ts, start = c(1964, (1+d)), end = c(year, q))

boosting_data = as.data.frame(adl_train$model[1])
names(boosting_data) = "logGDP"
for( i in 2 : dim(adl_train$model)[2] ){
  temp_df = as.data.frame(adl_train$model[,i])
  names(temp_df) = paste(names(work_data_diff[i-1]), ".",
                         paste("l", h:(h+p[i-1]), sep = ''), 
                         sep = '')
  boosting_data = cbind(boosting_data, temp_df)
}

################ Fitting GAMBoost model ################ (only relevant for t=0, then only predict is considered)
# Experimentally has been found that mstop should be set as 16 or 19
adl_gamboost_model = gamboost(logGDP ~ ., baselearner = "bbs", dfbase = 5, data = boosting_data, control = boost_control(mstop = 16))
#adl_gamboost_model = gamboost(logGDP ~ ., baselearner = "bbs", data = boosting_data, control = boost_control(mstop = 16))
names(coef(adl_gamboost_model)) # selected baselearners at specified ittereations
#cvm = cvrisk(adl_gamboost_model) # default method is 25-fold bootstrap cross-validation
#plot(cvm)
  
# adl_gamboost_model[mstop(cvm)] # set the model automatically to the optimal mstop
# names(coef(adl_gamboost_model))

############### Fit AR(1) #################
AR_ts = ts(work_data_diff[1], start=c(1964, (1+d)), end = c(year, q), frequency = 4)
AR_1 = arima(AR_ts, order = c(1, 0, 0))

############# Extract data to perform predictsion ##############
adl_formula_test = as.formula(paste("logGDP ~ L(logGDP, ", 0,":", p[1], ") +", 
                                    paste("L(", adl_predictors, ",", 0,":", p[-1], ")", 
                                          sep = '', 
                                          collapse = "+") ))

adl_test = dynlm(formula = adl_formula_test, data = work_data_diff_ts, start = c(year-10, q), end = c(year, q))

lagged_data = as.data.frame(adl_test$model[1])
for( i in 2 : dim(adl_test$model)[2] ){
  temp_df = as.data.frame(adl_test$model[,i])
  names(temp_df) = paste(names(work_data_diff[i-1]), ".",
                         paste("l", h:(h+p[i-1]), sep = ''), 
                         sep = '')
  lagged_data = cbind(lagged_data, temp_df)
}

lagged_data = lagged_data[,-1]


############# Prediction ##############
gamboost_predict = predict(adl_gamboost_model, lagged_data[dim(lagged_data)[1], ]) # boosting
AR_1_forecast = forecast(AR_1, h=h)   # forecasting with arima

result_df = data.frame(work_data_diff[143+t, 1], gamboost_predict, (work_data_diff[143+t, 1] - gamboost_predict)^2,
                       AR_1_forecast$mean[h], (work_data_diff[143+t, 1] - AR_1_forecast$mean[h])^2)

