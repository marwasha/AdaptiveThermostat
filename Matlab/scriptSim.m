%% Setup
clear all;
close all;

addpath("Control/MPC", "Control/Dumb", "dynamics", "lookup", "estimation");

% Init model
ModelForAdapt2019;
MODEL = 'ModelForAdapt2019';
set_param(MODEL,'FastRestart','off');

% Simulation parameters
hr2sec = 3600;
sec2hr = 1/hr2sec;
dt = 1/6; % Works great with 1/4, but less spikes in estimations with 1/6
hrSim = 200;
steps = round(hrSim/dt);
hrPrev = 6;
prev.N = round(hrPrev/dt);

t_sample_est = 1/20; % Period for RLS algorithm
t_sample = 1/3600;   % Sampling period for digital filters
t_observer = 0.01;   % Must match Ts in observer block code

n_paramConverge = 35; % Start state observer after parameter convergence
n_smartThermoOn = 80/dt; % Switch to smart thermo after n steps

parameters;
Filters;
plantTfCoef;

%% Dist Lookup
LUparam.N = prev.N;
LUparam.Ta_ave = 12;
LUparam.Ta_dev = 5;
LUparam.Ta_t_max = 15;
LUparam.Ps_max = .7;
LUparam.Ps_t_max = 12;
LUparam.Ps_shift = -.5;
LUparam.distShit = 1;
LUparam.t_start = 3;
LUparam.r_var = .03;
LUparam.r_min = .1;
LUparam.TSDay = 21;
LUparam.TSNight = 20;
LUparam.t_day = 7;
LUparam.t_night = 17;

[DPrev, RPrev, TSPrev, TimePrev] = lookup(dt, steps, LUparam);


%% For loop
x0     = [16; 16; 16; 16];
uSM    = zeros(steps-n_smartThermoOn,1);
ySM    = zeros(steps-n_smartThermoOn,1);
uSD    = zeros(steps-n_smartThermoOn,1);
ySD    = zeros(steps-n_smartThermoOn,1);
tSM    = zeros(steps-n_smartThermoOn,1);
thetaS = zeros(steps,10);
xhatS  = zeros(steps,4);
xactS  = zeros(steps,4);
tS     = zeros(steps,1);

dynEst.A = dyn.A;
dynEst.B = dyn.B;
dynEst.C = dyn.C;
dynEst.E = dyn.E;

set_param(MODEL,'LoadInitialState','off');
inputSim = Simulink.SimulationInput(MODEL);
set_param(MODEL,'FastRestart','on');

% Setup
u = 0;
enableSmartThermo = false;

for i = 1:steps
    % Setup up prev
    prev.D = DPrev(i:i+prev.N-1, :);
    prev.Ts = TSPrev(i:i+prev.N-1, :);
    prev.R = RPrev(i:i+prev.N-1, :);
    
    % Solve for inputs
    d = prev.D(1,:)';
        
    % Run dumb thermostat until smart thermostat is ready. Then run both in
    % parallel and store results
    if (enableSmartThermo == true)
        u = mpcThermostat(x0, dynEst, prev);
        uD = dumb_thermo(dyn.C*xD,uD, prev.Ts(1));
        
        % Simulate dumb
        [time, xContD] = ode45(@(t,x) linContDyn(t,x,uD, d,dynLin),[0 dt],xD);
        xD = xContD(end,:)';

    else
        u = dumb_thermo(dynLin.C*x0, u, prev.Ts(1));
        uD = u;
    end
   
    %% Sim smart
    set_param(MODEL, 'StopTime', 'i*dt');
    simOut = sim(inputSim);
    
    % Save and restore operating point
    OperPoint = simOut.OperPoint;
    set_param(MODEL,'LoadInitialState','on','InitialState',...
                    'OperPoint');
    set_param(MODEL,'SaveFinalState','on','FinalStateName',...
                    'OperPoint','SaveOperatingPoint','on');
        
    % Store outputs
    thetaS(i,:) = simOut.yout.signals(1).values(end,:);
    xhatS(i,:)  = simOut.yout.signals(2).values(end,:);
    xactS(i,:)  = simOut.yout.signals(4).values(end,:);
    tS(i)       = (i-1)*dt;
      
    % Kick on smart thermostat after state estimate convergence
    if i < n_smartThermoOn
      x0 = xactS(i,:)';
      xD = x0;
    else
      enableSmartThermo = true;
      
      % Store smart
      uSM(i-n_smartThermoOn+1) = u;
      ySM(i-n_smartThermoOn+1) = dynLin.C*xactS(i,:)';
      tSM(i-n_smartThermoOn+1) = (i-1)*dt;
      % Store dumb
      uSD(i-n_smartThermoOn+1) = uD;
      ySD(i-n_smartThermoOn+1) = dynLin.C*xD;
        
      x0 = xhatS(i,:)'; 
      
      % Capture estimated dynamics
      Ahat_new = simOut.EstimatedPlant_A.signals.values;
      Bhat_new = simOut.EstimatedPlant_B.signals.values;
   
      if (~isequal(Ahat_new,dynEst.A) || ...
          ~isequal(Bhat_new,dynEst.B))
   
          dynEst.A = Ahat_new;
          dynEst.B = Bhat_new(:,1);
          dynEst.E = Bhat_new(:,2:3);
      end
    end
   
    disp([num2str(floor(i*100/steps)), '%']);
end

set_param(MODEL,'FastRestart','off'); % If you run into problems
                                      % run this line and then
                                      % restart matlab

%% Plots
SimulationPlots;

costDumb  = dt*sum(RPrev(n_smartThermoOn:steps).*uSD);
costSmart = dt*sum(RPrev(n_smartThermoOn:steps).*uSM);

figure
plot(tSM,ySD,tSM,ySM, tSM, TSPrev(n_smartThermoOn:steps) + 1, tSM, TSPrev(n_smartThermoOn:steps) - 1)
xlabel("Time (hr)")
ylabel("T_s (C)")
legend("Dumb", "MPC", "T Set + beta", "T Set - beta")
xlim([n_smartThermoOn*dt hrSim])

figure
plot(tSM,uSD,tSM,uSM)
title("Input Cost Dumb = " + costDumb + " " + "Input Cost MPC = " + ...
                 costSmart);
xlabel("Time (hr)")
ylabel("h")
legend("Dumb", "MPC")
xlim([n_smartThermoOn*dt hrSim])
ylim([-.05 1.05])

disp(['Savings: ', num2str((costDumb - costSmart)/costDumb*100), '%']);
