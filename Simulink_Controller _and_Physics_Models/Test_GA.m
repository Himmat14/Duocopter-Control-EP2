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


%% Multiple PID Setup

% PortNum = 1;
% 
% Kp=226.746; 
% Ki=199.888;
% Kd=51.324; 
% N=16.6;
% 
% Kp2=241.643; 
% Ki2=137.703; 
% Kd2=70.282;
% N2=19.5;


%% Distributions

% simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');
% 
% figure;
% subplot(3,1,1), plot(simOut.e_out.time,simOut.e_out.signals.values), title('Error');
% subplot(3,1,2), plot(simOut.u_out.time,simOut.u_out.signals.values), title('PID output');
% subplot(3,1,3), plot(simOut.y_out.time,simOut.y_out.signals.values), title('Plant output');
% hold on
% subplot(3,1,3), plot(simOut.in_signal(1,:).time,simOut.in_signal.signals.values(1,:)), title('Target Height')
% hold off



%% Sample Mission With Filter

sigNum = 3;  % Sample Mission 


simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');

With_Filter_setup = figure;
%set(Analytical_solution,"WindowState","maximized");
set(findall(With_Filter_setup,'-property','FontSize'),'FontSize',24);
set(findall(With_Filter_setup,'-property','Interpreter'),'Interpreter','latex') 
set(findall(With_Filter_setup,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(With_Filter_setup,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(With_Filter_setup,'Position');
set(With_Filter_setup,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])


plot(simOut.y_out.time,simOut.y_out.signals.values, 'DisplayName', 'System Response')
hold on
plot(simOut.in_signal.time,simOut.in_signal.signals.values, ':', 'DisplayName', 'Sample Mission')
yline(1.44, 'k--', DisplayName='Max Height')

xlabel("Time [s]")
ylabel("Height [m]")

legend(Location = 'northoutside', Orientation="horizontal");


grid minor
hold off

saveas(With_Filter_setup, 'E:\EP2_Summer\Simulink models\sample_mission_pics\Sample_Mission_With_filter.png');



%% Sample Mission Without Filter

sigNum = 3;  % Sample Mission 

N = 0;

simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');


With_Filter_setup = figure;
%set(Analytical_solution,"WindowState","maximized");
set(findall(With_Filter_setup,'-property','FontSize'),'FontSize',24);
set(findall(With_Filter_setup,'-property','Interpreter'),'Interpreter','latex') 
set(findall(With_Filter_setup,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(With_Filter_setup,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(With_Filter_setup,'Position');
set(With_Filter_setup,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])


plot(simOut.y_out.time,simOut.y_out.signals.values, 'DisplayName', 'Unfilterd System Response')
hold on
plot(simOut.in_signal.time,simOut.in_signal.signals.values, ':', 'DisplayName', 'Sample Mission')
yline(1.44, 'k--', DisplayName='Max Height')

xlabel("Time [s]")
ylabel("Height [m]")

legend(Location = 'northoutside', Orientation="horizontal");


grid minor
hold off

saveas(With_Filter_setup, 'E:\EP2_Summer\Simulink models\sample_mission_pics\Sample_Mission_Without_filter.png');








% %% Sample Mission
% 
% 
% sigNum = 3;  % Sample Mission 
% 
% 
% simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');
% 
% SINGLE_PID_setup = figure;
% %set(Analytical_solution,"WindowState","maximized");
% set(findall(SINGLE_PID_setup,'-property','FontSize'),'FontSize',24);
% set(findall(SINGLE_PID_setup,'-property','Interpreter'),'Interpreter','latex') 
% set(findall(SINGLE_PID_setup,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
% set(SINGLE_PID_setup,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
% pos = get(SINGLE_PID_setup,'Position');
% set(SINGLE_PID_setup,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
% 
% 
% plot(simOut.y_out.time,simOut.y_out.signals.values, 'DisplayName', 'System Response')
% hold on
% plot(simOut.in_signal.time,simOut.in_signal.signals.values, ':', 'DisplayName', 'Sample Mission')
% yline(1.44, 'k--', DisplayName='Max Height')
% 
% xlabel("Time [s]")
% ylabel("Height [m]")
% 
% legend(Location = 'northoutside', Orientation="horizontal");
% 
% 
% grid minor
% hold off
% 
% % saveas(SINGLE_PID_setup, 'E:\EP2_Summer\Simulink models\sample_mission_pics\SINGLE_PID_setup.png');
% 
% 
% RSME = simOut.RSME.signals.values(end);
% 
% ENERGY = simOut.ENERGY.signals.values(end);
% 
% DPI = mean(simOut.DPI.signals.values);
% 
% disp('Sample Mission')
% disp('----------------------------------------------------------')
% fprintf('Test → Kp=%.4f, Ki=%.4f, Kd=%.4f, N=%.1f\nRSME=%.4f, ENERGY=%.4f, DPI=%.4f\n', Kp, Ki, Kd, N, RSME, ENERGY, DPI);
% disp('----------------------------------------------------------')
% 
% 
% %% Step down 
% 
% sigNum = 2;  % Step down
% 
% 
% simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');
% 
% SINGLE_PID_setup_Step_down = figure;
% %set(Analytical_solution,"WindowState","maximized");
% set(findall(SINGLE_PID_setup_Step_down,'-property','FontSize'),'FontSize',24);
% set(findall(SINGLE_PID_setup_Step_down,'-property','Interpreter'),'Interpreter','latex') 
% set(findall(SINGLE_PID_setup_Step_down,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
% set(SINGLE_PID_setup_Step_down,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
% pos = get(SINGLE_PID_setup_Step_down,'Position');
% set(SINGLE_PID_setup_Step_down,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
% 
% 
% plot(simOut.y_out.time,simOut.y_out.signals.values, 'DisplayName', 'System Response')
% hold on
% plot(simOut.in_signal.time,simOut.in_signal.signals.values, ':', 'DisplayName', 'Step Down Mission')
% yline(1.44, 'k--', DisplayName='Max Height')
% 
% xlabel("Time [s]")
% ylabel("Height [m]")
% 
% legend(Location = 'northoutside', Orientation="horizontal");
% 
% 
% grid minor
% hold off
% 
% % saveas(SINGLE_PID_setup_Step_down, 'E:\EP2_Summer\Simulink models\sample_mission_pics\SINGLE_PID_setup_Step_down.png');
% 
% 
% 
% RSME = simOut.RSME.signals.values(end);
% 
% ENERGY = simOut.ENERGY.signals.values(end);
% 
% DPI = mean(simOut.DPI.signals.values);
% 
% disp('Step Down\n')
% disp('----------------------------------------------------------')
% fprintf('Test → Kp=%.4f, Ki=%.4f, Kd=%.4f, N=%.1f\nRSME=%.4f, ENERGY=%.4f, DPI=%.4f\n', Kp, Ki, Kd, N, RSME, ENERGY, DPI);
% disp('----------------------------------------------------------')
% 
% %% Sine Wave
% 
% sigNum = 4;  % Sine Wave
% 
% 
% simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');
% 
% SINGLE_PID_setup_Sine = figure;
% %set(Analytical_solution,"WindowState","maximized");
% set(findall(SINGLE_PID_setup_Sine,'-property','FontSize'),'FontSize',24);
% set(findall(SINGLE_PID_setup_Sine,'-property','Interpreter'),'Interpreter','latex') 
% set(findall(SINGLE_PID_setup_Sine,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
% set(SINGLE_PID_setup_Sine,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
% pos = get(SINGLE_PID_setup_Sine,'Position');
% set(SINGLE_PID_setup_Sine,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
% 
% 
% plot(simOut.y_out.time,simOut.y_out.signals.values, 'DisplayName', 'System Response')
% hold on
% plot(simOut.in_signal.time,simOut.in_signal.signals.values, ':', 'DisplayName', 'Sine Mission')
% yline(1.44, 'k--', DisplayName='Max Height')
% 
% xlabel("Time [s]")
% ylabel("Height [m]")
% 
% legend(Location = 'northoutside', Orientation="horizontal");
% 
% 
% grid minor
% hold off
% 
% % saveas(SINGLE_PID_setup_Sine, 'E:\EP2_Summer\Simulink models\sample_mission_pics\SINGLE_PID_setup_Sine.png');
% 
% 
% RSME = simOut.RSME.signals.values(end);
% 
% ENERGY = simOut.ENERGY.signals.values(end);
% 
% DPI = mean(simOut.DPI.signals.values);
% 
% disp('Sine Wave\n')
% disp('----------------------------------------------------------')
% fprintf('Test → Kp=%.4f, Ki=%.4f, Kd=%.4f, N=%.1f\nRSME=%.4f, ENERGY=%.4f, DPI=%.4f\n', Kp, Ki, Kd, N, RSME, ENERGY, DPI);
% disp('----------------------------------------------------------')
% 
% %% Step Up
% 
% sigNum = 5;  % Step Up
% 
% 
% simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');
% 
% SINGLE_PID_setup_Step_UP = figure;
% %set(Analytical_solution,"WindowState","maximized");
% set(findall(SINGLE_PID_setup_Step_UP,'-property','FontSize'),'FontSize',24);
% set(findall(SINGLE_PID_setup_Step_UP,'-property','Interpreter'),'Interpreter','latex') 
% set(findall(SINGLE_PID_setup_Step_UP,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
% set(SINGLE_PID_setup_Step_UP,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
% pos = get(SINGLE_PID_setup_Step_UP,'Position');
% set(SINGLE_PID_setup_Step_UP,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
% 
% 
% plot(simOut.y_out.time,simOut.y_out.signals.values, 'DisplayName', 'System Response')
% hold on
% plot(simOut.in_signal.time,simOut.in_signal.signals.values, ':', 'DisplayName', 'Step Up Mission')
% yline(1.44, 'k--', DisplayName='Max Height')
% 
% xlabel("Time [s]")
% ylabel("Height [m]")
% 
% legend(Location = 'northoutside', Orientation="horizontal");
% 
% 
% grid minor
% hold off
% 
% % saveas(SINGLE_PID_setup_Step_UP, 'E:\EP2_Summer\Simulink models\sample_mission_pics\SINGLE_PID_setup_Step_UP.png');
% 
% RSME = simOut.RSME.signals.values(end);
% 
% ENERGY = simOut.ENERGY.signals.values(end);
% 
% DPI = mean(simOut.DPI.signals.values);
% 
% disp('Step Up\n')
% disp('----------------------------------------------------------')
% fprintf('Test → Kp=%.4f, Ki=%.4f, Kd=%.4f, N=%.1f\nRSME=%.4f, ENERGY=%.4f, DPI=%.4f\n', Kp, Ki, Kd, N, RSME, ENERGY, DPI);
% disp('----------------------------------------------------------')
% %% Climb Mission
% 
% sigNum = 6;  % Climb Mission
% 
% 
% simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');
% 
% SINGLE_PID_setup_Climb = figure;
% %set(Analytical_solution,"WindowState","maximized");
% set(findall(SINGLE_PID_setup_Climb,'-property','FontSize'),'FontSize',24);
% set(findall(SINGLE_PID_setup_Climb,'-property','Interpreter'),'Interpreter','latex') 
% set(findall(SINGLE_PID_setup_Climb,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
% set(SINGLE_PID_setup_Climb,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
% pos = get(SINGLE_PID_setup_Climb,'Position');
% set(SINGLE_PID_setup_Climb,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
% 
% 
% plot(simOut.y_out.time,simOut.y_out.signals.values, 'DisplayName', 'System Response')
% hold on
% plot(simOut.in_signal.time,simOut.in_signal.signals.values, ':', 'DisplayName', 'Climb Mission')
% yline(1.44, 'k--', DisplayName='Max Height')
% 
% xlabel("Time [s]")
% ylabel("Height [m]")
% 
% legend(Location = 'northoutside', Orientation="horizontal");
% 
% 
% grid minor
% hold off
% 
% % saveas(SINGLE_PID_setup_Climb, 'E:\EP2_Summer\Simulink models\sample_mission_pics\SINGLE_PID_setup_Climb.png');
% 
% 
% RSME = simOut.RSME.signals.values(end);
% 
% ENERGY = simOut.ENERGY.signals.values(end);
% 
% DPI = mean(simOut.DPI.signals.values);
% 
% disp('Climb Mission\n')
% disp('----------------------------------------------------------')
% fprintf('Test → Kp=%.4f, Ki=%.4f, Kd=%.4f, N=%.1f\nRSME=%.4f, ENERGY=%.4f, DPI=%.4f\n', Kp, Ki, Kd, N, RSME, ENERGY, DPI);
% disp('----------------------------------------------------------')
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
