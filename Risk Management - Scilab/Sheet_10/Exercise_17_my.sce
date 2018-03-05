// C-Exercise 17
// (a)

clear 
clc 

// Define normal pdf
function phi = NormPDF(x, mu, sigma)
    phi = ( 1/sqrt(2*%pi*sigma) ) * exp( -((x-mu)^2)/(2*sigma^2) )
endfunction

// Define function for VaR & ES
function [VaR, ES] = VaR_ES_var_covar (x_data, c, w, alpha)
    
    // Compute mean and covariance
    mu = mean(x_data,"r")
    covar = cov(x_data);
    q = cdfnor( 'X', 0, 1, alpha, 1-alpha )
    
    // Compute VaR and ES according to the linearised loss operator with mult. 
    //  Gaussian RFC
    VaR = -(c + w' * mu') + sqrt(w' * covar * w) * q
    ES = -(c + w' * mu') + sqrt(w' * covar * w) / (1 - alpha) * NormPDF( q, 0, 1 )

endfunction

// (b)
// Set Confidence Level alpha
alpha = 0.99

// Read Stock Returns and combine them to Matrix s
s1 = csvRead('./time-series-dax-sp500.csv', ';', ".", "double", [], [], [], 1)(:,2)
s1 = flipdim(s1,1)
s2 = csvRead('./time-series-dax-sp500.csv', ';', ".", "double", [], [], [], 1)(:,3)
s2 = flipdim(s2,1)
s =[s1, s2]

// Compute Returns and combine them to Matrix x
x1 = log(s(2:$,1)./s(1:$-1,1))
x2 = log(s(2:$,2)./s(1:$-1,2))
x = [zeros(1,2);[x1, x2]]

// Initialize Vectors for VaR, ES, Loss and Violations
VaR = zeros( size(s, 1) )
ES = zeros( size(s, 1) )
Loss = zeros( size(s, 1) )
Violations = zeros( size(s,1 ) )

V = 1000                       // Initial PF value
phi1 = 0.5 * V/s(1, 1)         // 50% in DAX
phi2 = 0.5 * V/s(1, 2)         // 50% in S&P500
phi = [phi1; phi2]

// Loop over all Trading Days since we want to rebalance the PF from beginning on
//  Set an If statement from Trading Day 254 on to compute VaR, ES and Loss
for i = 2 : size(s, 1)
    if (i >= 254) then

        // Compute the effective Loss of the PF via the weighted stock prices
        Loss(i) =  phi1 * ( s(i-1, 1) - s(i, 1) ) + ... 
                   phi2 * ( s(i-1, 2) - s(i, 2) )
        
        // Calculate c and w
        c = 0
        w = s(i-1, :)' .* phi
        
        // Compute VaR and ES
        [VaR(i), ES(i)] = VaR_ES_var_covar( x(i-252 : i-1, :), c, w, alpha )
        
        // Check if there is a Violation
        Violations(i) = VaR(i) < Loss(i)
    end

    // Rebalance Portfolio to 50% DAX, 50% SPX
    V = phi1 * s1(i) + phi2 * s2(i)
    phi1 = 0.5 * V/s1(i)
    phi2 = 0.5 * V/s2(i)
    phi = [phi1; phi2]
end

// Display Expected and Actual Violations
disp("Expected Violations: " + string( (1-alpha) * (size(s, 1)-253) ) + ...
     ", Actual Violations: " + string( sum(Violations) ) )

// Plot Loss, VaR and ES
scf(0) 
clf(0)

plot(Loss(254 : $), "+k")
plot(VaR(254 : $), "r")
plot(ES(254 : $), "b")
title('VaR and ES for Bivariate Variance Covariance Method')
xlabel('Trading Day')
ylabel('Value')
legend("Loss", "VaR", "ES")
