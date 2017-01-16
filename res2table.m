function res2table(folder_save, final_res)

% From struct to matrices

for irun = 1:length(final_res)
    
%     colname{irun} = [num2str(final_res(irun).ndoner) '_n'];
    
    ns_table(:, irun)    = final_res(irun).ns(:);
    kge_table(:, irun)   = final_res(irun).kge(:);
    rmse_table(:, irun)  = final_res(irun).rmse(:);
    pbias_table(:, irun) = final_res(irun).pbias(:);
    
end

% From matrices to tables

ns_table    = array2table(ns_table); %, 'VariableNames', colname);
kge_table   = array2table(kge_table); %, 'VariableNames', colname);
rmse_table  = array2table(rmse_table); %, 'VariableNames', colname);
pbias_table = array2table(pbias_table); %, 'VariableNames', colname);

% Write files

writetable(ns_table, fullfile(folder_save,'ns_table.txt'))
writetable(kge_table, fullfile(folder_save,'kge_table.txt'))
writetable(rmse_table, fullfile(folder_save,'rmse_table.txt'))
writetable(pbias_table, fullfile(folder_save,'pbias_table.txt'))

% Write warnings

if any(any(ismissing(ns_table))); warning('NaN in NSE results'); end
if any(any(ismissing(kge_table))); warning('NaN in KGE results'); end
if any(any(ismissing(rmse_table))); warning('NaN in RMSE results'); end
if any(any(ismissing(pbias_table))); warning('NaN in PBIAS results'); end

end
