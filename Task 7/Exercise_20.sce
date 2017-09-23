clc
clear

// Calculate sigma to calibrate Black-Scholes
function sigma = BS_EuCall_Calibrate (S0, r, T, K, V, sigma0)
    
    // Black-Scholes closed form pricing model at t = 0
    function V0 = BS_EuCall_0(sig)
    
        d1 = (log(S0 ./ K) + r .* T + 0.5 .* T .* sig^2) ./ (sig .* sqrt(T))
        d2 = (log(S0 ./ K) + r .* T - 0.5 .* T .* sig^2) ./ (sig .* sqrt(T))
        
        Phi1 = cdfnor('PQ', d1, zeros(d1), ones(d1))
        Phi2 = cdfnor('PQ', d2, zeros(d2), ones(d2))
        
        V0 = S0 .* Phi1 - K .* exp(-r .* T) .* Phi2
    
    endfunction
    
    // Define loss function
    function l = loss(sig)
        l = V - BS_EuCall_0(sig)
    endfunction
    
    // Minimize loss function and get sigma
    [fopt, sigma] = leastsq(loss, sigma0)
    
endfunction

// Black-Scholes closed form pricing model at time t with calibrated sigma
function Vt = BS_EuCall(S0, r, T, K, t, sigma)
    
    d1 = (log(S0 ./ K) + r .* (T - t) + 0.5 .* (T - t) .* sigma^2) ./ ... 
         (sigma .* sqrt(T - t))
    
    d2 = (log(S0 ./ K) + r .* (T - t) - 0.5 .* (T - t) .* sigma^2) ./ ... 
         (sigma .* sqrt(T - t))
        
    Vt = S0 .* cdfnor('PQ', d1', zeros(1:length(d1)), ones(1:length(d1))) - ...
         (K .* exp(-r .* (T - t)) .* ...
         cdfnor('PQ', d2', zeros(1:length(d2)), ones(1:length(d2)))')'
    
endfunction

// Test data

// read data, assigne variable of Strike price, Maturity, Current option price
DAX_data = csvRead('Dax_CallPrices_Eurex20170601.csv', ';', ',', 'double')
K = DAX_data(2:$, 1)
T = DAX_data(2:$, 2)
V = DAX_data(2:$, 3)

r = 0
sigma0 = 0.3
S0 = 12658

sigma = BS_EuCall_Calibrate(S0, r, T, K, V, sigma0)
