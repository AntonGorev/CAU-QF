// C-Exercise 10
// Mykhaylo Cherner
// Anton Gorev

clear
clc
funcprot(0)

// (a)

// Define normal pdf
function phi = NormPDF(x, mu, sigma)
    phi = ( 1/sqrt(2*%pi*sigma) ) * exp( -((x-mu)^2)/(2*sigma^2) )
endfunction

// Substitute all parametrs regarding 2.2 of script
function [ VaR, ES ] = VaR_ES_var_covar( x_data, c, w, alpha )
    
    // Compute estimators for the mean and SD
    m_hat = mean( x_data )
    sd = sqrt( variance( x_data ) )
    q = cdfnor( 'X', 0, 1, alpha, 1-alpha )
    
    // Substitute (w'*Var*w = w^2*sd^2)
    VaR = -(c + w * m_hat) + w * sd * q
    ES = -(c + w * m_hat) + w * sd *( NormPDF( q, 0, 1 ) / (1-alpha) )
    
endfunction

// (b)

// set test parameters
td = 252        // trading days
alpha = 0.98    

// read data from csv
DAX_values = csvRead('time_series_dax.csv', ascii(9), ',', 'double')
s_DAX = DAX_values(:, 1)

//compute log-returns
lr = log( s_DAX(2:$) ./ s_DAX(1:$-1) )

// Create arrays to store estimates of ES and VaRs
VaR = zeros(length(lr))
ES = zeros(length(lr))


c = 0       // Set constant = 0

// Call function for specified days
for m = 253 : length(lr)
    w = s_DAX(m) // portfolio only contains DAX index
    [VaR(m+1), ES(m+1)] = VaR_ES_var_covar( lr(m+1-252 : m), c, w, alpha )
end

// Plot results
scf(1)
plot( VaR(254:$), 'r' )
plot( ES(254:$), 'b' )
legend('VaR', 'ES', 'in_upper_left')
title ('Variance-Covariance Method')
xlabel('trading day')

