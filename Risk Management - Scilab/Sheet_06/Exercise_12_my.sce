// C-Exercise 12
// Mykhaylo Cherner
// Anton Gorev

clear
clc 
scf(0) 
clf()

// a)
function [VaR, ES] = VaR_ES_historic(x_data, l, alpha)
    
    // Compute loss values vector
    loss_vec = l(x_data)
    
    // Order values in the loss vector
    loss_vec_sort = gsort(loss_vec)
    
    // Calculate position of (1-alpha)+1 -th observation
    pos = floor(length(loss_vec_sort)*(1-alpha))+1
    VaR = loss_vec_sort(pos)
    ES = 1/pos * sum(loss_vec_sort(1:pos))
    
endfunction

// b)

// VaR_ES_var_covar is needed for calculations and is located in this file
exec ("VaR_ES_var_covar.sci", -1);

// Read csv file and extract the first column
Dax_close_price = csvRead('time_series_dax.csv',ascii(9),",")(:,1) // data is read, ascii(9) is the separator, "," is the decimal
alpha = 0.98
startp = 252
x = diff(log(Dax_close_price))

// Reserving memory for VaR_ES_var_covar vectors
VaR_var_covar = zeros(1,length(Dax_close_price))
ES_var_covar = zeros(1,length(Dax_close_price))
// Reserving memory for VaR_ES_historic vectors
VaR_historic = zeros(1,length(Dax_close_price))
ES_historic = zeros(1,length(Dax_close_price))

// Calculation of VaR_ES_historic and VaR_ES_var_covar values and storing in vectors
for i=1+startp:length(x)
    
    c = 0
    s = Dax_close_price(i)
    
    deff("y = l(x)", "y = s * (1 - exp(x))")
    
    // VaR_ES_historic
    [VaR_historic(i+1), ES_historic(i+1)] = VaR_ES_historic(x(i-startp:i-1), l, alpha) 
    
    // VaR_ES_var_covar
    [VaR_var_covar(i+1), ES_var_covar(i+1)] = VaR_ES_var_covar(x(i-startp:i-1), c, s, alpha)
end

// Plot VaR_ES_historic and VaR_ES_var_covar values against trading days
// VaR Subplot
subplot(211)
plot(ES_historic)
plot(VaR_var_covar, 'r')

xtitle('Estimates for VaR at 98% alpha level')
xlabel('Trading days')
ylabel('Dax Performance Points')
legend("Value at Risk var_covar", "Value at Risk historic", "in_upper_left")
       
xgrid(4, 1, 7)
// Show values only for trading days only from 254 to 6816
a=gca()
a.tight_limits='on'
a.data_bounds=[254,6816,0,500]

// ES Subplot
subplot(212)
plot(ES_var_covar)
plot(VaR_historic, 'r')

xtitle('Estimates for ES at 98% alpha level')
xlabel('Trading days')
ylabel('Dax Performance Points')
legend(" Expected Shortfall var_covar" ," Expected Shortfall historic", "in_upper_left")
       
xgrid(4, 1, 7)
// Show values only for trading days only from 254 to 6816
b=gca()
b.tight_limits='on'
b.data_bounds=[254,6816,0,500]
