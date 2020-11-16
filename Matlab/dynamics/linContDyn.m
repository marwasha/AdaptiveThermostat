function xdot = linContDyn(t, x, u, d, dyn)
    xdot = dyn.A*x + dyn.B*u + dyn.E*d;
end