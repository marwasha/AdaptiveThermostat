%% Setup
clear all;
addpath("MPC", "dynamics", "lookup", "estimation");
parameters;
plantTfCoef;
dt = 1/6;
hrSim = 100;
steps = round(hrSim/dt);
hrPrev = 6;
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
uS = zeros(steps,1);
yS = zeros(steps,1);
tS = zeros(steps,1);

% For estimation
Ahat = zeros(4,4);
Bhat = zeros(4,3);
xhat = zeros(4, steps);
xS   = zeros(4, steps);
dynEst.A = dyn.A;
dynEst.B = dyn.B;
dynEst.C = dyn.C;
dynEst.E = dyn.E;

for i = 1:steps
   % Setup up prev
   prev.D = DPrev(i:i+prev.N-1, :);
   prev.Ts = TSPrev(i:i+prev.N-1, :);
   prev.R = RPrev(i:i+prev.N-1, :);
   % Solve for inputs
   d = prev.D(1,:)';
   u = mpcThermostat(x0, dynEst, prev);
   % Store
   uS(i) = u;
   yS(i) = dynLin.C*x0;
   xS(:,i) = x0;
   tS(i) = (i-1)*dt;
   % Sim
   [time, xCont] = ode45(@(t,x) linContDyn(t,x,u, d, dynLin),[0 dt],x0);
   x0 = xCont(end,:)';
   % Estimate matrices, update for next MPC iteration
   [Ahat, Bhat, xhat(:,i+1)] = estimate_fullStateFB(Ahat, Bhat, x0, xhat(:,i), [u d(1) d(2)]');
   dynEst.A = Ahat;
   dynEst.B = Bhat(:,1);
   dynEst.E = Bhat(:,2:3);
end

%% Plots
figure(1)
plot(tS,yS)
figure(2)
plot(tS,uS)
title("Input Cost = " + dt*sum(RPrev(1:steps).*uS))

figure(3)
subplot(4, 1, 1)
plot(tS, [yS, xhat(1,(1:end-1))']);
title('State Estimations vs Actual Based on Ahat, Bhat')
xlabel('Time (hours)');
ylabel('Temperature (C)');
legend('Sensor Temp.', 'Sensor Temp. Est.');
subplot(4, 1, 2)
plot(tS, [xS(2,:)', xhat(2,(1:end-1))']);
xlabel('Time (hours)');
ylabel('Temperature (C)');
legend('x2', 'x2 est.');
subplot(4, 1, 3)
plot(tS, [xS(3,:)', xhat(3,(1:end-1))']);
xlabel('Time (hours)');
ylabel('Temperature (C)');
legend('x3', 'x3 est.');
subplot(4, 1, 4)
plot(tS, [xS(4,:)', xhat(4,(1:end-1))']);
xlabel('Time (hours)');
ylabel('Temperature (C)');
legend('x4', 'x4 est.');
