function run_regionalization(data, settings, opt_param, iexp)

% Run regionalization experiment

final_res = regionalization_distance_based(data, opt_param, settings);

% switch settings.reg_method
%     
%     case 'spatial_proximity'
%         
%         final_res = spatial_proximity(data, opt_param, settings);
%         
%     case 'physical_similarity'
%         
%         final_res = physical_similarity(data, opt_param, settings);
%         
% end

% Store results

folder_save = ['results_' num2str(iexp)];

if ~exist(folder_save,'dir')
    mkdir(folder_save)
end

save(fullfile(folder_save, 'final_res.mat'), 'final_res')

% Results to tables

res2table(folder_save, final_res)

end