function V0 = BS_Price_Int (r, sigma, S0, T, g)
      
    // Specify integrand for integration formula.
    function y = integrand (x)
        y = 1/sqrt(2*%pi) * g( S0*exp((r-0.5*sigma^2)*T + sigma*sqrt(T)*x) ) * exp(-r*T) * exp(-x^2/2);
    endfunction
    
    // Perform integration. To approximate the indefinite integral from -inf to +inf, we have to cut
    // the domain of integration. E.g., we can use fixed numbers like -50 and 50, which works quite
    // well for calls7puts with reasonable strikes. An alternative would be an adaptive approach or tan-substitution.
        
    V0 = intg(-10, 10, integrand);
    
 
    
endfunction

