function data = catchment_descriptors(data)

for istat = 1:length(data)
    
%     data(istat).cd_area = (data(istat).area - mean([data(:).area])) / std([data(:).area]);
    
    data(istat).cd_area = data(istat).area / ( max([data(:).area])-min([data(:).area]) );
    
end

end