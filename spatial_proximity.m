function [ns, pb] = spatial_proximity(data, opt_param, settings)

% Settings to variables

ndoner = settings.ndoner;
mc = settings.mc;
method = settings.method;
plot_fig = settings.plot_fig;
pcorr_local = settings.pcorr_local;

% Loop over target catchments

for itarget = 1:length(data)
    
    % Data for target catchment
    
    data_target = data(itarget);
    
    % Data for available doner catchments
    
    data_doner = data;
    data_doner(itarget) = [];
    
    % Distance between target and doner catchments
    
    dist = sqrt(([data_doner(:).x_utm] - data_target.x_utm).^2 + ([data_doner(:).y_utm] - data_target.y_utm).^2);
    
    [dist, isorted] = sort(dist);
    
    % Final selection of doner catchments
    
    idoner = isorted(1:ndoner);
    
    switch method
        
        case 'output_average'
            
            % Run model for all doner catchments
            
            [ip, ed] = prepare_data(data_target, 1);
            
            pa_target = opt_param{itarget};
            
            icounter = 1;
            
            for iwsh = idoner
                
                % Initilize model states
                
                st.AK = 0;
                st.ST = 150;
                
                % Parameter values
                
                pa_doner = opt_param{iwsh};
                
                pa_target.A1 = pa_doner.A1;
                pa_target.A2 = pa_doner.A2;
                pa_target.A3 = pa_doner.A3;
                pa_target.A4 = pa_doner.A4;
                pa_target.A5 = pa_doner.A5;
                pa_target.A6 = pa_doner.A6;
                
                if pcorr_local
                    pa_target.A7 = pa_doner.A7;
                end                
                
                % Run model
                
                sim(icounter) = wasmod(st, ip, pa_target, mc, 1, true);
                
                icounter = icounter + 1;
                
            end
            
            % Outputs to matrices
            
            q_mat = zeros(length(sim(1).Q), ndoner);
            
            for idoner = 1:ndoner
                q_mat(:, idoner) = sim(idoner).Q;
                temp_mat(:, idoner) = sim(idoner).TEMP;
                prec_mat(:, idoner) = sim(idoner).PREC;
                melt_mat(:, idoner) = sim(idoner).MELT;
                rain_mat(:, idoner) = sim(idoner).RAIN;
                fast_mat(:, idoner) = sim(idoner).FAST;
                slow_mat(:, idoner) = sim(idoner).SLOW;
                store_mat(:, idoner) = sim(idoner).STORE;
                aet_mat(:, idoner) = sim(idoner).AET;
            end
            
            % Average outputs
            
            q_ave = mean(q_mat,2);
                        
            % Compute performance measure
            
            ns(itarget) = ns_eff(q_ave(settings.warmup:end),ed.Q(settings.warmup:end));
            pb(itarget) = pbias(q_ave(settings.warmup:end),ed.Q(settings.warmup:end));
            
            % Plot outputs
            
            if plot_fig
                
                figure('position', [100 100 1200 800], 'visible', 'off')
                
                subplot(2,1,1)
                plot(ed.Q, 'r', 'linewidth', 1.2)
                hold on
                plot(q_ave, 'b', 'linewidth', 1)
                axis tight
                box on
                xlabel('Months since start')
                ylabel('Runoff (mm/month')
                title(['Name: ' data_target.name ' Number: ' num2str(data_target.stat)])
                
                message = sprintf(['NS eff = ' num2str(ns(itarget),'%0.2f') '\n' ...
                                   'PBIAS = ' num2str(pb(itarget),'%0.1f')]);
                
                text(0.8, 0.8, message, 'units', 'normalized')
                
                subplot(2,1,2)
                plot(q_mat)
                axis tight
                box on
                xlabel('Months since start')
                ylabel('Runoff (mm/month')
                
                filename = ['figures\' num2str(data_target.stat) '_station.png'];
                
                print('-dpng', '-r600', filename)
                
                close all
                
            end
            
    end
    
end

end