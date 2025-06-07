%Grid-Based Filter with Adaptive Grid and MAP Estimation

% Parameters
rng(1);
K_max = 100;
Q = 10;
R = 1;
N = 1000;

% Simulate true state and measurements
x_true = zeros(1, K_max + 1);
z = zeros(1, K_max + 1);
x_true(1) = randn;
for k = 2:K_max + 1
    x_prev = x_true(k-1);
    v = sqrt(Q) * randn;
    x_true(k) = 0.5 * x_prev + (25 * x_prev) / (1 + x_prev^2) + 8 * cos(1.2 * (k-1)) + v;
end
for k = 1:K_max + 1
    n = sqrt(R) * randn;
    z(k) = (x_true(k)^2) / 20 + n;
end

% Initial belief and grid
x_range = [-40, 40];
x_grid = linspace(x_range(1), x_range(2), N);
dx = x_grid(2) - x_grid(1);
prior = normpdf(x_grid, 0, 1);
prior = prior / sum(prior);

% Output storage
x_igb = zeros(1, K_max + 1);
x_igb(1) = sum(prior .* x_grid);
posterior_history = zeros(K_max + 1, N);
x_grid_history = zeros(K_max + 1, N);
posterior_history(1, :) = prior;
x_grid_history(1, :) = x_grid;

% Main loop
for k = 2:K_max + 1
    pred = zeros(1, N);
    for j = 1:N
        f = 0.5 * x_grid(j) + (25 * x_grid(j)) / (1 + x_grid(j)^2) + 8 * cos(1.2 * (k-1));
        pred = pred + prior(j) * normpdf(x_grid, f, sqrt(Q));
    end
    pred = pred / sum(pred);

    % Measurement update
    z_pred = (x_grid.^2) / 20;
    likelihood = normpdf(z(k), z_pred, sqrt(R));
    posterior = likelihood .* pred;
    posterior = posterior / sum(posterior);

    % MAP estimate from posterior
    [~, idx_max] = max(posterior);
    x_igb(k) = x_grid(idx_max);

    % Store posterior and grid
    posterior_history(k, :) = posterior;
    x_grid_history(k, :) = x_grid;

    % Adaptive grid update with std safeguard
    mean_post = sum(posterior .* x_grid);
    std_post = sqrt(sum(posterior .* (x_grid - mean_post).^2));
    std_post = max(std_post, 2.0);  % Prevent collapse
    x_range = [mean_post - 4 * std_post, mean_post + 4 * std_post];
    x_grid = linspace(x_range(1), x_range(2), N);
    dx = x_grid(2) - x_grid(1);
    prior = posterior;
end

% Plot 1: Estimate vs True
figure;
plot(0:K_max, x_true, 'k-', 'LineWidth', 1.2, 'DisplayName', 'True x_k'); hold on;
plot(0:K_max, x_igb, 'b--', 'LineWidth', 1.5, 'DisplayName', 'Improved Grid Estimate (MAP)');
xlabel('Time k'); ylabel('x_k');
title('Improved Grid-Based Estimate vs True State (MAP)');
legend; grid on;

% Plot 2: Adaptive Posterior Surface
figure;
[X, K] = meshgrid(1:N, 0:K_max);
surf(K, x_grid_history, posterior_history, 'EdgeColor', 'none');
xlabel('Time k'); ylabel('x_k'); zlabel('p(x_k | z_{1:k})');
title('Adaptive Posterior Density Surface');
view([45 30]); colorbar;

% Table output
k_vals = (0:K_max)';
abs_error = abs(x_true - x_igb);
grid_table = table(k_vals, x_true', x_igb', abs_error', ...
    'VariableNames', {'k', 'x_true', 'x_grid_estimate', 'abs_error'});
disp('Improved Grid-Based Filter Results (MAP):');
disp(grid_table(1:101, :));

% Save results locally
save('\\filestore.((location))\Imp_Grid_based_output.mat', 'x_igb');

