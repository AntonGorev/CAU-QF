clc 
clear

function [V0, c1, c2] = Heston_EuCall_MC_Euler(S0, r, gamma0, kappa, lambda, sigma_tilde, T, g, M, m)
    
    clf
    scf(0)
    xtitle('Simulated paths of Eu Call Option for ' + string(m) + ' steps', 'm', 'V')
    
    V_hat = []                      // Define vectore for Monte Carlo estimates

    // Set the increment for equidistance grid
    delta_t = T / m
        
    // Create two different Weiner processes (which might be in fact correlated, but we don't 
    //  handle it for now)
    delta_W_vol = grand(m, M, 'nor', 0, sqrt(delta_t))
    delta_W_S = grand(m, M, 'nor', 0, sqrt(delta_t))
        
    // Define vector to store volatility and stock price paths 
    Vol_Euler(1, 1 : M) = gamma0
    S_Euler(1, 1 : M) = S0
        
    // Simulate processes with Euler method (for each M Monte Carlo simulations)
    for i = 1 : m 
                  
        Vol_Euler(i + 1, :) = Vol_Euler(i, :) + ... 
                              (kappa - lambda * max(0, Vol_Euler(i, :))) * delta_t + ... 
                              sigma_tilde * sqrt(max(0, Vol_Euler(i, :))) .* delta_W_vol(i, :)
            
        S_Euler(i + 1, :) = S_Euler(i, :) + r * S_Euler(i, :) * delta_t + ...
                            sqrt(max(0, Vol_Euler(i, :))) .* S_Euler(i, :) .* delta_W_S(i, :)
            
    end
        
        
    // Vector for storing all M option prices.
    // We calculate payoff for each Monte Carlo simulation
    V_hat = g(S_Euler($, :))
        
    
    V0 = exp(-r * T) * mean(V_hat)
    
    var_hat = variance(V_hat)
    
    c1 = V0 - 1.96 * sqrt(var_hat / M)    
    c2 = V0 + 1.96 * sqrt(var_hat / M)
    
endfunction


function payoff = g(S)
    
    K = 100
    payoff = max(S - K, 0)
    
endfunction

S0=100 
r=0.05 
gamma0=0.2^2 
kappa=0.5 
lambda=2.5 
sigma_tilde=1 
T=1  
R=3

m = 250
M = 10000

[V0, c1, c2] = Heston_EuCall_MC_Euler(S0, r, gamma0, kappa, lambda, sigma_tilde, T, g, M, m)
disp("Price of the European Call in the Heston model " + string(V0))
