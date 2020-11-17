%% Setup
clear all;
addpath("MPC", "dynamics", "lookup");
parameters;
dt = 1/6;
hrSim = 40;
steps = round(hrSim/dt);
hrPrev = 4;
prev.N = round(hrPrev/dt);

dynLin.A = full.A;
dynLin.B = full.B(:,1);
dynLin.C = full.C;
dynLin.E = full.B(:,2:3);

full_d = c2d(full, dt);
dyn.A = full_d.A;
dyn.B = full_d.B(:,1);
dyn.C = full_d.C;
dyn.E = full_d.B(:,2:3);

x0 = [16; 16; 16; 16];

%% Dist Lookup
%I think the easiest way to do preview is if we set up a lookup table for
%the disturbances
LUparam.N = prev.N;
LUparam.Ta_ave = 15;
LUparam.Ta_dev = 5;
LUparam.Ta_t_max = 15;
LUparam.Ps_max = .7;
LUparam.Ps_t_max = 12;
LUparam.Ps_shift = -.5;
LUparam.distShit = 1;
LUparam.t_start = 3;
LUparam.r_var = .03;
LUparam.r_min = .1;
LUparam.TSDay = 22;
LUparam.TSNight = 20;
LUparam.t_day = 7;
LUparam.t_night = 17;

[DPrev, RPrev, TSPrev, TimePrev] = lookup(dt, steps, LUparam);


%% For loop
x0;
uS = zeros(200,1);
yS = zeros(200,1);
tS = zeros(200,1);

for i = 1:steps
   % Setup up prev
   prev.D = DPrev(i:i+prev.N-1, :);
   prev.Ts = TSPrev(i:i+prev.N-1, :);
   prev.R = RPrev(i:i+prev.N-1, :);
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
title("InputSum = " + sum(uS))
