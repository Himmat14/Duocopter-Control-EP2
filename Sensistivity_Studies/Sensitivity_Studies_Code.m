clc; 
% clear; 
close all;

format long
s = settings;
s.matlab.fonts.editor.code.Name.TemporaryValue = 'Calibri';
set(groot,'defaultLineLineWidth',2)  %sets graph line width as 2
set(groot,'defaultAxesFontSize',20)  %sets graph axes font size as 18
set(groot,'defaulttextfontsize',20)  %sets graph text font size as 18
set(groot,'defaultLineMarkerSize',12) %sets line marker size as 8
set(groot,'defaultAxesXGrid','on')   %sets X axis grid on 
set(groot,'defaultAxesYGrid','on')   %sets Y axis grid on
set(groot,'DefaultAxesBox', 'on')   %sets Axes boxes on

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.75; % feel free to play with this ratio

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

%% Input signal 

% sigNum = 2;  % Step down
sigNum = 3;  % Sample Mission 
% sigNum = 4;  % Sine Wave
% sigNum = 5;  % Step Up
% sigNum = 6;  % Climb Mission

%% Define Params

M_perc = 0.80:0.01:1.20;
Cdf_perc = 0.80:0.01:1.20;
Csf_perc = 0.80:0.01:1.20;


Cdf = 0.17;
M_test = 0.528;
mu_static = 0.26;
Throttle_sat = 90;

%% Distributions

Ma_dist = M_test * M_perc; 
Cdf_dist = Cdf * Cdf_perc;
Csf_dist = mu_static * Csf_perc;

Throttle_sat_dist = 70:2:100;

%% Mass sensitivity study
for i = 1:length(Ma_dist)

    M_test = Ma_dist(i);
    Cdf = 0.17;
    mu_static = 0.26;
    Throttle_sat = 90;

    simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');

    RSME_Ma_study(i) = simOut.RSME.signals.values(end); 
    % DPI_Ma_study(i) = mean(simOut.DPI.signals.values);
    ENERGY_Ma_study(i) = simOut.ENERGY.signals.values(end);

end

%% CDF study (Dynamic Friction)

% for i = 1:length(Cdf_dist)
% 
%     M_test = 0.528;
%     Cdf = Cdf_dist(i);
%     mu_static = 0.26;
%     Throttle_sat = 90;
% 
%     simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');
% 
%     RSME_Cdf_study(i) = simOut.RSME.signals.values(end); 
%     % DPI_Cdf_study(i) = mean(simOut.DPI.signals.values);
%     ENERGY_Cdf_study(i) = simOut.ENERGY.signals.values(end);
% 
% end


%% Throttle sensitivity study
% for i = 1:length(Throttle_sat_dist)
% 
%     Throttle_sat = Throttle_sat_dist(i);
%     Cdf = 0.17;
%     M_test = 0.528;
%     mu_static = 0.26;
% 
%     simOut = sim('AdaptivePID_Model_28May2025','StopTime','80');
% 
%     RSME_Throttle_study(i) = simOut.RSME.signals.values(end); 
%     % DPI_Throttle_study(i) = mean(simOut.DPI.signals.values);
%     ENERGY_Throttle_study(i) = simOut.ENERGY.signals.values(end);
% 
% end

%% Mass sensitivity study

Mass_study = figure;
%set(Analytical_solution,"WindowState","maximized");
set(findall(Mass_study,'-property','FontSize'),'FontSize',24);
set(findall(Mass_study,'-property','Interpreter'),'Interpreter','latex') 
set(findall(Mass_study,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(Mass_study,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(Mass_study,'Position');
set(Mass_study,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])


hold on
yyaxis left
plot(M_perc*100-100, RSME_Ma_study, 'x', DisplayName= 'RMSE')
ylabel("RMSE")

yyaxis right
plot(M_perc*100-100, ENERGY_Ma_study/1000, 'o', DisplayName= 'Energy [kJ]')
ylabel('Energy [kJ]')
legend(Location="southeast")

xlim([-20, 20])

% title("Mass Study")
xlabel("M_{constant} Variation [%]")
grid minor
hold off

saveas(Mass_study, 'E:\EP2_Summer\Sensistivity_Studies\Mass_study.png');


%% Mass sensitivity study
% 
% Throttle_study = figure;
% %set(Analytical_solution,"WindowState","maximized");
% set(findall(Throttle_study,'-property','FontSize'),'FontSize',24);
% set(findall(Throttle_study,'-property','Interpreter'),'Interpreter','latex') 
% set(findall(Throttle_study,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
% set(Throttle_study,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
% pos = get(Throttle_study,'Position');
% set(Throttle_study,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
% 
% 
% hold on
% yyaxis left
% plot(Throttle_sat_dist, RSME_Throttle_study, 'x', DisplayName= 'RMSE')
% ylabel("RMSE")
% 
% yyaxis right
% plot(Throttle_sat_dist, ENERGY_Throttle_study/1000, 'o', DisplayName= 'Energy [kJ]')
% ylabel('Energy [kJ]')
% legend(Location="east")
% 
% % xlim([-10, 10])
% 
% % title("Mass Study")
% xlabel("S_T [%]")
% grid minor
% hold off
% 
% saveas(Throttle_study, 'E:\EP2_Summer\Sensistivity_Studies\Throttle_study.png');
% 
% 
% 
% 
% %% CDF study (Dynamic Friction)
% 
% Cdf_study = figure;
% %set(Analytical_solution,"WindowState","maximized");
% set(findall(Cdf_study,'-property','FontSize'),'FontSize',24);
% set(findall(Cdf_study,'-property','Interpreter'),'Interpreter','latex') 
% set(findall(Cdf_study,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
% set(Cdf_study,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
% pos = get(Cdf_study,'Position');
% set(Cdf_study,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
% 
% 
% hold on
% yyaxis left
% plot(Cdf_perc*100-100, RSME_Cdf_study, 'x', DisplayName= 'RMSE')
% ylabel("RMSE")
% 
% yyaxis right
% plot(Cdf_perc*100-100, ENERGY_Cdf_study/1000, 'o', DisplayName= 'Energy [kJ]')
% ylabel('Energy [kJ]')
% legend(Location="best")
% 
% xlim([-20, 20])
% 
% % title("Dynamic Friction Study")
% xlabel("C_{df} Variation [%]")
% grid minor
% hold off
% 
% saveas(Cdf_study, 'E:\EP2_Summer\Sensistivity_Studies\Cdf_study.png');
% 
% 
