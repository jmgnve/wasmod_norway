
%% Load data

clear

load('C:\Users\jmg\Dropbox\Work\Data\hydro_data\norway_data.mat')


%% Model combinations

counter = 1;

for mc_1 = [1 3 4]
    for mc_2 = [1 2]
        for mc_3 = [1 2]
            for mc_4 = [1 2]
                mc(1,counter) = mc_1;
                mc(2,counter) = mc_2;
                mc(3,counter) = mc_3;
                mc(4,counter) = mc_4;
                counter = counter + 1;
            end
        end
    end
end


%% Calibrate model

for imc = 1:size(mc,2)
    
    for iwsh = 1:length(data)
        
        % Prepare data
        
        [ip,ed] = prepare_data(data,iwsh);
        
        % Model settings
        
        settings.mc = mc(:,imc);
        settings.warmup = 37;
        settings.nruns = 100000;
        settings.AK = 0;   % Initial snow storage
        settings.ST = 150; % Initial land moisture
        
        % Run calibration
        
        ns(iwsh,imc) = run_calib(ip,ed,settings);
        
    end
    
end


%% Save results

save('results.mat', 'ns', 'mc');






