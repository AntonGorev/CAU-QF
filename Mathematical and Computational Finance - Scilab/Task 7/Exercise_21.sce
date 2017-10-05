clc
clear

function [V0, c1, c2] = EuOption_BS_MC(S0, r, sigma, T, K, M, g)
    
    // According 3.11 the price of underline stock at T is:
    W_Q = grand(M, 1, 'nor', 0, sqrt(T))        // Simulate Wiener process, 
                                                //  with variance T, to create
                                                //  M Monte Carlo prices
    S_T = S0 * exp((r - 0.5 * sigma^2) * T + sigma .* W_Q)
    
    V_hat = exp(-r * T) .* g(S_T, K)
    V0 = mean(V_hat)
    Var_V_hat = variance(V_hat) 
    
    // Since we need to determine 95% confidence interval, the s.d. is 1.96
    c1 = V0 - 1.96 * sqrt(Var_V_hat/M)
    c2 = V0 + 1.96 * sqrt(Var_V_hat/M)
    
endfunction

// Define payoff
function payoff = g(x, K)
    payoff = max(K - x, 0)
endfunction

// Test data
K = 100
S0 = 95
r = 0.05
sigma = 0.2
T = 1
M = 1000

[V0, c1, c2] = EuOption_BS_MC(S0, r, sigma, T, K, M, g)
disp('Eu Put Price V0 = ' + string(V0))
disp('95% Confidence interval is [' + string(c1) + ', ' + string(c2) + ']')
