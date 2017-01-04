function NS = run_calib(ip,ed,settings)
%RUN_CALIB Calibration of WASMOOD
%
%   Function call:
%   NS = run_calib(ip,ed,settings)
%
%   Input variables:
%   ip - struct containing input variables
%   ed - struct containing evaluation data
%   settings - struct containing settings

% Parameter limits for actual evapotranspiration model 1

if settings.mc(2) == 1
    A_lower = [0   -0.5   0     0     0    0   0.08];
    A_upper = [1     0    2     1     10   10  0.20];
end

% Parameter limits for actual evapotranspiration model 2

if settings.mc(2) == 2
    A_lower = [0   -0.5   0     0     0    0   0.08];
    A_upper = [1     0    2     10    10   10  0.20];
end

% Run Monte Carlo simulations

st.AK = settings.AK;
st.ST = settings.ST;

pa.A1 = A_lower(1) + (A_upper(1)-A_lower(1))*rand(1,settings.nruns);
pa.A2 = A_lower(2) + (A_upper(2)-A_lower(2))*rand(1,settings.nruns);
pa.A3 = A_lower(3) + (A_upper(3)-A_lower(3))*rand(1,settings.nruns);
pa.A4 = A_lower(4) + (A_upper(4)-A_lower(4))*rand(1,settings.nruns);
pa.A5 = A_lower(5) + (A_upper(5)-A_lower(5))*rand(1,settings.nruns);
pa.A6 = A_lower(6) + (A_upper(6)-A_lower(6))*rand(1,settings.nruns);
pa.A7 = A_lower(7) + (A_upper(7)-A_lower(7))*rand(1,settings.nruns);

pa.fa = ip.fa;

sim = wasmod(st,ip,pa,settings.mc,settings.nruns,false);

err = repmat(ed.Q,settings.nruns,1) - sim.Q;
err = err(:,settings.warmup:end);
err = err(:,~any(isnan(err),1));
sse = sum(err.^2,2);
imin = find(sse==min(sse),1);

% Optimize parameters using fminsearch

A_init  = [pa.A1(imin) pa.A2(imin) pa.A3(imin) pa.A4(imin) pa.A5(imin) pa.A6(imin) pa.A7(imin)];

par = fminsearchbnd(@(A) wasmod_wrapper(A,ip,settings,ed.Q),A_init,A_lower,A_upper,optimset('Display','on','MaxFunEvals',20000,'MaxIter',20000));

% Run simulation with optimized parameters

st.AK = settings.AK;  % Snow storage
st.ST = settings.ST;  % Land moisture

pa.A1 = par(1);
pa.A2 = par(2);
pa.A3 = par(3);
pa.A4 = par(4);
pa.A5 = par(5);
pa.A6 = par(6);
pa.A7 = par(7);

pa.fa = ip.fa;

sim = wasmod(st,ip,pa,settings.mc,1,true);

NS = ns_eff(sim.Q(settings.warmup:end),ed.Q(settings.warmup:end));

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
disp(['A(7) = ' num2str(par(7))])

disp('Optimal performance:')
disp(['NS eff = ' num2str(NS)])

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
        ['  prec corr = ' num2str(10*par(7))];
        '';
        'Optimal performance:';
        ['  NS eff = ' num2str(NS)];
        '';
        'Runoff efficiency:';
        ['  Q/P = ' num2str(ip.re_eff)]};
        
% Plot results

figure('position',[100 100 1400 800],'visible','off')

ax(1) = subplot('position',[0.1 0.7 0.6 1/4]);

plot(ed.Q(settings.warmup:end),'linewidth',1.5,'color',[0.4 0.4 0.4])
hold on
plot(sim.Q(settings.warmup:end),'r')
ylabel('Discharge')
legend('Obs','Sim')
text(1.05,0,info,'units','normalized')
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

print(['results\',ip.name '_' mc_str '.png'],'-dpng','-r400')

close all

end

