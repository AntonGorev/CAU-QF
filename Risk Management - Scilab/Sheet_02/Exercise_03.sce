// C-Exercise 03
// Anton Gorev

clc
clear
funcprot(0)

// (a)

function v = VaR_log_normal(s, alpha)
    
    // compute risk factor changes i.e. log returns, 
    //  mean and standard deviation
    lr = log( s(2:$) ./ s(1:$-1) )
    mu = mean(lr)
    sigma = sqrt( variance(lr) )
    
    // determine quantile
    q = cdfnor("X", 0, 1, alpha, 1-alpha)
    
    // compute VaR
    v =  s($) * ( 1 - exp(-sigma * q + mu) )     // since we need 1-lpha quantile
                                                //  use hint and (1.5) from script

endfunction

// (b)

// set test parameters
td = 252        // trading days
alpha = 0.98    

// read data from csv as double, values in columns are separated with tabs
//  (that was determined by observing data with text editor)
DAX_values = csvRead('time_series_dax.csv', ascii(9), ',', 'double')

// prices are in the first column, so we take that one
s_dax = DAX_values(:, 1)

N = length(s_dax) // current time point
VaR = zeros(N) // reserve memory for storing VaR
viol = zeros(N) // reserve memory for storing violations

// compute the loss
L = [0; -(s_dax(2:$)-s_dax(1:$-1))]

// Compute VaR for the past traiding year
for i = (td+1) : N
    VaR(i) = VaR_log_normal( s_dax(i-td : i-1), alpha )
    
    // if holds store 1 in not - 0
    viol(i) = VaR(i) < L(i)
end

disp("Ideally we expect that violations will not take place" + ... 
     " more than 2% of cases i.e. " + string( round((1-alpha)*(length(VaR)-td)) ) )
disp("Actual number of violations is: " + string(sum(viol)) )

