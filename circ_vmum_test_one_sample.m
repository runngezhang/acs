function [H, P, llrt, exitflag] = circ_vmum_test_one_sample(data, mu)
%CIRC_VMUM_REST_ONE_SAMPLE_MM one sample test for vMUM model
%
%   Audio Circular Statistics (ACS) library
%   Copyright 2016 Enzo De Sena


alpha = 0.05;

if nargin == 1
    mu = 0;
end

%% Assert
assert(isvector(data));
assert(isscalar(mu));

%% Calculate ll of null hypothesis
[mu_mm_0, k_mm_0, p1_mm_0, p2_mm_0, p3_mm_0] = circ_vmum_est_mm(data, mu);
assert(abs(mu_mm_0-mu)<1e-10);

options = optimoptions('fmincon', ...
        'Display', 'notify-detailed', ...
        'Algorithm', 'sqp', ...
        'MaxFunEvals', 2000);

[params_0, ll_0_neg, exitflag_0] = fmincon(@(params) ...
                   -circ_vmum_ll(mu, params(1), params(2), params(3), params(4), data, true), ...
                   [k_mm_0, p1_mm_0, p2_mm_0, p3_mm_0], [], [], ...
                   [0, 1, 1, 1], 1, ...
                   [-inf, 0, 0, 0], [inf, 1, 1, 1], ...
                   [], options);
ll_0 = -ll_0_neg;

%% Calculate ll of alternate hypothesis
[~, ~, ~, ~, ~, ll_1, exitflag_1, ~] = ...
    circ_vmum_est_ml(data, mu, params_0(1), params_0(2), params_0(3), params_0(4), options);
   
exitflag = min(exitflag_0, exitflag_1);

%% Run test
llrt = -2*(ll_0-ll_1);
P = 1 - chi2cdf(llrt, 1);
H = P < alpha;

end
