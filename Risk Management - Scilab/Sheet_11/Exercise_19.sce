// C-Exercise 19
// Mykhaylo Cherner
// Anton Gorev

clear; clc; scf(0); clf(0);

// a) Kendall's tau: tau(X1, X2)
function tau = Kendall(x)
    n = size(x,1);
    tau = 0;
    for k=1:n-1
        for l=k+1:n
            tau = tau + sign((x(k, 1) - x(l, 1)) * (x(k, 2)-x(l, 2)));
        end
    end
    tau = tau / (0.5 * n * (n - 1));
endfunction

// b) Spearman's rho: rho(X1, X2)
function rho = Spearman(x)
    n = size(x, 1);
    // compute ranks for both components
    rank_x1 = rank(x(:, 1));
    rank_x2 = rank(x(:, 2));
       
    // berechne Spearman's rho
    rho = 12 / n / (n ^ 2 - 1) * (rank_x1-0.5*(n + 1))' * (rank_x2 - 0.5 * (n + 1));
endfunction

// c)
// Read csv file and extract the first column
csv_content = csvRead('time_series_dax_SP500_cleanx.csv',";",",")
dax_close_price = csv_content(:, 2);
dax_close_price = flipdim(dax_close_price, 1);

sp500_close_price = csv_content(:, 3);
sp500_close_price = flipdim(sp500_close_price, 1);

// Diff logs
dax_logdiff = diff(log(dax_close_price));
sp500_logdiff = diff(log(sp500_close_price));
stock_logdiff = [dax_logdiff, sp500_logdiff];
stock_logdiff = [dax_logdiff, sp500_logdiff];

// Plot the common daily log returns
subplot(2,1,1);
plot(dax_logdiff, sp500_logdiff, 'o');
// Add Y- and X-axis
plot([min(dax_logdiff) max(dax_logdiff)], [0 0], "r");
plot([0 0], [min(sp500_logdiff) max(sp500_logdiff)], "r");
xlabel("DAX");
ylabel("SP500");
title("Common daily log returns of DAX and SP500 indices");

// d) and still c)
// Estimate the mean mu and covariance matrix Sigma
mu = [mean(dax_logdiff); mean(sp500_logdiff)];
Sigma = cov(stock_logdiff);

// Linear correlation
rho = Sigma(2, 1) / sqrt(Sigma(1, 1)) / sqrt(Sigma(2, 2));

disp("Linear correlation: " + string(rho) + ", Kendall" + ascii(39) + "s tau: "...
     + string(Kendall(stock_logdiff)) + ", Spearman" + ascii(39) + "s rho: "...
     + string(Spearman(stock_logdiff)));

// d) purely
// Simulate n = 6278 iid samples of a N(mu_hat, Sigma_hat) distribution
n = size(csv_content, 1);
y = grand(n, 'mn', mu, Sigma)';

// Plot samples
subplot(2, 1, 2);
plot(y(:, 1), y(:, 2), 'o');
// Add Y- and X-axis
plot([min(y(:,1)) max(y(:,1))], [0 0], "r");
plot([0 0], [min(y(:,2)) max(y(:,2))], "r");
title("Simulation");
xlabel("$Y_1$");
ylabel("$Y_2$");

// Estimate Kendall's tau and Spearman's rho
disp("Simulated Kendall" + ascii(39) + "s tau: "...
     + string(Kendall(y)) + ", simulated Spearman" + ascii(39) + "s rho: "...
     + string(Spearman(y)));
