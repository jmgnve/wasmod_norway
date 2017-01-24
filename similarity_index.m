function res = similarity_index(data_doner, data_target, catchment_desc)
%SIMILARITY_INDEX Compute similarity index
%   Compute similarity index between doner and target catchments. A small
%   index indicates that the catchments are similar to one another, whereas
%   a large index indicates catchments with large differences in catchment
%   descriptors.

for idoner = 1:length(data_doner)
    
    res(idoner) = 0;
    
    for ifield = 1:length(catchment_desc)
        
        field = ['norm_' catchment_desc{ifield}];
        
        dist = abs(data_doner(idoner).(field) - data_target.(field));
        
        res(idoner) = res(idoner) + dist;
        
    end
    
end

end