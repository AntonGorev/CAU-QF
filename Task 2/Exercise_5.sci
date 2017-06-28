clc
clear

function V0 = BinMod_EuPut_CF(S0, r, sigma, T, M, K)
    
    delta_t = T ./ M
    
    // Calculate probabilities and parameter 'a' (given)
    b = 0.5 * (exp(-r * delta_t) + exp((r + sigma^2) * delta_t))      // Beta
    u = b + sqrt(b.^2 - 1)
    d = u.^(-1)
    a = ceil((log(K/S0) - M .* log(d)) ./ log(u./d))  // The number of successes observed
    p = (exp(r .* delta_t) - d) ./ (u - d)            // Probability of successes for Bond
                                                      //  Probability of 'up-movement' in each trial
                                                      //  (1-p) is respectively probability of
                                                      //  'down-movement'
    
    p_tilde = (p .* u) ./ exp(r .* delta_t)             // -"- for Stock
    
    // With cdfbin we get probability of success overall in M trials using  
    //  probability p or p_tilde (up-movement in a single trial)
    
    // Calculate option price
    V0 = K * exp(-r * T) * cdfbin("PQ", a-1, M, p, 1-p) - ...
         S0 * cdfbin("PQ", a-1, M, p_tilde, 1-p_tilde)

endfunction

// Test data
S0 = 100
r = 0.05
sigma = 0.2
T = 1
K = 100
M = [10:500]

// Testing and plotting
clf
scf(0)
V0 = BinMod_EuPut_CF(S0, r, sigma, T, M, K);
plot(M, V0, "b.")
xtitle('', 'M range', 'Option price')
