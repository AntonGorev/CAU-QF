clc
clear

function [y_hat, theta_hat] = cubic_regression(x, y)
    
    // Define matrix of regressors
    X = [,]
    
    for i = 1 : length(x)
        for j = 1 : 4
            X(i, j) = x(i)^(4 - j)
        end
    end
    
    // Calculate vector of coefficients and estimates
    theta_hat = inv(X'*X)*X'*y
    
    y_hat = X * theta_hat
    
endfunction

// Test values
x = [0; 1; 2; 3; 4]
y = [1; 0; 3; 5; 8]

y_hat = cubic_regression(x, y)

// Plot regression result on test data
clf(0)
scf(0)
plot(x, y, '-', x, y_hat,'.')
a = gca()
a.tight_limits = 'off'
a.data_bounds = [-1, -1; 5, 9]
xtitle('x agains y', 'x', 'y')
