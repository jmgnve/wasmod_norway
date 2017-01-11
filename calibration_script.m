
%% Load data

clear

load('C:\Users\jmg\Dropbox\Work\Data\avrenningskart_data\norway_data.mat')


%% Model combinations

counter = 1;

% for mc_1 = [1 3 4]
%     for mc_2 = [1 2]
%         for mc_3 = [1 2]
%             for mc_4 = [1 2]
%                 mc(1,counter) = mc_1;
%                 mc(2,counter) = mc_2;
%                 mc(3,counter) = mc_3;
%                 mc(4,counter) = mc_4;
%                 counter = counter + 1;
%             end
%         end
%     end
% end

for mc_1 = [3]
    for mc_2 = [1]
        for mc_3 = [1]
            for mc_4 = [1]
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
        settings.plot_res = true;
        
        % Run calibration
        
        [ns(iwsh,imc), opt_param{iwsh,imc}] = run_calib(ip,ed,settings);
        
    end
    
end


%%%%%%%%% THIS WILL NOT WORK FOR MANY COMBINATIONS! NEEDS FIX! %%%%%%%%%%%%


%% Remove duplicate stations

% rowname = {data(:).name};
% 
% [~, ikeep] = unique(rowname);
% 
% data = data(ikeep);
% ns = ns(ikeep);
% opt_param = opt_param(ikeep);


%% Results to table

for irow = 1:length(data)
    rowname{irow} = num2str(data(irow).stat);
end

for icol = 1:size(mc,2)
    colname{icol} = ['mc_' num2str(mc(1,icol)) num2str(mc(2,icol)) num2str(mc(3,icol)) num2str(mc(4,icol))];
end

res_table = array2table(ns); 

res_table.Properties.RowNames = rowname;
res_table.Properties.VariableNames = colname;

writetable(res_table, 'tables\wasmod_nseff.csv', 'Delimiter', ';', 'WriteVariableNames', true, 'WriteRowNames', true)


%% Save optimal parameter values

save('optimal_param\optimal_param.mat', 'opt_param')






