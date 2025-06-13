clc
clear
close all

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

%% Define Params

Cdf = 0.17;
M_test = 0.528;
mu_static = 0.26;
Throttle_sat = 90;

%% Define PID Params

% Kp = 112.9515;
% Ki = 33.8912;
% Kd = 28.5419;
% N = 14.7684;

PortNum = 1;

Kp=226.746; 
Ki=199.888;
Kd=51.324; 
N=16.6;

Kp2=241.643; 
Ki2=137.703; 
Kd2=70.282;
N2=19.5;



%% Distributions

simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');

figure;
subplot(3,1,1), plot(simOut.e_out.time,simOut.e_out.signals.values), title('Error');
subplot(3,1,2), plot(simOut.u_out.time,simOut.u_out.signals.values), title('PID output');
subplot(3,1,3), plot(simOut.y_out.time,simOut.y_out.signals.values), title('Plant output');
hold on
subplot(3,1,3), plot(simOut.in_signal(1,:).time,simOut.in_signal.signals.values(1,:)), title('Target Height')
hold off



Multi_PID_setup = figure;
%set(Analytical_solution,"WindowState","maximized");
set(findall(Multi_PID_setup,'-property','FontSize'),'FontSize',24);
set(findall(Multi_PID_setup,'-property','Interpreter'),'Interpreter','latex') 
set(findall(Multi_PID_setup,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(Multi_PID_setup,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(Multi_PID_setup,'Position');
set(Multi_PID_setup,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])


plot(simOut.y_out.time,simOut.y_out.signals.values, DisplayName= 'System Response')
hold on
plot(simOut.in_signal.time,simOut.in_signal.signals.values, ':', DisplayName= 'Sample Mission')
yline(1.44, 'k--', DisplayName='Max Height')

xlabel("Time [s]")
ylabel("Height [m]")

legend(Location = 'northoutside', Orientation="horizontal");

grid minor
hold off

saveas(Multi_PID_setup, 'E:\EP2_Summer\Simulink models\sample_mission_pics\Multi_PID_setup.png');

RSME = mean(simOut.RSME.signals.values);

ENERGY = simOut.ENERGY.signals.values(end);

DPI = mean(simOut.DPI.signals.values);


fprintf('Test → Kp=%.4f, Ki=%.4f, Kd=%.4f, N=%.1f\nRSME=%.4f, ENERGY=%.4f, DPI=%.4f\n', Kp, Ki, Kd, N, RSME, ENERGY, DPI);


