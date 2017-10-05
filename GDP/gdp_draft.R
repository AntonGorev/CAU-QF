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

#Reading data
source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/init_data.R")

horizont = c(1,2,4,8)   # Forecasting horizon

forecast_result = NULL

horizont = c(1)
h =1 ##########
for(h in horizont){
  
  for( t in 0 : (68 - h) ){

    # Preparing and cleaning data
    source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/prepare_data.R")
  
    # Variable Selection
    source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/variable_selection.R")
    
    # Vector autoregression
    source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/VAR_etc.R")
    
    # Gamboost
    source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/gamboost_gdp.R")
    
    forecast_result = rbind(forecast_result, 
                            c(VAR_forecast, gamboost_forecast_y, gamboost_forecast))
    
    rm(list=setdiff(ls(), c("t", "horizont", "h", "forecast_result", "gdpdfFull", "quarterlyFull", "quarterlyts")))
  }
}

# Results
source("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/results.R") # from 2000 Q1















write.csv(data.frame(gdpdfFull[145:212,], c(0:67)), "/Users/antongorev/Dropbox/Study/Seminar/my tests/print.csv")

ccc_cycle = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/compare.csv")
ccc_single = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/compare2.csv")
rrr = ccc_cycle-ccc_single


############## Dimension reduction ##############

# stdquartely = scale(quarterly[2:length(quarterly)]) # standartize data (exept first column "date")
# quatPCA = prcomp(stdquartely) # perform PCA

# extracting info to decide ow many components to retain
# summary(quatPCA)
# screeplot(quatPCA, type="lines") # consider the slope
# (quatPCA$sdev)^2 # look where variance is bigger than 1 (Kaiser Criterion)
                 #  By Kaiser's criterion we should retain first 10 PC


#quartVAR_df = data.frame(date=as.Date(as.yearqtr(time(quartVARts))), quartVARts)
#quartVAR_df_std = scale(quartVAR_df[,-1])
# Save standartization atributes
#a1 = attr(quartVAR_df_std, "scaled:scale")
#a2 = attr(quartVAR_df_std, "scaled:center")
#quartVARts = ts(quartVAR_df_std, start=c(1964, 1), frequency = 4)












# Чисто тестовый кусок
#var_predictors = names(var_model_data[, names(var_model_data) != c("y", "const")])           # names of predictors
#var_predictors = paste(var_predictors, sep = '')
#var_formula = as.formula(paste("y ~", paste(var_predictors, collapse = "+")))   # build formula
#coef(lm(var_formula, data = var_model_data))

#test_gamboost = gamboost(y~bbs(loggdpts.l1, center = TRUE) + bols(const, intercept=FALSE), data = var_model_data)
#coef(test_gamboost, which = "")




# Unstandartize data back
b <- attr(var_model_data_std, "scaled:scale")
a <- attr(var_model_data_std, "scaled:center")
rx <- var_model_data_std * rep(b, each = nrow(var_model_data_std)) + rep(a, each = nrow(var_model_data_std))
var_model_data_std[14,1] * b[1] + a[1]









#Test for serial autocorrelation using the Portmanteau test
#Rerun var model with other suggested lags if H0 can be rejected at 0.05
serial.test(var, lags.pt = 30, type = "PT.asymptotic") # Learn why it is needed!!!!!!!!!!!

#Granger Causality test
#Does x1 granger cause x2?
for(i in 2 : dim(VARDiff)[2]){
  print('/////////////////////////////////////////')
  print(colnames(VARDiff)[i])
  print(grangertest(VARDiff[,"loggdpts"] ~ VARDiff[,i], order = 16))
}


# convert time series object to data frame
diffDF = data.frame(date=as.Date(as.yearqtr(time(quartRedTsDiff))), quartRedTsDiff)
#colMeans(as.matrix(diffDF[,-1]))
colnames(diffDF)[2] = "logGDP"

# checking for stationarity
Acf(quartRedTsDiff[,1:4], lag.max=20)
Acf(quartRedTsDiff, lag.max=20, plot=FALSE) # get the autocorrelation values


################################################
# train1 = data.frame(quartReduced[1], gdpdf[2], quartReduced[2:length(quartReduced)])
#train1 = diffDF

#set.seed(150)

#train1$ma = EMA(train1$logGDP, 8)
#train1 = train1[-(1:8),]

#train = train1[(1:134),]
#val = train1[(135:142),]

#logGDP = val$logGDP
#val$logGDP = NULL
#Dates = as.Date(as.character(val$date))

#formula = logGDP~(UNRATE + DMANEMP + CES0600000007 + HOUSTS + T1YFF + M2MOWN)*ma

#fit = gbm(var, data = train, n.trees = 100000)

#model = predict(fit, newdata = val, n.trees = 100000)

#df = data.frame(Dates, logGDP, floor(model))
#colnames(df)[3] = "model"

############### Try out XGboosting ################
train1 = diffDF[1:(dim(diffDF)[1]-7),]  # Leave out 2001

set.seed(150)

h = 1 # horizont, h quaters 

train1$ma = EMA(train1$logGDP, h+1)
train1 = train1[-(1:h),]

train = train1[1:(dim(train1)[1]-h),]
val = train1[(dim(train)[1]+1):dim(train1)[1],]

X_train = train[,-(1:2)]
X_test = val[,-(1:2)]

Y_train = train[2]
Y_test = val[2]

xgbtrain = xgb.DMatrix(data = as.matrix(X_train), label = as.matrix(Y_train))
xgModel = xgboost(data = xgbtrain, nround = 10000)
xgModel_gblinear = xgboost(data = xgbtrain, booster = "gblinear", nround = 10000)

preds = predict(xgModel, as.matrix(X_test))
preds_gblinear = predict(xgModel_gblinear, as.matrix(X_test))

df = data.frame(Y_test, preds, preds_gblinear, prdVAR$fcst$loggdpts[1,1])

modelts = ts(df, start=c(2000, 1), frequency = 4)


##################
importance_matrix <- xgb.importance(colnames(xgbtrain), model = xgModel)
print(importance_matrix)
xgb.plot.importance(importance_matrix = importance_matrix[1:20])
