clear all
syms C_i C_e C_h C_s R_ie R_ea R_ih R_is A_w A_e Phi_h s

SSModel;

H2T_s = C*(s*eye(n) - A)^-1*B;
T_a2T_s = C*(s*eye(n) - A)^-1*E(:,1);
S2T_s = C*(s*eye(n) - A)^-1*E(:,2);