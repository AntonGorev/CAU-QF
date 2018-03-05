// C-Exercise 18
// Alexander Georges Gretener
// Henriette Ries
// (a)

clear; clc; scf(0); clf(0);

// Define function for VaR & ES
function [VaR, ES] = VaR_ES_historic_biv (x_data, l, alpha)
// Calculate length of Return Matrix and initialize Loss Vector
n = size(x_data,1);
Loss = zeros(n,1);

// Compute the Loss via inserting the Risk Factor Changes into the loss operator
for m = 1:n
Loss(m) = l(x_data(m,:)');
end

// Sort Losses
Loss_sorted = gsort (Loss, "g", "d");

// Compute VaR and ES as in the univariate case
VaR = Loss_sorted(floor(n*(1-alpha))+1);
ES = 1/(floor(n*(1-alpha))+1)*sum(Loss_sorted(1:floor(n*(1-alpha))+1));
endfunction

// (b)
// Set Confidence Level alpha
alpha = 0.99;

// Read Stock Returns and combine them to Matrix s
s1 = csvRead('./time-series-dax-sp500.csv', ';', ".", "double", [], [], [], 1)(:,2)
s1 = flipdim(s1,1);
s2 = csvRead('./time-series-dax-sp500.csv', ';', ".", "double", [], [], [], 1)(:,3)
s2 = flipdim(s2,1);
s =[s1, s2];

// Compute Returns and combine them to Matrix x
x1 = log(s(2:$,1)./s(1:$-1,1));
x2 = log(s(2:$,2)./s(1:$-1,2));
x = [x1, x2];

// Initialize Vectors for VaR, ES, Loss and Violations
VaR = zeros(size(s,1));
ES = zeros(size(s,1));
Loss = zeros(size(s,1));
Violations = zeros(size(s,1));

// Set the Portfolio Value and Weighting at Initialisation
V = 1000;
phi1 = 0.5*V/s(1,1);
phi2 = 0.5*V/s(1,2);

// Loop over all Trading Days since we want to rebalance the PF from beginning on
// Set an If statement from Trading Day 254 on to compute VaR, ES and Loss
for i= 2:size(s,1)
    if (i>=254) then

        // Compute the effective Loss of the PF via the weighted stock prices
        Loss(i) =  phi1*(s(i-1,1)-s(i,1)) +  phi2*(s(i-1,2)-s(i,2));
        
        // Set the Loss Operator
        function y=l(x)
            y = phi1*s(i-1,1)*(1-exp(x(1))) + phi2*s(i-1,2)*(1-exp(x(2)))
        endfunction
        
        // Compute VaR and ES
        [VaR(i), ES(i)] = VaR_ES_historic_biv (x(i-252:i-1,:), l, alpha);

        // Check if there is a Violation
        Violations(i) = VaR(i) < Loss(i)
    end

    // Rebalance Portfolio to 50% DAX, 50% SPX
    V = phi1*s(i,1) + phi2*s(i,2);
    phi1 = 0.5*V/s(i,1);
    phi2 = 0.5*V/s(i,2);
end

// Display Expected and Actual Violations
disp("Expected Violations: "+string((1-alpha)*(size(s,1)-253))+", Actual Violations: "+string(sum(Violations)));

// Plot Loss, VaR and ES
plot(Loss(254:$), "+k");
plot (VaR(254:$), "r");
plot (ES(254:$), "b");
title ('VaR and ES for Bivariate Historical Simulation');
xlabel('Trading Day');
ylabel('Value');
legend("Loss", "VaR", "ES");

// Historical Simulation seems to yield better results, altough changes in Volatility 
// seem only to be picked up with a certain Delay
