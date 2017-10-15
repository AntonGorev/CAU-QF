#################### Stationarity ###########################
work_data = data.frame(gdpdfFull[,1], gdpdfFull[,-1], quarterlyFull[,-1])
#work_data = data.frame(gdpdfFull[,1], log(gdpdfFull[,-1]), quarterlyFull[,-1])

d = NULL
for(i in 2: dim(work_data)[2]){
  d[i-1] = ndiffs(work_data[, i], alpha = 0.05, test = c("adf"))
}

work_data_diff = NULL
max_d = max(d)
for(i in 2: dim(work_data)[2]){
  if(d[i-1] != 0){
    temp_vec = diff(log(work_data[,i]), differences = d[i-1])
    #temp_vec = diff(work_data[,i], differences = d[i-1])
  }else{
    temp_vec = work_data[,i]
  }
  work_data_diff = cbind(work_data_diff, temp_vec[ ( (max_d+1) - d[i-1]) : length(temp_vec) ] )
}

d = max(d)
gdp_d = d[1]

work_data_diff = data.frame(work_data_diff)
colnames(work_data_diff) = c("logGDP", colnames(quarterlyFull[-1]))
write.csv(work_data_diff, 
          "/Users/antongorev/Dropbox/Study/Seminar/my tests/GDP/work_data_diff.csv")

work_data_diff = work_data_diff[-120]
work_data_diff_ts = ts(work_data_diff, start=c(1964, (1+d)), frequency = 4)

#VARselect(work_data_diff[1:(dim(work_data_diff)[1]-(68)),1:70], lag.max = 20, type="none")