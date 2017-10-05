# read GDP csv
gdpdfFull = read.csv("/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/gdp.csv", header = TRUE)
gdpdfFull$date = as.Date(gdpdfFull$date, "%d/%m/%Y")
tslength = dim(gdpdfFull)[1]-68
gdpdf = gdpdfFull[21 : tslength, ]
loggdpts = ts(log(gdpdf[2]), start=c(1964, 1), frequency = 4)
plot.ts(loggdpts)

