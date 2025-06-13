% initial set up
clear
clc
format long

% model = "AdaptivePID_Model_28May2025.slx";

% open_system(model);

%% Input signal 

% sigNum = 2;  % Step down
sigNum = 3;  % Sample Mission 
% sigNum = 4;  % Sine Wave
% sigNum = 5;  % Step Up
% sigNum = 6;  % Climb Mission


%% Define Params

Cdf = 0.17;
M_test = 0.528;
mu_static = 0.26;
Throttle_sat = 90;

%% Define PID Params

PortNum = 2;

Kp = 112.9515;
Ki = 33.8912;
Kd = 28.5419;
N = 14.7684;

Kp2=0; 
Ki2=0; 
Kd2=0;
N2=0;

%%

nPI = 10; % number of Kp & Ki gridpoints to check
Kpl = 50:10:300; % Range of Kp values to search
Kil = 0:10:150; % Range of Ki values to search

% nD = 10; % number of Kd gridpoints to check
Kdl = 20:5:35; % Range of Kd values to search


for p = 1:length(Kpl)
    Kp = Kpl(p);

    for i = 1:length(Kil)
        Ki = Kil(i);

        for d = 1:length(Kdl)
            Kd = Kdl(d);
            
            % sm = sim(model, 'SimulationMode','normal','StopTime','80','SaveOutput','on','SaveTime','on');

            sm = sim('AdaptivePID_Model_28May2025','StopTime','80');

            RMSE(p,i,d) = sm.RSME.signals.values(end);


        end
    end
end

save("RMSE_Final.mat","RMSE","Kdl","Kil","Kpl")
