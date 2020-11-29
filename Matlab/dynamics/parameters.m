clear all
%% From Identifying suitable models for the heat dynamics of buildings

% Note that C's units are in terms of hours!
uT = 1; % This is a parameter to convert unit of time, set to 3600 for seconds

C_i   = 0.0928*uT; %kWh/C 
C_e   = 3.32*uT;   %kWh/C
C_h   = 0.889*uT;  %kWh/C
C_s   = 0.0549*uT; %kWh/C
R_ie  = 0.897;     %C/kW
R_ea  = 4.38;      %C/kW
R_ih  = 0.146;     %C/kW
R_is  = 1.89;      %C/kW
A_w   = 5.75;      %m^2
A_e   = 3.87;      %m^2
Phi_h = 5.1;       %kW

SSModel; % Creates the linear A, B, C matrices

x_0 = [20; 20; 20; 20];

%% Get the desired sys objects
H2T_s = ss(A, B, C, 0);
T_a2T_s = ss(A, E(:,1), C, 0);
S2T_s = ss(A, E(:,2), C, 0);
full = ss(A, [B E], C, zeros(1,m+p));

%% MPC/Preview Param
dt = 1/6;
t_sample = .1/3600;
N = 30;


full_d = c2d(full, dt);
dyn.A = full_d.A;
dyn.B = full_d.B(:,1);
dyn.C = full_d.C;
dyn.E = full_d.B(:,2:3);

