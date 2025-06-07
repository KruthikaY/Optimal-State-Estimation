%Comaprision of all filters 
clear; clc;
load('EKF_output.mat','x_true','x_EKF');   
load('Grid_based_output.mat', 'x_gb');
load('PF_output.mat', 'x_pf');
load('UKF_output.mat','x_UKF');   
load('Imp_Grid_based_output.mat', 'x_igb');
load('RPF_output.mat', 'x_rpf');

figure;
hold on; grid on;

plot(0:100, x_true, 'k-', 'LineWidth', 2, 'DisplayName', 'True State');
plot(0:100, x_EKF, 'r--', 'LineWidth', 1.5, 'DisplayName', 'EKF');
plot(0:100, x_UKF, 'm-.', 'LineWidth', 1.5, 'DisplayName', 'UKF');
plot(0:100, x_gb, 'c:', 'LineWidth', 1.5, 'DisplayName', 'Grid-Based');
plot(0:100, x_igb, 'b-.', 'LineWidth', 1.5, 'DisplayName', 'Improved Grid (MAP)');
plot(0:100, x_pf, 'g--', 'LineWidth', 1.5, 'DisplayName', 'PF (SIR)');
plot(0:100, x_rpf, 'y-', 'LineWidth', 1.5, 'DisplayName', 'Regularized PF (RPF)');

xlabel('Time Step k', 'FontSize', 12);
ylabel('State Value', 'FontSize', 12);
title('Comparison of True State and Filter Estimates', 'FontSize', 14);
legend('Location', 'best');
set(gca, 'FontSize', 11);
xlim([0 100]);
grid on;
hold off;
