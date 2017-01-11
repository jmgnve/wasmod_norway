
%% Load data

clear

% Load data

load('C:\Users\jmg\Dropbox\Work\Data\avrenningskart_data\norway_data.mat')

% Load parameter values

load('optimal_param\optimal_param.mat')


%% Load experiments table

tbl_exp = readtable('regionalization_experiments.xlsx');


%% Run experiments

settings.warmup   = 37;
settings.mc       = [3 1 1 1];
settings.plot_fig = false;

for iexp = 1:size(tbl_exp,1)
    
    settings.model           = tbl_exp.Model{iexp};
    settings.reg_method      = tbl_exp.Reg_method{iexp};
    settings.cmb_method      = tbl_exp.Cmb_method{iexp};
    settings.weighting       = tbl_exp.Weighting{iexp};
    settings.local_prec_corr = tbl_exp.Local_prec_corr(iexp);
    settings.max_doners      = tbl_exp.Max_doners(iexp);
    settings.run_experiment  = tbl_exp.Run_experiment(iexp);
    
    if settings.run_experiment
        
        disp(['Running experiment ' num2str(iexp)])
        
        run_regionalization(data, settings, opt_param, iexp);
        
    end
    
end























% %% Experiment 1
%
% % Simulation settings
%
% settings.ndoner = 3;
% settings.mc = [3 1 1 1];
% settings.method = 'output_average';
% settings.warmup = 37;
% settings.plot_fig = false;
% settings.pcorr_local = false;
%
% % Spatial proximity method
%
% [ns_1, pb_1] = spatial_proximity(data, opt_param, settings);
%
%
%
%
%
%
% %% Experiment 2
%
% % Simulation settings
%
% settings.ndoner = 5;
% settings.mc = [3 1 1 1];
% settings.method = 'output_average';
% settings.warmup = 37;
% settings.plot_fig = false;
% settings.pcorr_local = false;
%
% % Spatial proximity method
%
% ns_2 = spatial_proximity(data, opt_param, settings);
%
%
% %% Experiment 3
%
% for ndoner = 1:20
%
%     % Simulation settings
%
%     settings.ndoner = ndoner;
%     settings.mc = [3 1 1 1];
%     settings.method = 'output_average';
%     settings.warmup = 37;
%     settings.plot_fig = false;
%     settings.pcorr_local = false;
%
%     % Spatial proximity method
%
%     ns_tmp = spatial_proximity(data, opt_param, settings);
%
%     ns_median(ndoner) = median(ns_tmp);
%     ns_mean(ndoner) = mean(ns_tmp);
%
% end
%
% figure('visible','on')
% plot(ns_median)
% hold on
% plot(ns_mean,'r')
% legend('NS median','NS mean')
%
%
% %% Plot results
%
% figure('visible','on')
%
% plot(ns_1)
% hold on
% plot(ns_2,'r')
% legend('pcorr local = true', 'pcorr local = false')
%
%
%
%
% %% Simply averaging catchment runoff from neighbours
%
% settings.ndoner = 3;
% settings.mc = [3 1 1 1];
% settings.warmup = 37;
% settings.plot_fig = false;
% settings.pcorr_local = false;
%
% [ns, pb] = average_runoff(data, opt_param, settings);
%
% median(ns)
%
% hist(pb,100)
%
%
%
%
