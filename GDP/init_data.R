# Reading and cleaning initial data
monthly = read.csv('/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/cleanvars1964Full.csv', header = TRUE)
gdpdfFull = read.csv('/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/gdp1964.csv', header = TRUE)

# clean data (remove non-numeric)
for (i in 2:dim(monthly)[2]){
  monthly[,i] <- as.numeric(as.character(monthly[,i]))    # replace all non numeric data with "NA"
}

removeNAbefore = max(which(is.na(monthly), arr.ind=TRUE)[,1]) # find the most recent timeseries with any single NA

monthly = monthly[-(1:removeNAbefore),] # remove every timeseries before timeseries with NA (this part certanly was manually controlled)

# convert data to time series object
monthlyts = ts(monthly, start=c(1964, 1), frequency = 12)

# aggregate data quarterly
quarterlyts = aggregate(monthlyts, nfrequency=4, FUN=mean)

# convert time series object to data frame ([,-1] let us avoid stupid 'time' column)
quarterlyFull = data.frame(date=as.Date(as.yearqtr(time(quarterlyts))), quarterlyts[,-1])

# Remove redundant data from working Environment
rm(list = c("monthlyts", "removeNAbefore", "i"))