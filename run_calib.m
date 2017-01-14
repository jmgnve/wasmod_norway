function [ns, pa] = run_calib(ip,ed,settings)
%RUN_CALIB Calibration of WASMOOD
%
%   Function call:
%   [ns, pa] = run_calib(ip,ed,settings)
%
%   Input variables:
%   ip - struct containing input variables
%   ed - struct containing evaluation data
%   settings - struct containing settings

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameter limits for actual evapotranspiration model 1

if settings.mc(2) == 1
    A_lower = [0   -6    0     0     0    0];
    A_upper = [6    0    2     1     10   10];
end

% Parameter limits for actual evapotranspiration model 2

if settings.mc(2) == 2
    A_lower = [0   -6    0     0     0    0];
    A_upper = [6    0    2     10    10   10];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute precipitation correction factor

q_ave = 12 * mean(ed.Q(~isnan(ed.Q)));
aet_ave = ip.aet_ave;
prec_ave = ip.prec_ave;

A7 = (q_ave + aet_ave) / prec_ave;

A7 = A7 / 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run Monte Carlo simulations

st.AK = settings.AK;
st.ST = settings.ST;

pa.A1 = A_lower(1) + (A_upper(1)-A_lower(1))*rand(1,settings.nruns);
pa.A2 = A_lower(2) + (A_upper(2)-A_lower(2))*rand(1,settings.nruns);
pa.A3 = A_lower(3) + (A_upper(3)-A_lower(3))*rand(1,settings.nruns);
pa.A4 = A_lower(4) + (A_upper(4)-A_lower(4))*rand(1,settings.nruns);
pa.A5 = A_lower(5) + (A_upper(5)-A_lower(5))*rand(1,settings.nruns);
pa.A6 = A_lower(6) + (A_upper(6)-A_lower(6))*rand(1,settings.nruns);

pa.A7 = A7;
pa.fa = ip.fa;

sim = wasmod(st, ip, pa, settings.mc, settings.nruns, false);

for irun = 1:settings.nruns
    ns_vec(irun) = performance(sim.Q(irun,:), ed.Q, settings.warmup);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot Monte Carlo results

