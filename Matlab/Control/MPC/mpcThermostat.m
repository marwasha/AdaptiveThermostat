function u = mpcThermostat(x0, dyn, prev)

%% Input unpacking + setup

% Dynamics
A = dyn.A;
B = dyn.B;
C = dyn.C;
E = dyn.E;

% Preview Information all 
D = reshape(prev.D',[],1); % expects prev.D as Nxd matrix, must be vectorized
Ts = prev.Ts; %Expects Nx1 matrix
Rbar = prev.R; %Expects Nx1 matrix
N = prev.N; 

% MPC Var
mu = 10000; % Slack cost
dim_ep = 1;
u_max = 1;
u_min = 0;
beta = 1;

[~, m] = size(B);
[~, d] = size(E);
[p, n] = size(C);

%% Setting up the LP matrices

M = zeros(n*N, n);
S = zeros(n*N, m*N);
V = zeros(n*N, d*N);
for i = [1:N]
    a = i-1;
    R = a*n+1:a*n+n;
    M(R,1:n) = A^(i);
    for j = [1:i]
        b = j-1;
        Cu = b*m+1:b*m+m;
        Cd = b*d+1:b*d+d;
        h = i-j;
        S(R,Cu) = A^h*B;
        V(R,Cd) = A^h*E;
    end
end

O = kron(eye(N),C);

%% Constraints
Y_max = Ts + beta; 
Y_min = Ts - beta;
U_max = ones(N*m,1)*u_max;
U_min = ones(N*m,1)*u_min;

W = [Y_max; -Y_min; U_max; -U_min];
T = [-O*M; O*M; zeros(2*N*m,n)];
Z = [-O*V; O*V; zeros(2*N*m,d*N)];
G = [O*S; -O*S; eye(N*m); -eye(N*m)];

%% Slack Contraints
Ss = [S zeros(n*N, dim_ep)];
Gs = [G [-ones(2*N*p, dim_ep); zeros(2*N*m, dim_ep)]; 
      zeros(dim_ep, N*m) -eye(dim_ep)];
Rs = [Rbar; mu];

Ws = [W; 0];
Ts = [T; zeros(dim_ep,n)];
Zs = [Z; zeros(dim_ep,N*d)];

%% Linear Program
A_lp = Gs;
b_lp = Ws + Ts*x0 + Zs*D;
U = linprog(Rs, A_lp, b_lp);

if isempty(U)
  u = 0; % turn heater off if no optimal value found
else
  u = U(1);
end

end
