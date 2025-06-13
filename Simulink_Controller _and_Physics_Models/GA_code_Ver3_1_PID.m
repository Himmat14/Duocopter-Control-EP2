% run_pid_ga.m
clear; clc; close all;

%% Disable Simulink model–level logging (as before)
set_param('Updated_Shank_PID_Model', ...
    'SaveOutput',    'off', ...
    'SaveTime',      'off', ...
    'SaveState',     'off', ...
    'SignalLogging', 'off');

load('sampleH.mat');  % if your model needs it

%% Lower/upper bounds for [Kp, Ki, Kd, N]
lb = [  50,   10,   0,  1];
ub = [ 300,  150, 100, 20]; % can Edit
% N = 10;
options = optimoptions('ga', ...
    'Display','iter', ...
    'PopulationSize',50, ...
    'MaxGenerations',50, ...
    'PlotFcn',{@gaplotbestf});
    % 'UseParallel',true, ...
    % 'PlotFcn',{@gaplotbestf});

%% 4 variables now
[x_opt, fval] = ga(@pid_fitness, 4, [], [], [], [], lb, ub, [], options);

%% Unpack and save
% Kp = x_opt(1); Ki = x_opt(2); Kd = x_opt(3); N = x_opt(4);

fprintf('Optimized → Kp=%.3f, Ki=%.3f, Kd=%.3f, N=%.1f\n', Kp, Ki, Kd, N);
save('optimal_pid_gains.mat','Kp','Ki','Kd','N');


function cost = pid_fitness(x)
    % x = [Kp, Ki, Kd, N]
    Kp = x(1);
    Ki = x(2);
    Kd = x(3);
    N  = x(4);

    % Push them into the base workspace so Simulink picks them up
    assignin('base','Kp', Kp);
    assignin('base','Ki', Ki);
    assignin('base','Kd', Kd);
    assignin('base','N',  N);

    % w_e = 0.4 * 10e4;     % weight on RMSE
    % w_u = 0.3;    % weight on energy

    try
        simOut = sim('Updated_Shank_PID_Model', ...
            'SimulationMode','normal', ...
            'StopTime','80', ...
            'SaveOutput','on', ...
            'SaveTime','on' ...
            );

        y = simOut.get('y_out').signals.values;
        t = simOut.y_out.time; 
        u = simOut.u_out.signals.values;

        ref = ones(size(y));
        e   = ref - y;
        Npts = length(e);
        dt   = t(2) - t(1);
        
        rmse = sqrt( sum(e.^2)/Npts );
        cost = rmse;
        E = sum( u.^2 ) * dt;
        
        % energy = integral of u^2 dt

        % combined cost

        % cost = w_e * rmse + w_u * E;

    catch ME
        fprintf('[!] Simulation failed: %s\n', ME.message);
        cost = 1e6;
    end
end
