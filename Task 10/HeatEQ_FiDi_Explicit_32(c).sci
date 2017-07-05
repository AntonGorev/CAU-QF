function w = HeatEQ_FiDi_Explicit_1 (m, nu_max)

    w = zeros(nu_max + 1, m + 1);

    // discretization
    delta_t = 10 / nu_max;
    delta_x = 10 / m;
    lambda = delta_t / delta_x^2;
    x = (0:1:m) * delta_x - 5;

    // boundary conditions
    w(1, :) = exp(-x);
    w(:, 1) = exp(5);
    w(:, m+1) = exp(-5);

    // iterate through time layers
    for nu=1:nu_max
        w(nu+1,2:$-1) = lambda*w(nu,1:$-2) + (1-2*lambda)*w(nu,2:$-1) + lambda*w(nu,3:$);
    end

endfunction


function w = HeatEQ_FiDi_Explicit_2 (m, nu_max)

    w = zeros(nu_max + 1, m + 1);

    // discretization
    delta_t = 10 / nu_max;
    delta_x = 10 / m;
    lambda = delta_t / delta_x      // !!! Change lambda according to new 
                                    //  discritization
    x = (0:1:m) * delta_x - 5;

    // boundary conditions          // !!! We change conditions according (5)
    w(1, :) = exp(-x * 2);
    w(:, 1) = exp(10);
    w(:, m+1) = exp(-10);

    // iterate through time layers  // !!! Change explicit scheme according to (b)
    for nu = 1 : nu_max
        w(nu+1, 2 : $-1) = (1 - lambda) * w(nu, 2 : $-1) + lambda * w(nu, 3 : $)
    end

endfunction
