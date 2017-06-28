clc 
clear

function [V0, c1, c2] = Heston_EuCall_MC_Euler(S0, r, gamma0, kappa, lambda, sigma_tilde, T, g, M, m)
    
    clf
    scf(0)
    xtitle('Simulated paths of Eu Call Option for ' + string(m) + ' steps', 'm', 'V')
    
    V_hat = []                      // Define vectore for Monte Carlo estimates
    
    // Launch M number of Monte Carlo Simulations.
    // For Each simmulation two normaly distributed random vector
    //  are generated (for underline asset price and volatility)
    for k = 1 : M

        // Set the increment for equidistance grid
        delta_t = T / m
        
        // Create two different Weiner processes (which might be in fact correlated, but we don't 
        //  handle it for now)
        delta_W_vol = grand(m, 1, 'nor', 0, sqrt(delta_t))
        delta_W_S = grand(m, 1, 'nor', 0, sqrt(delta_t))
        
        // Define vector to store volatility and stock price paths 
        Vol_Euler(1) = gamma0
        S_Euler(1) = S0
        
        // Simulate processes with Euler method
        for i = 1 : m 
                         
            Vol_Euler(i + 1) = Vol_Euler(i) + ... 
                               (kappa - lambda * max(0, Vol_Euler(i))) * delta_t + ... 
                               sigma_tilde * sqrt(max(0, Vol_Euler(i))) * delta_W_vol(i)
            
            S_Euler(i + 1) = S_Euler(i) + r * S_Euler(i) * delta_t + ...
                             sqrt(max(0, Vol_Euler(i))) * S_Euler(i) * delta_W_S(i)
                             
            // In this case we have a good opportunity to compute exact value
            //S_Euler(i + 1) = S0 * exp(sum( (r - 0.5 * Vol_Euler(i)) * delta_t + ...
            //                 sqrt(Vol_Euler(i)) * delta_W_S(i)))
                             
            // S_Euler(i + 1) = S_Euler(i) * exp(r - 0.5 * Vol_Euler(i)) * delta_t + ...
            //                 sqrt(Vol_Euler(i)) * sqrt(delta_t) * delta_W_S(i)
            
        end
        
        if modulo(k, 1000) == 0 then
            plot2d(S_Euler)
        end
        
        // Matrix M by m for storing all M number of paths of option price.
        // We calculate payoff for each Monte Carlo simulation
        //V_hat(:, k) = g(S_Euler)
        
        V_hat(k) = g(S_Euler($))
        
    end
    
    // Vector of "mean path" (average among all Monte Carlo simulations)
    //V_hat_mean = []
    
    //for i = 1 : (m + 1)
        
    //    V_hat_mean(i) = mean(V_hat(i, :))
    
    //end
    
    V0 = mean(V_hat)
    
    //var_hat = variance(V_hat($, :))
    
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

m = 500
M = 10000

[V0, c1, c2] = Heston_EuCall_MC_Euler(S0, r, gamma0, kappa, lambda, sigma_tilde, T, g, M, m)
disp("Price of the European Call in the Heston model " + string(V0))
