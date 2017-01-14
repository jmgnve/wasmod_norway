function final_res = spatial_proximity(data, opt_param, settings)

% Settings to variables

max_doners      = settings.max_doners;
mc              = settings.mc;
cmb_method      = settings.cmb_method;
weighting       = settings.weighting;
local_prec_corr = settings.local_prec_corr;
% plot_fig        = settings.plot_fig;

% Compute catchment descriptors

data = catchment_descriptors(data);

% Loop over number of doner catchments

final_res = [];

for ndoner = 1:max_doners
    
    % Loop over target catchments
    
    for itarget = 1:length(data)
        
        % Data for target and doner catchments
        
        data_target = data(itarget);
        data_doner = data;
        data_doner(itarget) = [];
        
        % Compute distance between target and doner catchments
        
        dist = sqrt(([data_doner(:).x_utm] - data_target.x_utm).^2 + ([data_doner(:).y_utm] - data_target.y_utm).^2);
        
        [dist, isorted] = sort(dist);
        
        % Final selection of doner catchments
        
        idoner = isorted(1:ndoner);
        dist = dist(1:ndoner);
        
        % Run regionalization for output average or parameter average method
        
        switch cmb_method
            
            case 'output_average'
                
                % Run model for all doner catchments
                
                [ip, ed] = prepare_data(data_target, 1);
                
                pa_target = opt_param{itarget};
                
                icounter = 1;
                
                for iwsh = idoner
                    
                    % Initilize model states
                    
                    st.AK = 0;
                    st.ST = 150;
                    
                    % Assign parameter values
                    
                    pa_doner = opt_param{iwsh};
                    
                    pa_target.A1 = pa_doner.A1;
                    pa_target.A2 = pa_doner.A2;
                    pa_target.A3 = pa_doner.A3;
                    pa_target.A4 = pa_doner.A4;
                    pa_target.A5 = pa_doner.A5;
                    pa_target.A6 = pa_doner.A6;
                    
                    if local_prec_corr
                        pa_target.A7 = pa_doner.A7;
                    end
                    
                    % Run model
                    
                    sim(icounter) = wasmod(st, ip, pa_target, mc, 1, true);
                    
                    icounter = icounter + 1;
                    
                end
                
                % Assign outputs to matrices
                
                for isim = 1:ndoner
                    qsim_mat(:, isim)  = sim(isim).Q;
                    temp_mat(:, isim)  = sim(isim).TEMP;
                    prec_mat(:, isim)  = sim(isim).PREC;
                    melt_mat(:, isim)  = sim(isim).MELT;
                    rain_mat(:, isim)  = sim(isim).RAIN;
                    fast_mat(:, isim)  = sim(isim).FAST;
                    slow_mat(:, isim)  = sim(isim).SLOW;
                    store_mat(:, isim) = sim(isim).STORE;
                    aet_mat(:, isim)   = sim(isim).AET;
                end
                
                % Average model outputs
                
                switch weighting
                    
                    case 'arithmetic'
                        
                        qsim_ave = mean(qsim_mat, 2);
                        
                    case 'wsh_area'
                        
                        cd_area = [data_doner(idoner).cd_area];
                        
                        qsim_ave = weighted_mean(qsim_mat, cd_area, 2);
                        
                    case 'idw'
                        
                        qsim_ave = idw(qsim_mat, dist);
                        
                end
                
                % Store final results
                
                final_res = store_results(final_res, qsim_ave, ed.Q, ndoner, itarget, settings);
                
            case 'param_average'
                
                
                
                
                
                
                
                
                
                
                
                
        end
        
    end
    
end

end







% % %             % Plot outputs
% % %
% % %             if plot_fig
% % %
% % %                 figure('position', [100 100 1200 800], 'visible', 'off')
% % %
% % %                 subplot(2,1,1)
% % %                 plot(ed.Q, 'r', 'linewidth', 1.2)
% % %                 hold on
% % %                 plot(qsim_ave, 'b', 'linewidth', 1)
% % %                 axis tight
% % %                 box on
% % %                 xlabel('Months since start')
% % %                 ylabel('Runoff (mm/month')
% % %                 title(['Name: ' data_target.name ' Number: ' num2str(data_target.stat)])
% % %
% % %                 message = sprintf(['NS eff = ' num2str(ns(itarget),'%0.2f') '\n' ...
% % %                     'PBIAS = ' num2str(pb(itarget),'%0.1f')]);
% % %
% % %                 text(0.8, 0.8, message, 'units', 'normalized')
% % %
% % %                 subplot(2,1,2)
% % %                 plot(qsim_mat)
% % %                 axis tight
% % %                 box on
% % %                 xlabel('Months since start')
% % %                 ylabel('Runoff (mm/month')
% % %
% % %                 filename = ['figures\' num2str(data_target.stat) '_station.png'];
% % %
% % %                 print('-dpng', '-r600', filename)
% % %
% % %                 close all
% % %
% % %             end