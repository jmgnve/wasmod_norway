
%% Preparations

clear

% Load data

load('C:\Users\jmg\Dropbox\Work\Data\avrenningskart_data\norway_data.mat')

% Load parameter values

load('optimal_param\optimal_param.mat')


%% Experiment 1

% Simulation settings

settings.ndoner = 3;
settings.mc = [3 1 1 1];
settings.method = 'output_average';
settings.warmup = 37;
settings.plot_fig = false;
settings.pcorr_local = false;

% Spatial proximity method

[ns_1, pb_1] = spatial_proximity(data, opt_param, settings);






%% Experiment 2

% Simulation settings

settings.ndoner = 5;
settings.mc = [3 1 1 1];
settings.method = 'output_average';
settings.warmup = 37;
settings.plot_fig = false;
settings.pcorr_local = false;

% Spatial proximity method

ns_2 = spatial_proximity(data, opt_param, settings);


%% Experiment 3

for ndoner = 1:20
    
    % Simulation settings
    
    settings.ndoner = ndoner;
    settings.mc = [3 1 1 1];
    settings.method = 'output_average';
    settings.warmup = 37;
    settings.plot_fig = false;
    settings.pcorr_local = false;
    
    % Spatial proximity method
    
    ns_tmp = spatial_proximity(data, opt_param, settings);
    
    ns_median(ndoner) = median(ns_tmp);
    ns_mean(ndoner) = mean(ns_tmp);

end

figure('visible','on')
plot(ns_median)
hold on
plot(ns_mean,'r')
legend('NS median','NS mean')


%% Plot results

figure('visible','on')

plot(ns_1)
hold on
plot(ns_2,'r')
legend('pcorr local = true', 'pcorr local = false')




%% Simply averaging catchment runoff from neighbours

settings.ndoner = 3;
settings.mc = [3 1 1 1];
settings.warmup = 37;
settings.plot_fig = false;
settings.pcorr_local = false;

[ns, pb] = average_runoff(data, opt_param, settings);

median(ns)

hist(pb,100)




