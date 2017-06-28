function Vn = capital(V0, r, n ,c)
    if c == 1 then
        Vn = V0*exp(r * n)
    elseif c == 0 then
        Vn = V0 * (1 + r)^n
    end
endfunction

funcprot(0)

V0 = 1000
r = 0.05
n = 10
c = 0

if c == 1 then
    disp("Capital with continious rate: Vn = " + string( capital(V0, r, n ,c) ))
elseif c == 0 then
    disp( "Capital with simple rate: Vn = " + string( capital(V0, r, n ,c) ) )
end
