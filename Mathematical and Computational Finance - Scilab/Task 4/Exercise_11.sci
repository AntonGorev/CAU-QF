// C-Exercise 11

// Import price method
exec("./CompFin_2017_SS_BS_Price_Int.sce")

function [Delta, vega, rho, Theta] = BS_Greeks_num(r, sigma, S0, T, g, eps)
    
    // Call price function
    V0 = BS_Price_Int(r, sigma, S0, T, g)
    V_Delta = BS_Price_Int(r, sigma, (1+eps)*S0, T, g)
    V_vega = BS_Price_Int(r, (1+eps)*sigma, S0, T, g)
    V_rho = BS_Price_Int((1+eps)*r, sigma, S0, T, g)
    V_Theta = BS_Price_Int(r, sigma, S0, (1+eps)*T, g)
    
    // Callculate corresponding deriviatives
    Delta = (V_Delta-V0)/(eps*S0)
    vega = (V_vega-V0)/(eps*sigma)
    rho = (V_rho-V0)/(eps*r)
    Theta = -(V_Theta-V0)/(eps*T)
    
endfunction
    
// test parameters
r = 0.05
sigma = 0.2
T = 1
S0 = 50:1:150
eps = 0.00001

// Defining payoff function for put with strike 100
function y = g(x)
    y = max(100 - x, 0)
endfunction

// Initialize vector for Deltas
Delta = ones(S0)
vega = ones(S0)
rho = ones(S0)
Theta = ones(S0)

for i = 1:length(S0)
    [Delta(i), vega(i), rho(i), Theta(i)] = BS_Greeks_num(r, sigma, S0(i), T, g, eps)
end

scf(1)
clf(1)

// Plot with respect to price
subplot(2,2,1)
plot(S0, Delta)
xlabel("S0")
ylabel("Delta")

subplot(2,2,2)
plot(S0, vega)
xlabel("S0")
ylabel("vega")

subplot(2,2,3)
plot(S0, rho)
xlabel("S0")
ylabel("rho")

subplot(2,2,4)
plot(S0, Theta)
xlabel("S0")
ylabel("Theta")
