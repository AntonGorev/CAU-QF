// C-Exercise 01
// Anton Gorev

clc

// (a)

// read data from csv as double, values in columns are separated with tabs
//  (that was determined by observing data with text editor)
DAX_values = csvRead('time_series_dax.csv', ascii(9), ',', 'double')

// prices are in the first column, so we take that one
s_dax = DAX_values(:,1)

// preparing vector of dates (as serial date number)
DAX_dates = datenum(DAX_values(:,2), DAX_values(:,3), DAX_values(:,4))

//string(datevec(DAX_dates)(1:3))

clf
scf(1) // figure for the first plot

// Define graph parametrs
a=get("current_axes");
x_label=a.x_label
y_label=a.y_label
y_label.text="Prices"
x_label.text="Dates as serial date numbers"
xtitle("DAX (daily data)")

plot(DAX_dates, s_dax)
// plot(string(datevec(DAX_dates)(:,1:3)), s_dax) !!!!!!!!!!!!!!!!!!


// (b)
// Calculate log-return (take a logorithm of prices and then find the
//  difference between previous and current values (diff() does it)
lr = diff(log(s_dax))

clf(2)
scf(2) // figure for the second plot

xtitle("DAX log-returns", "Dates as serial date numbers", "log-returns")
plot(DAX_dates(2:$), lr)


// (c)
clf(3)
scf(3) // figure for the third plot
xtitle("distribution of log-returns", "log-return", "frequency")
histplot(30, lr)


// (d)
// so since we assume normal distribution we can use mean() and variance() functions 
// to obtain mu and sd
lr_mean = mean(lr)
lr_sd = sqrt(variance(lr))

disp("Assuming the normal distribution and identical independence of " + ...
     "log-returns the best estimate for the mean and SD would be" + ...
     " arifmetical mean - " + string(lr_mean) + " and squaer root from " + ...
     "variance - " + string(lr_sd) + " respectively")
