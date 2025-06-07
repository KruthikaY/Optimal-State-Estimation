%Particle Filter (SIR) for nonlinear estimation
clear; clc;

% Parameters
rng(1);
K_max = 100;
Q = 10;
R = 1;
N_particles = 1000;

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

% Initialize Particles
x_particles = randn(N_particles, 1);  % x0 ~ N(0,1)
w_particles = ones(N_particles, 1) / N_particles;

% Storage for estimated states
x_pf = zeros(1, K_max + 1);
x_pf(1) = sum(x_particles .* w_particles);

% Main Particle Filtering 
for k = 2:K_max + 1
    % 1. Prediction Step
    for i = 1:N_particles
        x_prev = x_particles(i);
        process_noise = sqrt(Q) * randn;
        x_particles(i) = 0.5 * x_prev + (25 * x_prev) / (1 + x_prev^2) + 8 * cos(1.2 * (k-1)) + process_noise;
    end

    % 2. Weight Update Step
    for i = 1:N_particles
        z_expected = (x_particles(i)^2) / 20;
        w_particles(i) = normpdf(z(k), z_expected, sqrt(R));
    end

    % 3. Normalize Weights
    w_particles = w_particles / sum(w_particles);

    % 4. Resample (SIR)
    Neff = 1 / sum(w_particles.^2);
    if Neff < N_particles / 2
        indices = randsample(1:N_particles, N_particles, true, w_particles);
        x_particles = x_particles(indices);
        w_particles = ones(N_particles, 1) / N_particles;
    end

    % 5. Estimate State
    x_pf(k) = sum(x_particles .* w_particles);
end

% Plot Results
figure;
plot(0:K_max, x_true, 'k-', 'DisplayName', 'True x_k'); hold on;
plot(0:K_max, x_pf, 'g--', 'DisplayName', 'Particle Estimate');
xlabel('Time k'); ylabel('x_k');
legend; grid on;
title('Particle Filter Estimate vs True State');

k_vals = (0:K_max)';
abs_error = abs(x_true - x_pf);

pf_table = table(k_vals, x_true', x_pf', abs_error', ...
    'VariableNames', {'k', 'x_true', 'x_pf_estimate', 'abs_error'});

disp('Particle Filter Results:');
disp(pf_table(1:101,:));

save('\\filestore.((location))\PF_output.mat', 'x_true', 'x_pf');
