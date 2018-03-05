// C-Exercise 13
// Mykhaylo Cherner
// Anton Gorev

clear
clc
funcprot(0)

// (a)
function y = log_likelihood_GARCH_11(theta, x)
    
    // reserve memory
    n = length(x)
    sigma_sq = zeros(n)

    // set the initial sigma
    sigma_sq(1) = theta(4)^2
    
    // calculate sigma with respect to each risk factor change
    for i = 2 : n    
      sigma_sq(i) = theta(1) + theta(2) * x(i-1)^2 + theta(3) * sigma_sq(i-1)
    end    

    //log likelihood 
    y= -0.5 * ... 
        ( n*log(2*%pi) + ...
             sum(log(sigma_sq)) + ...
             sum((x.^2)./(sigma_sq)) )

endfunction

// (b)
function theta_hat = estimates_GARCH_11(x)
    
    // Use "optim" for non-linear optimization. It is importantto notice that
    //  argmax(L)=argmin(-L), since "optim" aims to find argmin we have to 
    //  provide it -L as an argument. 
    //deff('y = minus_ll(x, theta)', 'y = -log_likelihood_GARCH_11(theta, x)')
    function y = minus_ll(theta, x)
        y = -log_likelihood_GARCH_11(theta, x)
    endfunction
    
    // The optimiser requires a vector of initial parameters for the theta.
    // For GARCH(1,1) one typically use the following
    alpha_1 = 0.1
    beta_init = 0.8
    alpha_0 = variance(x) * (1 - alpha_1 - beta_init)
    theta_init = [alpha_0, alpha_1, beta_init, stdev(x)]'
    
    // Initialize corresponding upper and lower bounds
    small = 1e-6    // We use this variable instead of zero, it is important for                     //  optimization
    
    low = [small, small, small, small]'
    up = [100*abs(mean(x)), 1-small, 1-small, 10*abs(mean(x))]'

    // According to the scilab documentation the NDcots function can be used as 
    //  an external for "optim" to minimize problem where gradient is too 
    //  complicated to be programmed (which is exactly our case).
    
    // We maximize function with respect to theta, while X is given.
    //  If bounds are required, this sequence of arguments must be "b" flaged.
    [f, theta_hat, gopt] = optim( list(NDcost, minus_ll, x), 'b', ...
                                  low, up, theta_init )
 
endfunction



// (c)
function[VaR, ES] = VaR_ES_MC_GARCH_11(l, alpha, theta, x, k, m)
    
    // compute sigma squared as in a function above
    n = length(x)
    sigma_sq = zeros(n)
    sigma_sq(1) = theta(4)^2
    for i = 2 : n    
      sigma_sq(i) = theta(1) + theta(2) * x(i-1)^2 + theta(3) * sigma_sq(i-1)
    end 
    
    // reserve memory for X and sigma monte carlo simulations
    X = zeros(k, m)
    sigma_MC=zeros(k, m)
    
    // simulate m std. norm. variables (vectors)
    Y = grand(k, m, 'nor', 0, 1)
    
    // compute initial k Monte Carlo GARCH(1,1) sigma squared and X,
    //  we use the last x and sigma from the historical data as the previous 
    //  time point
    sigma_MC(:, 1) = theta(1) + theta(2) * x($)^2 + theta(3) * sigma_sq($)
    X(:, 1) = sqrt( sigma_MC(:, 1) ) .* Y(:, 1)
    
    // simulate the remaind (k by m-1) Monte Carlo GARCH(1,1) sigma squared and X
    for i = 2 : m    
      sigma_MC(:, i) = theta(1) + theta(2) * X(:, i-1).^2 + theta(3) * ...
                       sigma_MC(:, i-1)
                       
      X(:, i) = sqrt( sigma_MC(:, i) ) .* Y(:, i)
    end    

    // l - is a function of the loss operator
    // reserve memory 
    loss = zeros(k)
    
    for j = 1 : k
        loss(j) = l( X(j, :) )
    end

    // compute VaR and ES
    loss_sort = gsort(loss)
    VaR = loss_sort(floor( k * (1 - alpha) ) + 1)
    ES = 1 / (floor( k * (1 - alpha) ) + 1) * ...
         sum( loss_sort(1 : floor( k * (1 - alpha) ) +1) )
         
endfunction

// (d)
// set test parameters
alpha = 0.98
k = 1000
m = 5    

// read data from csv
DAX_values = csvRead('time_series_dax.csv', ascii(9), ',', 'double')
s_DAX = DAX_values(:, 1)

//compute log-returns
lr = log( s_DAX(2:$) ./ s_DAX(1:$-1) )

// loss operator
function y = l(x)
    y = s_DAX($) * ( 1 - exp(sum(x)) )
endfunction

theta_hat = estimates_GARCH_11(lr)
[VaR_hat, ES_hat] = VaR_ES_MC_GARCH_11(l, alpha, theta_hat, lr, k, m)

disp('level alpha=' + string(alpha) + ', estimated VaR=' + string(VaR_hat) )
disp('level alpha=' + string(alpha) + ', estimated ES=' + string(ES_hat) )
