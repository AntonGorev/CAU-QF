// C-Exercise 05
// Mykhaylo Cherner
// Anton Gorev

clear; clc;

function y = test_binomial(v, p0, beta)
    m = length(v)                               // Amount of experiments
    s = sum(v)                                  // Amount of successes
    p = 1-cdfbin("PQ", s-1, m, p0, 1-p0)        // P-Value of H0
    y = (p<beta)*1                              // H0 rejection result
endfunction


// Code from C-Exercise 3 to calculate the violation vector
///////////////////////////////////////////////////////////////////////////////
function VaR_alpha = VaR_log_normal(s, alpha)
    difflog_s = diff(log(s))
    mu = mean(difflog_s)                            // mean of the diff log of stock
    sigma = sqrt(variance(difflog_s))               // var of the diff log of stock
    quantile = cdfnor("X", 0, 1, (1-alpha), alpha)  // 1-alpha quantile of std. normal
    VaR_alpha = s($)*(1 - exp(mu + sigma*quantile)) // VaR of the Loss at n+1
endfunction

// b)
// Read csv file and extract the first column
Dax_close_price = csvRead('time_series_dax.csv',ascii(9),",")(:,1) // data is read, ascii(9) is the separator, "," is the decimal
alpha = 0.98
startp = 252

// Calculation of the VaR values and storing in a vector
for i=1:length(Dax_close_price)-startp
    VaR_vec(i) = VaR_log_normal(Dax_close_price(i:(i+startp-1)), alpha)
end

// Calculation of the absolute losses after the first 252 days
Loss_vec = -diff(Dax_close_price(startp:$))

// Compute violation occasions
vio_ind = Loss_vec > VaR_vec
///////////////////////////////////////////////////////////////////////////////

// Conduct the test
t = test_binomial(vio_ind, 1-alpha, 0.05)
if t then result = "reject" else result = "cannot reject"
end
disp("We "+string(result)+" H0:p<=p0, where p0 is 1-alpha! Alpha is "+string(alpha)+".")
