
%% Load data

clc
clear

% Load data

load('C:\Users\jmg\Dropbox\Work\Data\avrenningskart_data\norway_data.mat')

% Load parameter values

load('calibration_results\optimal_param.mat')


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
    settings.doner_prec_corr = tbl_exp.Doner_prec_corr(iexp);
    settings.max_doners      = tbl_exp.Max_doners(iexp);
    settings.run_experiment  = tbl_exp.Run_experiment(iexp);
    
    if settings.run_experiment
        
        disp(['Running experiment ' num2str(iexp)])
        
        run_regionalization(data, settings, opt_param, iexp);
        
    end
    
end




