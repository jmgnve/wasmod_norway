function final_res = regionalization_distance_based(data, opt_param, settings)

% Settings to variables

reg_method      = settings.reg_method;
max_doners      = settings.max_doners;
mc              = settings.mc;
cmb_method      = settings.cmb_method;
weighting       = settings.weighting;
doner_prec_corr = settings.doner_prec_corr;
catchment_desc  = strsplit(settings.catchment_desc{1},',');

% Normalize catchment descriptors

data = norm_catchment_desc(data);

% Loop over number of doner catchments

final_res = [];

for ndoner = 1:max_doners
    
    % Loop over target catchments
    
    for itarget = 1:length(data)
        
        % Data for target and doner catchments
        
        data_target = data(itarget);
        data_doner = data;
        data_doner(itarget) = [];
        
        % Compute distance measure
        
        switch reg_method
            
            case 'spatial_proximity'
                
                % Compute distance between target and doner catchments
                
                dist_measure = sqrt(([data_doner(:).x_utm] - data_target.x_utm).^2 + ([data_doner(:).y_utm] - data_target.y_utm).^2);
                
            case 'physical_similarity'
                
                % Compute similarity index
                
                dist_measure = similarity_index(data_doner, data_target, catchment_desc);
                
        end
        
        % Final selection of doner catchments
        
        [dist_measure, isorted] = sort(dist_measure);
        idoner = isorted(1:ndoner);
        dist_measure = dist_measure(1:ndoner);
        
        % Run regionalization for output average or parameter average method
        
        switch cmb_method
            
            case 'output_average'
                
                % Prepare data and parameters
                
                [ip, ed] = prepare_data(data_target, 1);
                
                pa_target = opt_param{itarget};
                
                % Run model for all doner catchments
                
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
                    
                    if doner_prec_corr
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
                        
                    case 'idw'
                        
                        qsim_ave = idw(qsim_mat, dist_measure);
                        
                end
                
                % Store final results
                
                final_res = store_results(final_res, qsim_ave, ed.Q, ndoner, itarget, settings);
                
            case 'param_average'
                
                % Prepare data and parameters
                
                [ip, ed] = prepare_data(data_target, 1);
                
                pa_target = opt_param{itarget};
                
                % Assign doner catchment parameter values to matrix
                
                icounter = 1;
                
                for iwsh = idoner
                    
                    pa_doner = opt_param{iwsh};
                    
                    A(1,icounter) = pa_doner.A1;
                    A(2,icounter) = pa_doner.A2;
                    A(3,icounter) = pa_doner.A3;
                    A(4,icounter) = pa_doner.A4;
                    A(5,icounter) = pa_doner.A5;
                    A(6,icounter) = pa_doner.A6;
                    A(7,icounter) = pa_doner.A7;
                    
                    icounter = icounter + 1;
                    
                end
                
                % Average parameter values
                
                switch weighting
                    
                    case 'arithmetic'
                        
                        A = mean(A, 2);
                        
                    case 'idw'
                        
                        A = idw(A, dist_measure);
                        
                end
                
                % Assign parameter values
                
                pa_target.A1 = A(1);
                pa_target.A2 = A(2);
                pa_target.A3 = A(3);
                pa_target.A4 = A(4);
                pa_target.A5 = A(5);
                pa_target.A6 = A(6);
                
                if doner_prec_corr
                    pa_target.A7 = A(7);
                end
                
                % Initilize model states
                
                st.AK = 0;
                st.ST = 150;
                
                % Run model
                
                sim = wasmod(st, ip, pa_target, mc, 1, true);
                
                % Store final results
                
                final_res = store_results(final_res, sim.Q, ed.Q, ndoner, itarget, settings);
                
        end
        
    end
    
end

end


