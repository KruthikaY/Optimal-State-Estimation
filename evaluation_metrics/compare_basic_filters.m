%Quantitative Comaprision of basic filters 
clear; clc;
load('EKF_output.mat','x_true','x_EKF');   
load('Grid_based_output.mat', 'x_gb');
load('PF_output.mat', 'x_pf');

% RMSE
rmse_ekf  = sqrt(mean((x_true - x_EKF).^2));
rmse_grid = sqrt(mean((x_true - x_gb).^2));
rmse_pf   = sqrt(mean((x_true - x_pf).^2));

% MAE
mae_ekf  = mean(abs(x_true - x_EKF));
mae_grid = mean(abs(x_true - x_gb));
mae_pf   = mean(abs(x_true - x_pf));

% Bias
bias_ekf  = mean(x_EKF - x_true);
bias_grid = mean(x_gb - x_true);
bias_pf   = mean(x_pf - x_true);

fprintf('\n PERFORMANCE COMPARISON \n');
fprintf('  Filter         |   RMSE    |    MAE    |   Bias   \n');
fprintf('-----------------|-----------|-----------|-----------\n');
fprintf('  EKF            | %9.4f | %9.4f | %9.4f\n', rmse_ekf,  mae_ekf,  bias_ekf);
fprintf('  Grid-Based     | %9.4f | %9.4f | %9.4f\n', rmse_grid, mae_grid, bias_grid);
fprintf('  Particle Filter| %9.4f | %9.4f | %9.4f\n', rmse_pf,   mae_pf,   bias_pf);

figure;
plot(0:100, x_true, 'k', 'LineWidth', 2); hold on;
plot(0:100, x_EKF, 'r--', 'LineWidth', 1.5);
plot(0:100, x_gb, 'b-.', 'LineWidth', 1.5);
plot(0:100, x_pf, 'g:', 'LineWidth', 1.5);
legend('True x_k', 'EKF Estimate', 'Grid Estimate', 'PF Estimate', 'Location', 'best');
xlabel('Time Step k'); ylabel('State Value');
title('True vs Estimated States using EKF, Grid, and Particle Filter');
grid on;
