function res = pbias(sim,obs)
%PBIAS Bias in percent
%   res = pbias(sim,obs)

obs = obs(:);
sim = sim(:);

inan = isnan(obs) | isnan(sim);

obs = obs(~inan);
sim = sim(~inan);

res = 100*(sum(sim)/sum(obs)-1);

end