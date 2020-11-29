%% Setup
clear all;
addpath("Control/MPC", "Control/Dumb", "dynamics", "lookup");
parameters;
hr2sec = 3600;
sec2hr = 1/hr2sec;

dt = 1/6;
hrSim = 48;
steps = round(hrSim/dt);
hrPrev = 6;
prev.N = round(hrPrev/dt);

temp_sampling_time_sec = .1;
temp_sampling_time_hr = .1*sec2hr;
intersample_count = round(dt/(temp_sampling_time_hr));

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
uS = zeros(steps,1);
yS = zeros(steps,1);
tS = zeros(steps,1);

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
   %for j = 1:intersample_count
   %    [time, xCont] = ode45(@(t,x) linContDyn(t,x,u, d, dynLin),[0 temp_sampling_time_hr],x0);
   %    x0 = xCont(end,:)';
   %end
   [time, xCont] = ode45(@(t,x) linContDyn(t,x,u, d, dynLin),[0:temp_sampling_time_hr:dt],x0);
   x0 = xCont(end,:)';
end

%% Plots

figure(1)
plot(tS,yS)
figure(2)
plot(tS,uS)
title("Input Cost = " + dt*sum(RPrev(1:steps).*uS))
