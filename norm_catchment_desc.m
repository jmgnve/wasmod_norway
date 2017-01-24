function data = norm_catchment_desc(data)

fields = {'area', 'elev_median', 'lus_agri', 'lus_bogs', 'lus_fore', ...
    'lus_glac', 'lus_lake', 'lus_lveg', 'lus_other', 'lus_urba'};

for ifield = 1:length(fields)
    
    for istat = 1:length(data)
        
        cd_range = max([data(:).(fields{ifield})]) - min([data(:).(fields{ifield})]);
        
        data(istat).(['norm_' fields{ifield}]) = data(istat).(fields{ifield}) / cd_range;
        
    end
    
end

end