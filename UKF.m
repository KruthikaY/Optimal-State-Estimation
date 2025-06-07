%Unscented Kalman Filter (UKF) 

% Parameters (same as EKF)
rng(1);
K_max = 100;
Q = 10;
R = 1;

% Simulate true state and measurements
x_true = zeros(1, K_max+1);
z = zeros(1, K_max+1);
x_true(1) = randn;

for k = 2:K_max+1
    x_prev = x_true(k-1);
    v = sqrt(Q) * randn;
    x_true(k) = 0.5*x_prev + (25*x_prev)/(1+x_prev^2) + 8*cos(1.2*(k-1)) + v;
end

for k = 1:K_max+1
    n = sqrt(R) * randn;
    z(k) = (x_true(k)^2)/20 + n;
end

% UKF Initialization
x_UKF = zeros(1, K_max+1);
P = zeros(1, K_max+1);
x_UKF(1) = x_true(1); % Improved initialization
P(1) = 1; % Start with small confidence

% UKF parameters
L = 1; % State dimension
alpha = 2;
kappa = 0;
beta = 2;
lambda = alpha^2 * (L + kappa) - L;
gamma = sqrt(L + lambda);

Wm = [lambda/(L+lambda), repmat(1/(2*(L+lambda)), 1, 2*L)];
Wc = Wm;
Wc(1) = Wc(1) + (1-alpha^2+beta);

% UKF loop
for k = 2:K_max+1
    % Sigma points calculation
    sqrtP = sqrt(max(P(k-1), 1e-6)); % ensure positivity
    chi = [x_UKF(k-1), x_UKF(k-1)+gamma*sqrtP, x_UKF(k-1)-gamma*sqrtP];

    % Prediction step
    chi_pred = 0.5*chi + (25*chi)./(1+chi.^2) + 8*cos(1.2*(k-1));
    x_pred = sum(Wm .* chi_pred);
    P_pred = Q + sum(Wc .* (chi_pred - x_pred).^2);

    % Predicted measurement
    z_sigma = (chi_pred.^2)/20;
    z_pred = sum(Wm .* z_sigma);

    % Measurement covariance
    P_zz = R + sum(Wc .* (z_sigma - z_pred).^2);

    % Cross covariance
    P_xz = sum(Wc .* (chi_pred - x_pred) .* (z_sigma - z_pred));

    % Kalman gain
    K_gain = P_xz / P_zz;

    % Update step
    x_UKF(k) = x_pred + K_gain * (z(k) - z_pred);
    P(k) = P_pred - K_gain^2 * P_zz;

    % Enforce numerical stability
    P(k) = max(P(k), 1e-6);
end

% Plot Results
figure;
plot(0:K_max, x_true, 'k-', 'DisplayName', 'True x_k'); hold on;
plot(0:K_max, x_UKF, 'm--', 'DisplayName', 'UKF Estimate');
plot(0:K_max, x_UKF + sqrt(P), 'b:', 'DisplayName', '+1\sigma');
plot(0:K_max, x_UKF - sqrt(P), 'b:', 'DisplayName', '-1\sigma');
xlabel('k'); ylabel('State');
title('UKF Estimate of x_k');
legend('Location', 'best'); grid on;

k = (0:K_max)';
table_output = table(k, x_true', x_UKF', P', ...
    x_UKF' + sqrt(P)', x_UKF' - sqrt(P)', ...
    'VariableNames', {'k', 'x_true', 'x_UKF', 'P', '+1 Sigma', '-1 Sigma'});

% Display table (all 101 rows)
disp(table_output(1:101,:));
save('\\filestore.((location))\UKF_output.mat'), 'x_true', 'x_UKF';
