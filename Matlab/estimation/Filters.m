%% Filter specs
s = tf('s');
filt_poles = 0.5*[-10 -20 -40 -60]; % Poles tuned ad hoc
filt_tf = 1/((s - filt_poles(1))*(s - filt_poles(3))*(s - filt_poles(2))*(s - filt_poles(4)));
filt_gain = 1/evalfr(filt_tf, 0); % DC offset
filt_tf_1 = (s)*filt_tf*filt_gain;
filt_tf_2 = (s^2)*filt_tf*filt_gain;
filt_tf_3 = (s^3)*filt_tf*filt_gain;
filt_tf_4 = (s^4)*filt_tf*filt_gain;
filt_tf = filt_tf*filt_gain;

% Discretize, use bilinear transform for stability properties
filt_tfd = c2d(filt_tf, t_sample, 'tustin', 'PrewarpFrequency');
filt_tfd_1 = c2d(filt_tf_1, t_sample, 'tustin', 'PrewarpFrequency');
filt_tfd_2 = c2d(filt_tf_2, t_sample, 'tustin', 'PrewarpFrequency');
filt_tfd_3 = c2d(filt_tf_3, t_sample, 'tustin', 'PrewarpFrequency');
filt_tfd_4 = c2d(filt_tf_4, t_sample, 'tustin', 'PrewarpFrequency');

% Remove workspace clutter
clear s;
clear filt_poles;
clear filt_tf; 
clear filt_gain; 
clear filt_tf_1; 
clear filt_tf_2; 
clear filt_tf_3; 
clear filt_tf_4;
