
%% LOAD DATA

clear

load('C:\Users\jmg\Dropbox\Work\Data\hydro_data\norway_data.mat')


%% CALIBRATE MODEL

for iwsh = 1:10
    
    % Prepare data

    [ip,ed] = prepare_data(data,iwsh);
    
    % Model settings
    
    settings.mc = [4 2 2 2];
    settings.warmup = 37;
    settings.nruns = 10000;
    settings.AK = 0;   % Initial snow storage
    settings.ST = 150; % Initial land moisture
    
    % Run calibration
    
    ns(iwsh) = run_calib(ip,ed,settings);
    
end