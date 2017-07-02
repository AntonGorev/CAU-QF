clc
clear

function V_t = BS_Price_DownOut_Call(r, sigma, S_t, T, K, H, t)
    
    V_t = zeros(length(S_t))
    
    if t == T then
        V_T = return(max(0, S_t - K) .* (S_t > H))
    end
        
    // Calcuclate 'd' parametrs to apply BS for barrier options
    d1_1 = (log(S_t ./ K) + (r + 0.5 * sigma^2) .* (T - t)) ./ ...
           (sigma .* sqrt(T - t))
        
    d1_2 = (log((H^2) / K) + (r + 0.5 * sigma^2) .* (T - t)) ./ ...
           (sigma .* sqrt(T - t))
             
    d2_1 = (log(S_t ./ K) + (r - 0.5 * sigma^2) .* (T - t)) ./ ...
           (sigma .* sqrt(T - t))
        
    d2_2 = (log((H^2) / K) + (r - 0.5 * sigma^2) .* (T - t)) ./ ...
           (sigma .* sqrt(T - t))
        
        
    // Apply Black-Scholes formula
    V_t = S_t .* (cdfnor("PQ", d1_1, zeros(1, length(d1_1)), ones(1, length(d1_1))) - ...
          (H ./ S_t).^(1 + 2 * r / sigma^2) .* ... 
          cdfnor("PQ", d1_2, zeros(1, length(d1_2)), ones(1, length(d1_2)))) - ...
          exp(-r .* (T - t)) .* K .* ...
          (cdfnor("PQ", d2_1, zeros(1, length(d2_1)), ones(1, length(d2_1))) - ...
          (H ./ S_t).^(1 - 2 * r / sigma^2) .* ...
          cdfnor("PQ", d2_2, zeros(1, length(d2_2)), ones(1, length(d2_2))))
                  
endfunction

// Test data
r = 0.03
sigma = 0.3
T = 1
H = 80
K = [80, 90, 100, 120]
S_t = [70 : 130]
t = linspace(0, 1, length(S_t))

clf
scf(0)

V_t = zeros(length(S_t), length(t))

for i = 1 : length(K)
    
    for j = 1 : length(t)
        V_t(:, j) = (BS_Price_DownOut_Call(r, sigma, S_t, T, K(i), H, t(j)))'
    end
    
    V_t(:, $) = V_T'
    
    subplot(2,2,i)
    
    surf(t, S_t, V_t)
    
end

