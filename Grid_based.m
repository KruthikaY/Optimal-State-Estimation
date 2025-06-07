%Grid-Based Filter for nonlinear estimation
clear; clc;

% Parameters
rng(1);
K_max = 100;
Q = 10;          % Process noise variance
R = 1;           % Measurement noise variance
N = 1000;        % Number of grid points
x_range = [-40, 40];
x_grid = linspace(x_range(1), x_range(2), N);  % State grid
dx = x_grid(2) - x_grid(1);  % Grid spacing

% Initialize true state and measurements
x_true = zeros(1, K_max + 1);
z = zeros(1, K_max + 1);
x_true(1) = randn;  % Initial state from N(0,1)

for k = 2:K_max + 1
    x_prev = x_true(k-1);
    v = sqrt(Q) * randn;
    x_true(k) = 0.5 * x_prev + (25 * x_prev) / (1 + x_prev^2) + 8 * cos(1.2 * (k-1)) + v;
end

for k = 1:K_max + 1
    n = sqrt(R) * randn;
    z(k) = (x_true(k)^2) / 20 + n;
end

% Initialize prior belief: p(x_0) ~ N(0,1)
prior = normpdf(x_grid, 0, 1);
prior = prior / sum(prior);  % Normalize

% Storage for estimates
x_gb = zeros(1, K_max + 1);
x_gb(1) = sum(x_grid .* prior);  % Expected value from prior
posterior_history = zeros(K_max + 1, N);  % For heatmap
posterior_history(1, :) = prior;

% Main filtering loop
for k = 2:K_max + 1
    % Prediction step
    pred = zeros(1, N);
    for j = 1:N
        f = 0.5 * x_grid(j) + (25 * x_grid(j)) / (1 + x_grid(j)^2) + 8 * cos(1.2 * (k-1));
        pred = pred + prior(j) * normpdf(x_grid, f, sqrt(Q));
    end
    pred = pred / sum(pred);  % Normalize prediction

    % Update step using measurement likelihood
    z_pred = (x_grid.^2) / 20;
    likelihood = normpdf(z(k), z_pred, sqrt(R));
    posterior = likelihood .* pred;
    posterior = posterior / sum(posterior);  % Normalize posterior

    % Save results
    x_gb(k) = sum(x_grid .* posterior);
    posterior_history(k, :) = posterior;

    % Prepare for next step
    prior = posterior;
end

% --- Plot Results ---
figure;
plot(0:K_max, x_true, 'k-', 'DisplayName', 'True x_k'); hold on;
plot(0:K_max, x_gb, 'r--', 'DisplayName', 'Grid Estimate');
xlabel('Time k'); ylabel('x_k');
legend; grid on;
title('Grid-Based Estimate vs True State');


[X, K] = meshgrid(x_grid, 0:K_max);
figure;
surf(K, X, posterior_history, 'EdgeColor', 'none');
xlabel('Time k'); ylabel('x_k'); zlabel('p(x_k | z_{1:k})');
title('Posterior Density Surface');
view([45 30]);
colorbar;


k_vals = (0:K_max)';
abs_error = abs(x_true - x_gb);

grid_table = table(k_vals, x_true', x_gb', abs_error', ...
    'VariableNames', {'k', 'x_true', 'x_grid_estimate', 'abs_error'});

disp('Grid-Based Filter Results:');
disp(grid_table(1:101, :));

save('\\filestore.((location))Grid_based_output.mat', 'x_true', 'x_gb');