if settings.plot_res
    
    figure('position',[100 100 1400 800],'visible','off')
    
    subplot(3,2,1)
    plot(pa.A1(ns_vec>0), ns_vec(ns_vec>0), '.')
    xlabel('A1')
    ylabel('NS eff')
    title('Snow param 1')
    
    subplot(3,2,2)
    plot(pa.A2(ns_vec>0), ns_vec(ns_vec>0), '.')
    xlabel('A2')
    ylabel('NS eff')
    title('Snow param 2')
    
    subplot(3,2,3)
    plot(pa.A3(ns_vec>0), ns_vec(ns_vec>0), '.')
    xlabel('A3')
    ylabel('NS eff')
    title('PET param')
    
    subplot(3,2,4)
    plot(pa.A4(ns_vec>0), ns_vec(ns_vec>0), '.')
    xlabel('A4')
    ylabel('NS eff')
    title('AET param')
    
    subplot(3,2,5)
    plot(pa.A5(ns_vec>0), ns_vec(ns_vec>0), '.')
    xlabel('A5')
    ylabel('NS eff')
    title('Slow flow param')
    
    subplot(3,2,6)
    plot(pa.A6(ns_vec>0), ns_vec(ns_vec>0), '.')
    xlabel('A6')
    ylabel('NS eff')
    title('Fast flow param')
    
    mc_str = [num2str(settings.mc(1)) num2str(settings.mc(2)) num2str(settings.mc(3)) num2str(settings.mc(4))];
    
    print(['calibration_results\figures\', num2str(ip.stat) '_' mc_str '_dottyplt.png'],'-dpng','-r400')
    
    close all
    
end

% NS_mat = [pa.A1(NS_vec>0)' pa.A2(NS_vec>0)' pa.A3(NS_vec>0)' ...
%           pa.A4(NS_vec>0)' pa.A5(NS_vec>0)' pa.A6(NS_vec>0)' ...
%           pa.A7(NS_vec>0)'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Optimize parameters using fminsearch

imax = find(ns_vec==max(ns_vec),1);

A_init  = [pa.A1(imax) pa.A2(imax) pa.A3(imax) pa.A4(imax) pa.A5(imax) pa.A6(imax)];

par = fminsearchbnd(@(A) wasmod_wrapper(A, A7, ip, settings,ed.Q), A_init, A_lower, A_upper,optimset('Display','on','MaxFunEvals',20000,'MaxIter',20000));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Run simulation with optimized parameters

st.AK = settings.AK;  % Snow storage
st.ST = settings.ST;  % Land moisture

pa.A1 = par(1);
pa.A2 = par(2);
pa.A3 = par(3);
pa.A4 = par(4);
pa.A5 = par(5);
pa.A6 = par(6);

pa.A7 = A7;
pa.fa = ip.fa;

sim = wasmod(st, ip, pa, settings.mc, 1, true);

ns = performance(sim.Q, ed.Q, settings.warmup);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print optimal parameters

disp('WASMOD setup:')
disp(['PE model = ' num2str(settings.mc(1))])
disp(['AE model = ' num2str(settings.mc(2))])
disp(['B1 = ' num2str(settings.mc(3))])
disp(['B2 = ' num2str(settings.mc(4))])

disp('Optimal parameters:')
disp(['A(1) = ' num2str(par(1))])
disp(['A(2) = ' num2str(par(2))])
disp(['A(3) = ' num2str(par(3))])
disp(['A(4) = ' num2str(par(4))])
disp(['A(5) = ' num2str(par(5))])
disp(['A(6) = ' num2str(par(6))])
disp(['A(7) = ' num2str(A7)])

disp('Optimal performance:')
disp(['NS eff = ' num2str(ns)])

% Check water balance

check_wb(settings,sim);

% Info

info = {'WASMOD setup:';
    ['  PE model = ' num2str(settings.mc(1))];
    ['  AE model = ' num2str(settings.mc(2))];
    ['  B1 = ' num2str(settings.mc(3))];
    ['  B2 = ' num2str(settings.mc(4))];
    '';
    'Optimal parameters (scaled):';
    ['  A(1) = ' num2str(par(1))];
    ['  A(2) = ' num2str(par(2))];
    ['  A(3) = ' num2str(par(3))];
    ['  A(4) = ' num2str(par(4))];
    ['  A(5) = ' num2str(par(5))];
    ['  A(6) = ' num2str(par(6))];
    ['  prec corr = ' num2str(10*A7) ' unscaled!'];
    '';
    'Actual evapotranspiration:';
    ['  Simulated = ' num2str(12*mean(sim.AET))];
    ['  Satellite = ' num2str(mean(ip.aet_ave))];
    '';
    'Optimal performance:';
    ['  NS eff = ' num2str(ns)];
    '';
    'Runoff efficiency:';
    ['  Q/P = ' num2str(ip.re_eff)]};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot results

if settings.plot_res
    
    figure('position',[100 100 1400 800],'visible','off')
    
    ax(1) = subplot('position',[0.1 0.7 0.6 1/4]);
    
    plot(ed.Q(settings.warmup:end),'linewidth',1.5,'color',[0.4 0.4 0.4])
    hold on
    plot(sim.Q(settings.warmup:end),'r')
    ylabel('Discharge')
    legend('Obs','Sim')
    text(1.05,-0.3,info,'units','normalized')
    title(['Watershed: ' ip.name ' | Area: ' num2str(ip.area) ' km2'])
    
    ax(2) = subplot('position',[0.1 0.4 0.6 1/4]);
    
    plot(sim.STORE(settings.warmup:end))
    ylabel('Storage')
    
    ax(3) = subplot('position',[0.1 0.1 0.6 1/4]);
    
    plot(sim.EPT(settings.warmup:end),'linewidth',1.5,'color',[0.4 0.4 0.4])
    hold on
    plot(sim.AET(settings.warmup:end),'r')
    ylabel('Evaporation')
    legend('EPT','AET')
    xlabel('Months after start of simulation period')
    
    linkaxes(ax,'x')
    
    mc_str = [num2str(settings.mc(1)) num2str(settings.mc(2)) num2str(settings.mc(3)) num2str(settings.mc(4))];
    
    print(['calibration_results\figures\', num2str(ip.stat) '_' mc_str '_tseris.png'],'-dpng','-r400')
    
    close all
    
end

end

