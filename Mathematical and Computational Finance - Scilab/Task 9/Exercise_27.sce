clc
clear

function [X_exact, X_Euler, X_Milshtein] = Sim_Paths_GeoBM(X0, mu, sigma, T, N)
    
    delta_t = T / N
    
    // Create vector of independent std. normal random variables with a variance 
    //  of delta_t
    delta_W = grand(N, 1, 'nor', 0, sqrt(delta_t))
    
    // Define and initialize vectors for storing results    
    X_Euler(1) = X0
    X_exact(1) = X0
    X_Milshtein(1) = X0
    
    // Simulate processes for each step
    for i = 1 : N 
        
        // Y stands for the process in the exponent of (3.11) which is 
        //  the solution for the given stochatsic differential equation
        Y = sum( (mu - 0.5 * sigma^2) * delta_t + ...
                  sigma * delta_W(1:i) )
        
        X_exact(i + 1) = X0 * exp(Y)
                     
        X_Euler(i + 1) = X_Euler(i) + mu * X_Euler(i) * delta_t + ... 
                         sigma * X_Euler(i) * delta_W(i)
        
        X_Milshtein(i + 1) = X_Milshtein(i) + mu * X_Milshtein(i) * delta_t + ...
                             sigma * X_Milshtein(i) * delta_W(i) + ...
                             0.5 * sigma * X_Milshtein(i) * sigma * ... 
                             ((delta_W(i))^2 - delta_t)
        
    end
   
endfunction

//Test data
X0 = 100
mu = 0.05
sigma = 0.2
T = 2
N = [10, 100, 1000, 10000]

// Prepare plotting setups
clf
scf(0)
a = gca()
a.tight_limits = 'on'
a.auto_scale = 'on'

// Call function with test data and Plot results in the matrix view.
// We are walking throught the for loop, calling function for each N.
for i = 1 : length(N)
    
    [X_exact, X_Euler, X_Milshtein] = Sim_Paths_GeoBM(X0, mu, sigma, T, N(i))
    subplot(2,2,i)
    plot2d([0 : N(i)],[X_exact, X_Euler, X_Milshtein],[1, 2, 3])
    xtitle('Simulated paths for ' + string(N(i)) + ' steps', 'N', 'X')
    legends(['Exact';'Euler';'Milshtein'],[1, 2, 3], opt="lr")
    
end


