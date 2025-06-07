%Extended Kalman Filter (EKF) to estimate x_k using given z_k

% Parameters
rng(1);
K_max = 100;
Q = 10;   % Process noise variance
R = 1;    % Measurement noise variance

% Simulate true state and measurements (single trajectory)
x_true = zeros(1, K_max+1);
z = zeros(1, K_max+1);
x_true(1) = randn;  % Initial state: x0 ~ N(0,1)

for k = 2:K_max+1
    x_prev = x_true(k-1);
    v = sqrt(Q) * randn;
    x_true(k) = 0.5 * x_prev + (25 * x_prev) / (1 + x_prev^2) + 8 * cos(1.2 * (k-1)) + v;
end

for k = 1:K_max+1
    n = sqrt(R) * randn;
    z(k) = (x_true(k)^2) / 20 + n;
end

% Initialize EKF variables
x_EKF = zeros(1, K_max+1);  % EKF state estimate
P = zeros(1, K_max+1);      % EKF error covariance
x_EKF(1) = 0;               % initial estimate
P(1) = 1;                   % initial variance

% EKF loop
for k = 2:K_max+1
    % Prediction step
    f = 0.5 * x_EKF(k-1) + (25 * x_EKF(k-1)) / (1 + x_EKF(k-1)^2) + 8 * cos(1.2 * (k-1));
    F = 0.5 + 25 * (1 - x_EKF(k-1)^2) / (1 + x_EKF(k-1)^2)^2;
    P_pred = F * P(k-1) * F + Q;

    % Measurement update
    h = f^2 / 20;
    H = f / 10;
    K_gain = P_pred * H / (H^2 * P_pred + R);

    x_EKF(k) = f + K_gain * (z(k) - h);
    P(k) = (1 - K_gain * H) * P_pred;
end

% --- Plot Results ---
close all;
figure;
plot(0:K_max, x_true, 'k-', 'DisplayName', 'True x_k'); hold on;
plot(0:K_max, x_EKF, 'r--', 'DisplayName', 'EKF Estimate');
plot(0:K_max, x_EKF + sqrt(P), 'b:', 'DisplayName', '+1\sigma');
plot(0:K_max, x_EKF - sqrt(P), 'b:', 'DisplayName', '-1\sigma');
xlabel('k'); ylabel('State');
title('EKF Estimate of x_k');
legend('Location', 'best'); grid on;


k = (0:K_max)';
table_output = table(k, x_true', x_EKF', P', ...
    x_EKF' + sqrt(P)', x_EKF' - sqrt(P)', ...
    'VariableNames', {'k', 'x_true', 'x_EKF', 'P', '+1 Sigma', '-1 Sigma'});

disp(table_output(1:101,:));
save('\\filestore((location))'), 'x_true', 'x_EKF';
