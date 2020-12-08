function h = dumb_thermo(T_s,h_old, T_set)

beta = 1;

if (T_s > (T_set + beta) && h_old == 1)
    h = 0;
    return
elseif (T_s < (T_set - beta) && h_old == 0)
    h = 1;
    return
end

h = h_old;

end