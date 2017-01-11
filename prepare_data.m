function [ip,ed] = prepare_data(data,iwsh)
%PREPARE_DATA Prepare monthly data of Norwegian catchments for wasmod
%
%   Function call:
%   [ip,ed] = prepare_data(data,sel_stat)

time  = data(iwsh).time;
Q     = data(iwsh).Qobs;
P     = data(iwsh).P;
Ta    = data(iwsh).TA;

% Input data

ip.time     = time;
ip.PT       = P;
ip.CT       = Ta;
ip.HT       = zeros(size(ip.PT));
ip.stat     = data(iwsh).stat;
ip.name     = data(iwsh).name;
ip.area     = data(iwsh).area;
ip.fa       = data(iwsh).frac_zones;
ip.aet_ave  = data(iwsh).aet_mean;

% Precipitation catchment average

prec_wsh_mean = sum(data(iwsh).P .* repmat(ip.fa,1,length(time)),1);

ip.prec_ave = 12*mean(prec_wsh_mean);

ip.CT_ave = nan(size(ip.CT));
ip.ET     = nan(size(ip.CT));

[~,mm,~] = datevec(time);

ET_sweden = [0.50 3.50 13.50 43.00 91.50 122.50 115.50 85.50 43.00 13.00 0.50 0];

for i = 1:12
    
    itime = find(mm==i);
    
    ip.CT_ave(:,itime) = repmat(mean(ip.CT(:,itime),2),1,length(itime));
    ip.ET(:,itime)     = ET_sweden(i);   
    
end

% Evaluation data

ed.time = time;
ed.Q    = Q;
ed.stat = data(iwsh).stat;
ed.name = data(iwsh).name;
ed.area = data(iwsh).area;
ed.fa   = data(iwsh).frac_zones;

% Compute runoff efficiency

re_eff = prec_wsh_mean./Q;
re_eff = mean(re_eff(~isnan(re_eff)));

ip.re_eff = re_eff;

end