function res = ns_eff(sim,obs)
%NS_EFF Nash-Sutcliffe efficiency
%    res = ns_eff(sim,obs)

obs = obs(:);
sim = sim(:);

inan = isnan(obs) | isnan(sim);

obs = obs(~inan);
sim = sim(~inan);

res = 1-sum((obs-sim).^2)/sum((obs-mean(obs)).^2);

end