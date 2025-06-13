

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Author Himmat Kaul 
%% CID: 02376386      
%% Date: 01/06/2025    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% run_pid_ga.m
% Uses GA to optimize PID gains in Shank_PID_Model.slx

clear; clc; close all;

format long
s = settings;
s.matlab.fonts.editor.code.Name.TemporaryValue = 'Calibri';
set(groot,'defaultLineLineWidth',2)  %sets graph line width as 2
set(groot,'defaultAxesFontSize',20)  %sets graph axes font size as 18
set(groot,'defaulttextfontsize',20)  %sets graph text font size as 18
set(groot,'defaultLineMarkerSize',8) %sets line marker size as 8
set(groot,'defaultAxesXGrid','on')   %sets X axis grid on 
set(groot,'defaultAxesYGrid','on')   %sets Y axis grid on
set(groot,'DefaultAxesBox', 'on')   %sets Axes boxes on

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.75; % feel free to play with this ratio

%% Genetic Algorithm Setup

% Define bounds for Kp, Ki, Kd N
lb = [0.1, 0.01,  0,  1]; % Lower bounds
ub = [300,   50, 30, 15]; % Upper bounds (tune as needed)

% 200 150 30 15

Cdf = 0.17;
M_test = 0.050;
mu_static = 0.26;
Throttle_sat = 90;


% Fitness function handle
fitnessFcn = @(x) pid_fitness(x);

% GA options
options = optimoptions('ga', ...
    'Display', 'iter', ...
    'PopulationSize', 30, ...
    'MaxGenerations', 50, ...
    'UseParallel',true, ...
    'PlotFcn', {@gaplotbestf});

% Run GA
[x_opt, fval] = ga(fitnessFcn, 4, [], [], [], [], lb, ub, [], options);

fprintf('Optimized PID gains:\nKp = %.4f\nKi = %.4f\nKd = %.4f\nN = %.4f\n', x_opt);

% Save best gains
Kp = x_opt(1);
Ki = x_opt(2);
Kd = x_opt(3);
N  = x_opt(4);

save('optimal_pid_gains.mat', 'Kp', 'Ki', 'Kd');

%%


function cost = pid_fitness(x)
    % Unpack PID values
    Kp = x(1);
    Ki = x(2);
    Kd = x(3);
    N  = x(4);

    % Assign to base workspace so Simulink can access
    assignin('base', 'Kp', Kp);
    assignin('base', 'Ki', Ki);
    assignin('base', 'Kd', Kd);
    assignin('base','N',  N);

    try
        % Simulate the model
        simOut = sim('Shank_PID_Model', ...
            'SimulationMode', 'normal', ...
            'StopTime', '80', ...
            'SaveOutput', 'on', ...
            'SaveTime', 'on');

        % Extract output
        y = simOut.get('y_out').signals.values;
        t = simOut.get('y_out').time;

        % Reference signal (assume step input to 1)
        ref = ones(size(y));

        % Compute error
        e = ref - y;
        Npts = length(e);
        % Cost function: integral of squared error
        cost = sum(e.^2)/Npts;

    catch ME
        % Print out what went wrong
        fprintf('[!] Simulation failed: %s\n', ME.message);
        cost = 1e6;

    end
end
