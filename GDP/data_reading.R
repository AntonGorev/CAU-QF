# Part 1
############## Preparing data sets (reading, aggregating, etc.) ##############
file.dir = dirname(sys.frame(1)$ofile)

# read from csv
monthly = read.csv(paste(file.dir, '/cleanvars1964Full.csv', sep = '', collapse = NULL), header = TRUE)
# monthly = read.csv('/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/cleanvars1964Full.csv', header = TRUE)

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

# Define baseline sample (1,...,T1-h)
quarterly = quarterlyFull[1 : (dim(quarterlyFull)[1]-(67+h)), ] # 68 is 17 years x 4 quarters (leave only "observed" data)

# Define forecast sample (T1,...,T2)
quarterly_forecast = quarterlyFull[ -(1 : (dim(quarterlyFull)[1]-68)), ]

# read GDP csv
file.dir = dirname(sys.frame(1)$ofile)
gdpdfFull = read.csv(paste(file.dir, '/gdp1964.csv', sep = '', collapse = NULL), header = TRUE)
gdpdfFull$date = as.Date(gdpdfFull$date, "%d/%m/%y")
gdpdf = gdpdfFull[1 : (dim(gdpdfFull)[1]-(67+h)), ]       # training sample
qdp_forecast = gdpFull[ -(1 : (dim(gdpFull)[1]-68)), ]   # forecast sample

# Preparing TS objects
loggdpts = ts(log(gdpdf[2]), start=c(1964, 1), frequency = 4, names = "logGDP")
quarterlyts = ts(quarterly[-1], start=c(1964, 1), frequency = 4)
loggdptsFULL = ts(log(gdpdfFull[2]), start=c(1964, 1), frequency = 4, names = "logGDP") # For testing purpose
#plot.ts(loggdpts)

# Remove redundant data from working Environment
rm(list = c("monthly", "monthlyts", "removeNAbefore", "i", "file.dir"))
