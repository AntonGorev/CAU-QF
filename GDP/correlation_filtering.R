# Part 2
################## Use correlation filter to define the subset of ###################
##################    variable for further feature selection      ###################

#################### Stationarity ###########################
all_var_ts = ts.union(loggdpts, quarterlyts)
d = NULL
for(i in 1: dim(all_var_ts)[2]){
  d[i] = ndiffs(all_var_ts[, i], alpha = 0.05, test = c("adf"))
}

d = max(d)
all_var_diff_ts = diff(all_var_ts, differences = d)  
all_var_diff_df = data.frame(date=as.Date(as.yearqtr(time(all_var_diff_ts))), all_var_diff_ts)
colnames(all_var_diff_df) = c("date","logGDP", colnames(quarterlyts))

# calculate correlation matrix
corrMatrix = cor(all_var_diff_df[3:length(all_var_diff_df)])

# find attributes that are highly corrected (ideally >0.75)
# LEARN WHAT IS CUTOFF PARAMETR, AND HOW IT WORKS
highlyCorr = findCorrelation(corrMatrix, cutoff=0.3)

# print indexes of highly correlated attributes
colToRemove = highlyCorr + 2 # plus 1 because at the original dataframe the first columns are date and logGDP

# remove highly correlated variables from data set
VARDiff_df = all_var_diff_df[,-1]
VARDiff_df[colToRemove] = list(NULL)

# plot remained 12 variables (correlation)
#corrSelected = cor(quartReduced[2:length(quartReduced)])
#corrplot(corrSelected, type="lower")

# Remove redundant data from working Environment
rm(list = c("corrMatrix", "highlyCorr", "colToRemove"))