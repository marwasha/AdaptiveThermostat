%% Setup
clear all;
addpath("MPC", "dynamics");
parameters;
dt = 1/6;

%% Get MPC inputs ready
full_d = c2d(full, dt);
dyn.A = full_d.A;
dyn.B = full_d.B(:,1);
dyn.C = full_d.C;
dyn.E = full_d.B(:,2:3);


prev.N = 6*12;
prev.D = [0*ones(prev.N,1) .1*ones(prev.N,1)];
prev.Ts = 22*ones(prev.N,1);
prev.R = ones(prev.N,1);

x0 = 16*ones(4,1);

%% Test MPC
x = x0;
uS = zeros(0,1);
yS = zeros(0,1);
tS = zeros(0,1);
for i = 0:200
    u = mpcThermostat(x, dyn, prev);
    tS = [tS; dt*i];
    uS = [uS; u];
    yS = [yS; C*x];
    x = dyn.A*x + dyn.B*u + dyn.E*prev.D(1,:)';
end

figure(1)
plot(tS,yS)
figure(2)
plot(tS,uS)