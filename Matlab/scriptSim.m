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
n_smartThermoOn = steps/2; % Switch to smart thermo after n steps

parameters;
Filters;
plantTfCoef;

%% Dist Lookup
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
x0     = [16; 16; 16; 16];
uS     = zeros(steps,1);
yS     = zeros(steps,1);
tS     = zeros(steps,1);
thetaS = zeros(steps,10);
xhatS  = zeros(steps,4);
xactS  = zeros(steps,4);

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
        
    if (enableSmartThermo == true)
        u = mpcThermostat(x0, dynEst, prev);
    else
        u = dumb_thermo(dynLin.C*x0, u, mean(prev.Ts));
    end
    
    % Store
    uS(i) = u;
    yS(i) = dynLin.C*x0;
    tS(i) = (i-1)*dt;
   
    %% Sim
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
      
    % Kick on smart thermostat after state estimate convergence
    if i < n_smartThermoOn
      x0 = xactS(i,:)';
    else
      enableSmartThermo = true;
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

%% Rough cost analysis
% Average electricity price during operation
costAvgDumb  = mean(RPrev(1:steps/2));
costAvgSmart = mean(RPrev(steps/2+1:steps));
disp(['Avg. cost of electricity while dumb operating: ', num2str(costAvgDumb)]);
disp(['Avg. cost of electricity while smart operating: ', num2str(costAvgSmart)]);

% Cost adjustment for price
costDumb = dt*sum(RPrev(1:steps/2).*uS(1:steps/2));
costSmart = dt*sum(RPrev(steps/2+1:steps).*uS(steps/2+1:end));
costAdjust = costAvgDumb/costAvgSmart;
disp(['Savings: ', num2str((costDumb/costAdjust - costSmart)/costDumb*100), '%']);

%% Plots
SimulationPlots;
