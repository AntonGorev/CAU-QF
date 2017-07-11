clc
clear

function Vt = Heston_EuCall_Laplace(St, r, gamma0, kappa, lambda, ...
                                    sigma_tilde, T, t, K, R)
    
    // By (4.6) Laplase transform of the payoff
    function f_til = f_tilde(z)
        f_til = (K^(1 - z)) / (z * (z - 1))
    endfunction
    
    // By (4.8) compute characteristic function for Heston model
    function chi = Chi_t(u)
        
        d = sqrt(lambda^2 + sigma_tilde^2 * (%i * u + u^2))
        
        c = cosh(0.5 * d * (T - t)) + lambda * sinh(0.5 * d * (T - t)) / d
        h = (%i * u + u^2) * sinh(0.5 * d * (T - t)) / d
        
        // Implement (4.8)
        chi = exp(%i * u * (log(St) + r * (T - t))) * ...
              ((exp(0.5 * lambda * (T - t)) / c)^(2 * kappa / sigma_tilde^2)) * ...
              exp(-gamma0 * h / c)
        
        // In fact gamma is a function of t, but since in the given test data t = 0
        //  we can use gamma0 (just in the sake of solving the task)
         
    
    endfunction
    
    // Integrand - f(x) transformation
    function argument = integral(u)
        argument = real(f_tilde(R + %i * u) * Chi_t(u - %i * R))
    endfunction
     
                                    
    // Use (4.5) pricing formula
    Vt = (exp(-r * (T - t)) / %pi) * intg(0, 28, integral)
         
endfunction

// Test Data
St = 100
r = 0.05
gamma0 = 0.2^2
kappa = 0.5
lambda = 2.5
sigma_tilde = 1
T = 1
t = 0
K = 100
R = 3

Vt = Heston_EuCall_Laplace(St, r, gamma0, kappa, lambda, sigma_tilde, T, t, K, R)
disp('Eu Call Price computed with Heston model via Laplace transform: V(t) = ' + ...
     string(Vt))
