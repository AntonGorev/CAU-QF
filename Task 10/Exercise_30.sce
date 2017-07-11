clc
clear

function V0 = UpOutPut_BS_MC_Richardson(S0, r, sigma, T, K, B, M, m)
    
    // Compute initial parameters for Euler method
    delta_t = T / (2 * m)

    Y_f = S0
    Y_c = S0
    
    // Simulating random processes for delta_t and 2*delta_t
    delta_W1 = grand((2 * m), M, 'nor', 0, sqrt(delta_t))
    delta_W1_2 = delta_W1(m + 1 : $, : )
    delta_W1 = delta_W1(1 : m,  : )
    
    //delta_W2 = grand((2 * m), M, 'nor', 0, sqrt(delta_t))
    
    // Vectores to track the barrier passing 
    B_flag_f = ones(M)
    B_flag_c = ones(M)
    
    // for-loop goes through the whole paths with m and 2*m steps
    //  for the process Y in coarse and fine grid respectivelly
    // However we only need the price at maturity, so we only store
    //  the last step (each step we make M simulations, for Montecarlo Approach) 
    for i = 1 : m
        
        // We calculate process Y two times in a roll for the fine grid,
        //  since the 'for' loop is defined for coarse grid (m steps)
        Y_f = Y_f + r * Y_f * delta_t + sigma * Y_f .* delta_W1(i, :)
        
        B_flag_f = B_flag_f .* (Y_f < B)         // If at any of MC simulations
                                                //  price has broken the barrier
                                                //  we set the flag

        Y_f = Y_f + r * Y_f * delta_t + sigma * Y_f .* delta_W1_2(i, :)
        B_flag_f = B_flag_f .* (Y_f < B)
        

        Y_c = Y_c + r * Y_c * (2 * delta_t) + sigma * Y_c .* (delta_W1(i, :) + ...
                                                             delta_W1_2(i, :))
        B_flag_c = B_flag_c .* (Y_c < B)
        
    end
    
    
    // Compute payoff using Richardson method
    payoff = mean(2 * max(0, K - Y_f) .* B_flag_f - max(0, K - Y_c) .* B_flag_c)
    V0 = exp(-r * T) * payoff
    
endfunction

// Test data
S0 = 100
r = 0.05
sigma = 0.2
T = 1
K = 100
B = 110
M = 10000
m = 250

V0 = UpOutPut_BS_MC_Richardson(S0, r, sigma, T, K, B, M, m)
disp("Price of UpOutPut BS_MC_Richardson: "+string(V0))
