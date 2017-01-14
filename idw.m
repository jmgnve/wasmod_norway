function res = idw(qsim_mat, dist)

% Compute weigths

if any(dist==0)
    
    weights = dist==0;
    
    weights = weights / sum(weights);
    
else
    
    weights = 1./dist / sum(1./dist);
    
end

% Compute average runoff

res = weighted_mean(qsim_mat, weights, 2);

end