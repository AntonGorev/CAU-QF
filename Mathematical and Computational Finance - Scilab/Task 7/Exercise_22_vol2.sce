clc
clear

// Acceptance-rejection method
function X = Sample_Beta_AR(alpha1, alpha2, N)
    
    // pdf g(x) has to satisfy f(x) <= C * g(x)
    // If we set g(x) = (1 - x)^(alpha2 - 1) with x in [0,1],
    //  it is easy to see that C = max(f(x)/g(x)) 
    //  is maximized by '1 / beta(alpha1, alpha2)' term.
    // To generate Y ~ g(y) we simulate uniform r.v U1, and solve the following
    //  equation for 'y': U1 = (1 - Y)^(alpha2 - 1)
    function Y = genY()
        Y = 1 - rand(1)^(1/(alpha2 - 1))
    endfunction
    
    // Set Constant C
    C = 1 / beta(alpha1, alpha2)
    
    // Since we are not allowed to use implemented functions we construct 
    //  pdf by known formula of Beta distribution
    function f_y = f(Y)
        f_y = (1 / beta(alpha1, alpha2)) * Y^(alpha1 - 1) * ... 
              (1 - Y)^(alpha2 - 1) .* (Y >= 0 & Y <= 1)
    endfunction
    
    function g_y = g(Y)
        g_y = (1 - Y)^(alpha2 - 1)
    endfunction
    
    // Check acc/rej condition and set X
    for i = 1 : N
        U = rand(1)
        Y = genY()
        
        // If rejected then we sample again until condition is satisfied
        while U > f(Y)/(C * g(Y))
            U = rand(1)
            Y = genY()
        end
        
        X(i) = Y
    end
    
endfunction

// Test data
alpha1 = 2
alpha2 = 3
N = 2000

X = Sample_Beta_AR(alpha1, alpha2, N)

clf(1)
scf(1)
histplot(50, X)
