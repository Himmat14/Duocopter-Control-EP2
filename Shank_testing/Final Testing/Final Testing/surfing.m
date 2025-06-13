clc; clear; close all;

format long
s = settings;
s.matlab.fonts.editor.code.Name.TemporaryValue = 'Calibri';
set(groot,'defaultLineLineWidth',2.5)  %sets graph line width as 2
set(groot,'defaultAxesFontSize',20)  %sets graph axes font size as 18
set(groot,'defaulttextfontsize',20)  %sets graph text font size as 18
set(groot,'defaultLineMarkerSize',8) %sets line marker size as 8
set(groot,'defaultAxesXGrid','on')   %sets X axis grid on 
set(groot,'defaultAxesYGrid','on')   %sets Y axis grid on
set(groot,'DefaultAxesBox', 'on')   %sets Axes boxes on

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.75; % feel free to play with this ratio

%%


load("RMSE_Final.mat");


%%

for i = 1:length(Kdl)
    % Select which Kdl slice
    chosenslice = i; % example: slice at Kdl(l)
    
    % Extract 2D slice (Kpl × Kil)
    Z_slice = squeeze(RMSE(:, :, chosenslice));
    
    % Find minimum RMSE location
    [min_val, min_idx] = min(Z_slice(:));
    [row, col] = ind2sub(size(Z_slice), min_idx);
    min_Kp = Kpl(col); % X axis (columns)
    min_Ki = Kil(row); % Y axis (rows)
    
    % Create meshgrid
    [X, Y] = meshgrid(Kpl, Kil);
    
    % Plot heatmap
    fig = figure;
    imagesc(Kpl, Kil, Z_slice);
    set(gca, 'YDir', 'normal');
    hold on;
    
    % Mark minimum point
    plot(min_Kp, min_Ki, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
    text(min_Kp, min_Ki, sprintf('  Min: %.3f', min_val), 'Color', 'red', 'FontSize', 10, 'FontWeight', 'bold');
    
    % Labels and colorbar
    colormap(parula);
    colorbar;
    xlabel('Kp');
    ylabel('Ki');
    title(['RMSE Heatmap at Kdl index ', num2str(chosenslice), ' (Kd = ', num2str(Kdl(chosenslice)), ')']);

    name= "E:\EP2_Summer\Shank_testing\Graphs\RMSE Heatmap at Kdl index "+ num2str(chosenslice)+ " (Kd = " + num2str(Kdl(chosenslice))+ ")_Final.png";

    saveas(fig, name)
    hold off;
end