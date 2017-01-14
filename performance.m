function [ns, kge, rmse, pbias, nr] = performance(sim, obs, warmup)

% Remove warmup period

sim = sim(warmup:end);
obs = obs(warmup:end);

% To column vectors

sim = sim(:);
obs = obs(:);

% Remove missing data

ikeep = ~isnan(sim) & ~isnan(obs);

sim = sim(ikeep);
obs = obs(ikeep);

% Nash-Sutcliffe efficiency

ns = 1-sum((obs-sim).^2)/sum((obs-mean(obs)).^2);

% Kling-Gupta efficiency

r_tmp = corrcoef(obs,sim);
r = r_tmp(2,1);

beta = mean(sim)/mean(obs);

cv_sim = std(sim)/mean(sim);
cv_obs = std(obs)/mean(obs);
gamma = cv_sim/cv_obs;

term1 = (r-1)^2;
term2 = (beta-1)^2;
term3 = (gamma-1)^2;

kge = 1 - (term1 + term2 + term3)^0.5;

% Root-mean-squared-error

rmse = sqrt(mean((obs-sim).^2));

% Percent bias

pbias = 100*(sum(sim)/sum(obs)-1);

% Number of data points

nr = sum(ikeep);

end