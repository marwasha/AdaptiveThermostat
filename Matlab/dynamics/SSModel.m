n = 4;
m = 1;
p = 2;
A = [-1/(R_is*C_s) 1/(R_is*C_s) 0 0;
      1/(R_is*C_i) -(1/(R_is*C_i) + 1/(R_ih*C_i) + 1/(R_ie*C_i)) 1/(R_ih*C_i) 1/(R_ie*C_i);
      0 1/(R_ih*C_h) -1/(R_ih*C_h) 0;
      0 1/(R_ie*C_e) 0 -(1/(R_ea*C_e) + 1/(R_ie*C_e))];
B = [0; 0; Phi_h/C_h; 0];
E = [0 0; 0 A_w/C_i; 0 0; 1/(R_ea*C_e) A_e/C_e];
C = [1 0 0 0];