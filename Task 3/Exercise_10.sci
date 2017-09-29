// C-Exercise 10

// CRR American Put Price
function V0 = CRR_AmPut(S0, r, sigma, T, M, K)
    
    delta_t = T / M
    
    // Calculate parameters u/d (up and down movements), beta, and probobilities
    b = 0.5 * (exp(-r * delta_t) + exp((r + sigma^2) * delta_t))
    u = b + sqrt(b^2 - 1)
    d = u^(-1)
    
    q = (exp(r * delta_t) - d) / (u - d)
    q_tilde = (q * u) / exp(r * delta_t)             // -"- for Stock
    
    // Define and calculate matrix of prices (i.e. binomial tree)
    S = ones(M+1, M+1)      // Reserve memory in prior for faster calculations
    S(1, 1) = S0
    for i = 1 : M
        for j = 0 : i
            S(j+1, i+1) = S0 * u^j * d^(i - j)
        end
    end
    
    size_S = size(S)
    
    V_am = zeros(size_S(1), size_S(2))
    
    // Calculate option values at maturity, initial conditions (use 2.16)
    V_am(:,$) = max( K - S(:, $), 0 )
   
    // Calculate option prices through whole tree (American Put) (use 2.15 for put)
    for n = size_S(2):-1:2
        V_am(1 : n - 1, n - 1) = max( max(K-S(1 : n - 1, n-1), 0), ...
                                 exp(-r * delta_t) * ...
                                 ( q * V_am(2 : n, n) + (1 - q) * V_am(1 : n - 1, n) ) )
    end

    // Calculate American Put (use 2.15 for put)
    // V0 = max(max(K-S0, 0), V_am(1,1))
    V0 = V_am(1,1)
    
endfunction

// (Adaptive step size control for the binomial method
function V0 = CRR_AmPut_Adapt(S0, r, sigma, T, K, M, epsilon)
   
    // Compute prices with M and 2M periods 
    V_M = CRR_AmPut(S0, r, sigma, T, M, K)
    V_2M = CRR_AmPut(S0, r, sigma, T, 2 * M, K)
    
    // Double number of periods until termination condition is reached       
    while ( abs(V_M-V_2M) / V_M >= epsilon)
        
        M = 2*M
        V_M = V_2M;
        
        // Compute new price for double "2M"
        V_2M = CRR_AmPut (S0, r, sigma, T, 2 * M, K)
        
        // disp("Price:" + string(V_2M)+" at number of time steps: " + string(M))
    end
    
    V0 = V_2M
         
endfunction

// test parameters
S0 = 100
r = 0.03
sigma = 0.24
T = 3/4
K = 95
M = 5
epsilon = 0.001

funcprot(0)

// Display price for test parameters.
disp("The put price with adaptive step size control: " + ...
        string(CRR_AmPut_Adapt (S0, r, sigma, T, K, M, epsilon)) )
