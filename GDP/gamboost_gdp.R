################### GAMBosting #####################
var_predictors = names(var_model_data_boost[, names(var_model_data_boost) != "const" ] )           # names of predictors
var_predictors = var_predictors[-1]
var_predictors = paste("bbs(", var_predictors, ")", sep = '')
# var_formula = as.formula(paste("y ~", paste(var_predictors, collapse = "+"), "+ bols(const, intercept=FALSE)"))   # build formula
var_formula = as.formula(paste("y ~", paste(var_predictors, collapse = "+")))

var_gamboost_model = gamboost(formula = var_formula, data = var_model_data_boost, control = boost_control(mstop = 100))

#cvm = cvrisk(var_gamboost_model)
#plot(cvm)
#mstop(cvm)

gamboost_predict = predict(var_gamboost_model)
# Sum of VAR(p) forecast and boosting components
# gamboost_forecast[i] = prdVAR$fcst$logGDP[i,1] + (temp_gamboost_forecast[length(temp_gamboost_forecast)] - 
# var_boosting[ (dim(var_boosting)[1]-(i-1)) , 2] )
gamboost_forecast_temp_h = prdVAR$fcst$logGDP[h] + (gamboost_predict[length(gamboost_predict)] - 
                                                      var_boosting[ (dim(var_boosting)[1]) , 2] )

# gamboost_forecast = cbind(gamboost_forecast, gamboost_forecast_temp_h)
gamboost_forecast = gamboost_forecast_temp_h


############### testing part with only Y
var_gamboost_model = gamboost(y_t ~ bspatial(y_t_hat), data = var_boosting, control = boost_control(mstop = 32))
#cvm = cvrisk(var_gamboost_model)
#plot(cvm)
#mstop(cvm)

gamboost_predict = predict(var_gamboost_model)
# Sum of VAR(p) forecast and boosting components
gamboost_forecast_y_h = prdVAR$fcst$logGDP[h] + (gamboost_predict[length(gamboost_predict)] - 
                                                   var_boosting[ (dim(var_boosting)[1]) , 2] )
gamboost_forecast_y = gamboost_forecast_y_h
##############################
