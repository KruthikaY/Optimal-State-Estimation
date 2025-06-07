%Quantitative Comaprision of advanced filters 
clear; clc;
load('UKF_output.mat','x_true','x_UKF');   
load('Imp_Grid_based_output.mat', 'x_igb');
load('RPF_output.mat', 'x_rpf');

% RMSE
rmse_ukf  = sqrt(mean((x_true - x_UKF).^2));
rmse_igrid = sqrt(mean((x_true - x_igb).^2));
rmse_rpf   = sqrt(mean((x_true - x_rpf).^2));

% MAE
mae_ukf  = mean(abs(x_true - x_UKF));
mae_igrid = mean(abs(x_true - x_igb));
mae_rpf   = mean(abs(x_true - x_rpf));

% Bias
bias_ukf  = mean(x_UKF - x_true);
bias_igrid = mean(x_igb - x_true);
bias_rpf   = mean(x_rpf - x_true);

fprintf('\n PERFORMANCE COMPARISON \n');
fprintf('  Filter                     |   RMSE    |    MAE    |   Bias   \n');
fprintf('-----------------------------|-----------|-----------|-----------\n');
fprintf('  UKF                        | %9.4f | %9.4f | %9.4f\n', rmse_ukf,  mae_ukf,  bias_ukf);
fprintf('  Imp_Grid_Based             | %9.4f | %9.4f | %9.4f\n', rmse_igrid, mae_igrid, bias_igrid);
fprintf('  Regularized Particle Filter| %9.4f | %9.4f | %9.4f\n', rmse_rpf,   mae_rpf,   bias_rpf);

figure;
plot(0:100, x_true, 'k', 'LineWidth', 2); hold on;
plot(0:100, x_UKF, 'r--', 'LineWidth', 1.5);
plot(0:100, x_igb, 'b-.', 'LineWidth', 1.5);
plot(0:100, x_rpf, 'g:', 'LineWidth', 1.5);
legend('True x_k', 'UKF Estimate', 'Imp Grid Estimate', 'RPF Estimate', 'Location', 'best');
xlabel('Time Step k'); ylabel('State Value');
title('True vs Estimated States using UKF, Improvised Grid, and Regularized Particle Filter');
grid on;
