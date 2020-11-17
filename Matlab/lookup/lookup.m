function [D, R, TS, time] = lookup(dt, steps, param)

D = zeros(steps+param.N,2);
R = param.r_min*ones(steps+param.N,1);
TS = zeros(steps+param.N,1);
time = zeros(steps+param.N,1);

r = param.r_min;

for i = 1:steps+param.N
    % Time
    t = (i-1)*dt + param.t_start;
    time(i) = t;
    % Set 
    if mod(t,24) > param.t_day && mod(t,24) < param.t_night
        TS(i) = param.TSDay;
    else
        TS(i) = param.TSNight;
    end
    % Ambient Temp
    D(i,1) = param.Ta_ave + param.Ta_dev*cos((t-param.Ta_t_max)*(2*pi/24));
    % Sun
    D(i,2) = max(0,param.Ps_shift + param.Ps_max*cos((t-param.Ps_t_max)*(2*pi/24)));
    % Cost
    r = max(param.r_min, r+normrnd(0,1/3)*param.r_var*dt);
    R(i) = r;
end