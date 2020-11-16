%% Setup
clear all;
addpath("MPC", "dynamics");
parameters;
dt = 1/6;
steps = 200;
prev.N = 12;

full_d = c2d(full, dt);
dyn.A = full_d.A;
dyn.B = full_d.B(:,1);
dyn.C = full_d.C;
dyn.E = full_d.B(:,2:3);

dynLin.A = full.A;
dynLin.B = full.B(:,1);
dynLin.C = full.C;
dynLin.E = full.B(:,2:3);

x0 = [16; 16; 16; 16];

%% Dist Lookup
%I think the easiest way to do preview is if we set up a lookup table for
%the disturbances

%% For loop
x0;
uS = zeros(200,1);
yS = zeros(200,1);
tS = zeros(200,1);

for i = 1:steps
   % Setup up prev
   prev.D = [0*ones(prev.N,1) .1*ones(prev.N,1)];
   prev.Ts = 22*ones(prev.N,1);
   prev.R = ones(prev.N,1);
   % Solve for inputs
   d = prev.D(1,:)';
   u = mpcThermostat(x0, dyn, prev);
   % Store
   uS(i) = u;
   yS(i) = dynLin.C*x0;
   tS(i) = (i-1)*dt;
   % Sim
   [time, xCont] = ode45(@(t,x) linContDyn(t,x,u, d, dynLin),[0 dt],x0);
   x0 = xCont(end,:)';
end

%% Plots

figure(1)
plot(tS,yS)
figure(2)
plot(tS,uS)