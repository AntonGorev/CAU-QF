#################### Stationarity ###########################
all_var_ts = ts.union(loggdpts, quarterlyts)
all_var_ts_FULL = ts.union(loggdptsFULL, quat_ts_FULL) # testing
d = NULL
for(i in 1: dim(all_var_ts)[2]){
  d[i] = ndiffs(all_var_ts[, i], alpha = 0.05, test = c("adf"))
}

d = max(d)
all_var_diff_ts = diff(all_var_ts, differences = d)
all_var_diff_df = data.frame(date=as.Date(as.yearqtr(time(all_var_diff_ts))), all_var_diff_ts)
colnames(all_var_diff_df) = c("date","logGDP", colnames(quarterlyts))

#testing_FULL_diff_ts = diff(all_var_ts_FULL, differences = d) #testing
#FULL_diff_df = data.frame(date=as.Date(as.yearqtr(time(testing_FULL_diff_ts))), testing_FULL_diff_ts)
#colnames(FULL_diff_df) = c("date","logGDP", colnames(quarterlyts))

# Perform variable selection with Lasso
# selected_lasso_variab = ezlasso(all_var_diff_df[,-1], "logGDP", folds=10, alpha = 0.9, maxnrvar=20)
# selected_lasso_variab_FULL = ezlasso(FULL_diff_df[,-1], "logGDP", folds=10, alpha = 0.9, maxnrvar=25)
# write.csv(selected_lasso_variab_FULL, 
#           "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/variables.csv")
dream_vars = c("logGDP", "PCEPI", "RPI", "IPFINAL", "IPBUSEQ", "IPMAT", "IPDMAT", 
               "IPNMAT","IPFPNSS","IPFUELN","TCU","MCUMFN","CLF16OV","CE16OV","UNRATE",
               "UEMPMEAN","UEMPLT5","UEMP5TO14","UEMP15OV","UEMP15T26","UEMP27OV","PAYEMS",
               "USPRIV","CES1021000001","USCONS")

selected_variables = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/variables.csv")[2]

# Leave out redundant variables
# VARDiff_df = all_var_diff_df[, selected_lasso_variab]
# VARDiff_df = all_var_diff_df[, dream_vars]
VARDiff_df = all_var_diff_df[, as.vector(selected_variables[1:25,1])]

rm(list = c("i","all_var_ts", "all_var_diff_ts", "all_var_diff_df", 
            "dream_vars"))

