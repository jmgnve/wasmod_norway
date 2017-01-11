function [ns, pb] = average_runoff(data, opt_param, settings)

% Settings to variables

ndoner = settings.ndoner;
mc = settings.mc;
plot_fig = settings.plot_fig;
pcorr_local = settings.pcorr_local;

% Fill gaps in observed runoff by simulation

Q_obs = [];

for iwsh = 1:length(data)
    
    % Run model for all doner catchments
    
    [ip, ed] = prepare_data(data, iwsh);
    
    pa = opt_param{iwsh};
    
    st.AK = 0;
    st.ST = 150;

    sim = wasmod(st, ip, pa, mc, 1, false);
    
    % Fill gaps in observations with simulations
    
    inan = isnan(ed.Q);
    
    if ~isempty(inan)
        ed.Q(inan) = sim.Q(inan);
    end
    
    Q_obs = [Q_obs; ed.Q];
   
end

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
    
    % Compute average discharge for target catchment
    
    q_ave = mean(Q_obs(idoner, :),1);
    
    % Compute performance measure
    
    [~, ed] = prepare_data(data, itarget);
    
    ns(itarget) = ns_eff(q_ave(settings.warmup:end),ed.Q(settings.warmup:end));
    pb(itarget) = pbias(q_ave(settings.warmup:end),ed.Q(settings.warmup:end));
    
    % Plot results
    
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