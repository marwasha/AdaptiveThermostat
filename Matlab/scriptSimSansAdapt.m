% Made this without adaptation to compare MPC with Model Free thermostate

%% Setup
clear all;

addpath("Control/MPC", "Control/Dumb", "dynamics", "lookup", "estimation");
parameters;
plantTfCoef;
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

x0 = [20; 20; 20; 20];

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
uSM = zeros(steps,1);
ySM = zeros(steps,1);
uSD = zeros(steps,1);
ySD = zeros(steps,1);
tS = zeros(steps,1);
uD = 0;
xD = x0;
xM = x0;

for i = 1:steps
   % Setup up prev
   prev.D = DPrev(i:i+prev.N-1, :);
   prev.Ts = TSPrev(i:i+prev.N-1, :);
   prev.R = RPrev(i:i+prev.N-1, :);
   % Solve for inputs
   d = prev.D(1,:)';
   uM = mpcThermostat(xM, dyn, prev);
   uD = dumb_thermo(dyn.C*xD,uD, prev.Ts(1));
   % Store
   uSD(i) = uD;
   uSM(i) = uM;
   ySD(i) = dynLin.C*xD;
   ySM(i) = dynLin.C*xM;
   tS(i) = (i-1)*dt;
   % Sim
   %for j = 1:intersample_count
   %    [time, xCont] = ode45(@(t,x) linContDyn(t,x,u, d, dynLin),[0 temp_sampling_time_hr],x0);
   %    x0 = xCont(end,:)';
   %end
   [time, xContD] = ode45(@(t,x) linContDyn(t,x,uD, d,dynLin),[0:temp_sampling_time_hr:dt],xD);
   [time, xContM] = ode45(@(t,x) linContDyn(t,x,uM, d,dynLin),[0:temp_sampling_time_hr:dt],xM);
   xD = xContD(end,:)';
   xM = xContM(end,:)';
end

%% Plots
figure(1)
plot(tS,ySD,tS,ySM, tS, TSPrev(1:steps) + 1, tS, TSPrev(1:steps) - 1)
xlabel("Time (hr)")
ylabel("T_s (C)")
legend("Dumb", "MPC", "T Set + beta", "T Set - beta")
xlim([0 hrSim])
figure(2)
plot(tS,uSD,tS,uSM)
title("Input Cost Dumb = " + dt*sum(RPrev(1:steps).*uSD) + " " + "Input Cost MPC = " + dt*sum(RPrev(1:steps).*uSM) )
xlabel("Time (hr)")
ylabel("h")
legend("Dumb", "MPC")
xlim([0 hrSim])
ylim([-.05 1.05])

% figure(3)
% subplot(4, 1, 1)
% plot(tS, [yS, xhat(1,(1:end-1))']);
% title('State Estimations vs Actual Based on Ahat, Bhat')
% xlabel('Time (hours)');
% ylabel('Temperature (C)');
% legend('Sensor Temp.', 'Sensor Temp. Est.');
% subplot(4, 1, 2)
% plot(tS, [xS(2,:)', xhat(2,(1:end-1))']);
% xlabel('Time (hours)');
% ylabel('Temperature (C)');
% legend('x2', 'x2 est.');
% subplot(4, 1, 3)
% plot(tS, [xS(3,:)', xhat(3,(1:end-1))']);
% xlabel('Time (hours)');
% ylabel('Temperature (C)');
% legend('x3', 'x3 est.');
% subplot(4, 1, 4)
% plot(tS, [xS(4,:)', xhat(4,(1:end-1))']);
% xlabel('Time (hours)');
% ylabel('Temperature (C)');
% legend('x4', 'x4 est.');
