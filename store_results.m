function final_res = store_results(final_res, qsim, qobs, ndoner, itarget, settings)

% Compute performance measure

[ns, kge, rmse, pbias, nr] = performance(qsim, qobs, settings.warmup);

% Store final results

final_res(ndoner).qsim_all(:, itarget) = qsim;
final_res(ndoner).qobs_all(:, itarget) = qobs;
final_res(ndoner).ns(itarget)    = ns;
final_res(ndoner).kge(itarget)   = kge;
final_res(ndoner).rmse(itarget)  = rmse;
final_res(ndoner).pbias(itarget) = pbias;
final_res(ndoner).nr(itarget)    = nr;
final_res(ndoner).ndoner         = ndoner;
final_res(ndoner).settings       = settings;

end