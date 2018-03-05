// C-Exercise 16
// Mykhaylo Cherner
// Anton Gorev

clear
clc
funcprot(0)

// (a)
function e = MEF(x, u)
        N_u = sum(x > u)                // number of X exceedes u
        e = 1/N_u * (x - u)' * (x > u)  // empirical mean excess function
endfunction

// (b)
function MEP(x)
    
    x = gsort(x)                        // sort x
    e = zeros(length(x)-1)              // reserve memory for MEF estimate
    
    // compute estimate for all X's as a threshold
    for k=2:length(x)
        e(k-1) = MEF(x, x(k))
    end
    
    // plot MEF
    plot(x(2:$), e)
    
endfunction

// (c)
scf(0) 
clf()

n = 500
subplot(3, 1, 1)
title ("Students-t: 3 degrees of freedom")
xlabel("k") 
ylabel("MEP")
MEP(distfun_trnd(3, n, 1))

subplot(3, 1, 2)
title ("Students-t: 6 degrees of freedom")
xlabel("k") 
ylabel("MEP")
MEP(distfun_trnd(6, n, 1))

subplot(3, 1, 3)
title ("Exponential distr")
xlabel("k") 
ylabel("MEP")
MEP(grand(n, 1, 'exp', 1))


// (d)
function neg_logL = neg_logLikelihood(param, Y, N_u)
    
    b = param(1)
    g = param(2)
    
    neg_logL = (-N_u * log(b) - (1/g + 1 ) * sum(1 + (g/b)*Y)) * (-1)
    
endfunction

function [b, g] = PoT_Est(x, u)
    
    X = x(x > u)
    Y = X - u
    N_u = sum(x > u)
    
    init = [0.1; 0.1]
    
    [f, param, gopt] = optim( list(NDcost, neg_logLikelihood, Y, N_u), init )
    
    b = param(1)
    g = param(2)
    
endfunction

// (e)
function [VaR, ES] = VaR_ES_PoT(x, p, u)
    
    [b, g] = PoT_Est(x, u)
    N_u = sum(x > u)
    
    //b = 3.5
    //g = 0.56
    
    VaR = u + (b/g)*( ( (length(x)/N_u)*(1-p) )^(-g) - 1)
    
    ES = VaR + (b+g*(VaR-u))/(1-g)
endfunction

// (f)
p = 0.99
data = evstr(read_csv("RiskMan_2017-18_WS_Exercise_15_data_set.dat"))
MEP(data)
u = 6

[VaR, ES] = VaR_ES_PoT(data, p, u)
disp('VaR=' + string(VaR) + ', ES=' + string(ES) )
