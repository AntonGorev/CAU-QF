# Part 1
############## Preparing data sets (reading, aggregating, etc.) ##############
# file.dir = dirname(sys.frame(1)$ofile)

# read from csv
# monthly = read.csv(paste(file.dir, '/cleanvars1964Full.csv', sep = '', collapse = NULL), header = TRUE)

# Define baseline sample (1,...,T1-h)
test_size = 68 # set 68 to be happy
quarterly = quarterlyFull[1 : ( dim(quarterlyFull)[1] - ( test_size + (h-1) - t ) ), ] # 68 is 17 years x 4 quarters (leave only "observed" data)

#quarterly = quarterlyFull[1 : (dim(quarterlyFull)[1]-((test_size - 1)+h) + t), ] # 68 is 17 years x 4 quarters (leave only "observed" data)

# Define forecast sample (T1,...,T2)
# quarterly_forecast = quarterlyFull[ -(1 : (dim(quarterlyFull)[1]- test_size + t)), ]

# read GDP csv
# file.dir = dirname(sys.frame(1)$ofile)
# gdpdfFull = read.csv(paste(file.dir, '/gdp1964.csv', sep = '', collapse = NULL), header = TRUE)
gdpdfFull$date = as.Date(gdpdfFull$date, "%d/%m/%y")
gdpdf = gdpdfFull[1 : (dim(gdpdfFull)[1]- ( test_size + (h-1) - t ) ), ]       # training sample
# qdp_forecast = gdpdfFull[ -(1 : (dim(gdpdfFull)[1]- test_size + t)), ]        # forecast sample

# Preparing TS objects
loggdpts = ts(log(gdpdf[2]), start=c(1964, 1), frequency = 4, names = "logGDP")
quarterlyts = ts(quarterly[-1], start=c(1964, 1), frequency = 4)

quat_ts_FULL = ts(quarterlyFull[,-1], start=c(1964, 1), frequency = 4) # For testing purpose
loggdptsFULL = ts(log(gdpdfFull[2]), start=c(1964, 1), frequency = 4, names = "logGDP") # For testing purpose
# plot.ts(loggdpts)
