clc
clear

function [V0, Veu, S, q] = UpOutPut_BinMod(S0, r, sigma, T, M, B, K)
    
    delta_t = T / M
    
    // Calculate parameters u/d (up and down movements), beta, and probobilities
    b = 0.5 * (exp(-r * delta_t) + exp((r + sigma^2) * delta_t))
    u = b + sqrt(b^2 - 1)
    d = u^(-1)
    
    q = (exp(r * delta_t) - d) / (u - d)
    q_tilde = (q * u) / exp(r * delta_t)             // -"- for Stock
    
    // Define and calculate matrix of prices (i.e. binomial tree)
    S(1, 1) = S0
    for i = 1 : M
        for j = 0 : i
            S(j+1, i+1) = S0 * u^j * d^(i - j)
        end
    end
    
    size_S = size(S)
    Veu = zeros(size_S(1), size_S(2))
    
    // Calculate option values at maturity
    for i = 1 : size_S(2)
        Veu(i, size_S(2)) = max(K - S(i,$), 0) * ...
                            (S(i, $) < B )      // If barrier is passed, 
                                                //  option price becomes a zero
    end
    
    // Calculate option prices through whole tree (European Put)
    for n = size_S(1):-1:2
        for k = 1 : n - 1
            Veu(k, n - 1) = exp(-r * delta_t) * ...
                            ( (1 - q) * Veu(k, n) + q * Veu(k+1, n) ) * ...
                            (S(k, n - 1) < B )  // If barrier is passed, 
                                                //  option price becomes a zero
        end
    end

    // Calculate American Put
    V0 = max(max(K-S0, 0), Veu(1,1))
    
endfunction


// Test data
S0 = 100
r = 0.05
sigma = 0.2
T = 1
K = 100
B = 110
M = 10

// Test function and display result
V0 = UpOutPut_BinMod(S0, r, sigma, T, M, B, K)
disp("Approximation to the price of an American put option using CRR model is V0 = " ...
      + string(V0))
