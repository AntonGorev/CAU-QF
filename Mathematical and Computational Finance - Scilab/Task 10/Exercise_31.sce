clc
clear

function [V0, V0_exact] = BS_EuPut_FiDi_Explicit(r, sigma, a, b, m, nu_max, T, K)
    
    t_max = T * 0.5 * sigma^2
    delta_x = (b - a) / m
    delta_t = t_max / nu_max
 
    // Set initial condition
    q = 2 * r / sigma^2 
    y0 = zeros(m - 1)
    
    i = 0 : m
    x_tilde = a + i .* delta_x
    i = 1 : m - 1  // redefine i
    //x = K .* exp(a + i .* delta_x)
    //x_tilde = log(x ./ K)
    
    y0 = max(exp(0.5 .* x_tilde .*(q - 1) - exp(0.5 .* x_tilde .*(q + 1))), 0)
    
    V0 = y0 .* K .* exp(-0.5 * (q - 1) .* x_tilde - (0.25 * (q - 1)^2 + q) * 0.5 * sigma^2 * (T - 1))
    
    
    ////////// Exact (3.23) //////////
    S_t = K .* exp(a + i .* delta_x)
    t = 0
    d1 = (log(S_t ./ K) + r * (T - t) + 0.5 * sigma^2 * (T - t)) ./ ...
         (sigma * sqrt(T - t))
        
    d2 = (log(S_t ./ K) + r * (T - t) - 0.5 * sigma^2 * (T - t)) ./ ...
         (sigma * sqrt(T - t))
         
    V0_exact = K * exp(-r * (T - t)) * cdfnor('PQ', -d2, zeros(d2), ones(d2)) - ...
               S_t .* cdfnor('PQ', -d1, zeros(d1), ones(d1))
    
endfunction


// Test data
r = 0.05
sigma = 0.2
a = -0.7
b = 0.4
m = 100
nu_max = 2000
T = 1
K = 100

// Call function with the test data
[V0, V0_exact] = BS_EuPut_FiDi_Explicit(r, sigma, a, b, m, nu_max, T, K)
disp("EuPut (explicit finite difference scheme): " + string(V0) + "    " + ...
     "EuPut Exact BS: " + string(V0_exact))
