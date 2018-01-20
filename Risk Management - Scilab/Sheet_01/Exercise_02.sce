// C-Exercise 02
// Anton Gorev

clc

// (a)
// define mean and standard deviation
x_mean = 0.0003062
x_sd = 0.0143290

// generate vector of log-returns 
X = grand(6815, 1, 'nor', x_mean, x_sd)

clf(1)
scf(1)

xtitle('simulated Log-Returns', 'time step n', 'log-return')
plot(X)

// (b)
// define initial price
S1 = 1443.20

// define the size of vector of prices
n = length(X) + 1

// Create vectore of cummulative sums of elements of X
//  i.e. each element of X_cs is equal to log(St/S1) where 't' is time point
//  from 2 to n
X_cs = cumsum(X)

// extract St from X_cs
St = S1 * exp(X_cs)

// Concatate vector St and S1
S = cat(1, S1, St)

//plot
clf(2)
scf(2)

xtitle('Stock prices', 'time step n', 'price')
plot(S)
