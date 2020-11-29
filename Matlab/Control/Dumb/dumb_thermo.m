function h = dumb_thermo(T_s,h_old)

if (T_s > 22 && h_old == 1)
    h = 0;
    return
elseif (T_s < 20 && h_old == 0)
    h = 1;
    return
end

h = h_old;

end