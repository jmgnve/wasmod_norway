function run_regionalization(data, settings, opt_param, iexp)

% Run regionalization experiment

switch settings.reg_method
    
    case 'spatial_proximity'
        
        final_res = spatial_proximity(data, opt_param, settings);
        
    case 'physical_similarity'
        
        
        
        
end

% Store results

folder_save = ['results_' num2str(iexp)];

if ~exist(folder_save,'dir')
    mkdir(folder_save)
end

save(fullfile(folder_save, 'final_res.mat'), 'final_res')

end