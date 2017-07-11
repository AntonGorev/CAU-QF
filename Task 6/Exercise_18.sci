clc
clear

function V0 = BS_EuCall_FFT(S0, r, sigma, T, K, R, N, M)
    
    delta = M / N
    kappa1 = 0
    kappa = kappa1 + ([1:N] - 1) .* (2 * %pi / M)
    
    // Define characteristic function Chi for Black-Scholes (4.7)
    function chi = Chi0(u)    
        chi = exp(%i * u * (log(S0) + r * T) - (%i * u) * (0.5 * sigma^2) * T)
    endfunction
    
    // Define g(u) (4.11)
    function integrand = g(u)
        z = R + %i * u  
        integrand = (1 / (z * (z - 1))) * ...
                    Chi0(u - %i * R) 
    endfunction
    
    
    // Initialize vectore for FFT discretization
    x = zeros(N)
    for n = 1 : N
        x(n) = g(delta * (n - 0.5)) * delta * exp(-%i * (n - 1) * delta * kappa1)
    end
    
    x_hat = fft(x)
    
    V_kappa = (exp(-r * T + (1 - R) * kappa) / %pi) .* ...
              real(x_hat' .* exp(-0.5 * %i * delta * kappa))      
              
    Vkm0(1,:) = V_kappa
    Vkm0(2,:) = exp(kappa)
    
    V0 = interpln(Vkm0, K)
    
endfunction


S0 = 100
r = 0.05
sigma = 0.2
T = 1
K = 80 : 130
R = 1.1
N = 2^11
M = 50

V0 = BS_EuCall_FFT(S0, r, sigma, T, K, R, N, M)
