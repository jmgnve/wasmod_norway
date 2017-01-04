function [time,res] = monthlymean(time,data)
% MONTHLYMEAN Compute montly average values
%
%   Function call:
%   [time,res] = monthlymean(time,data)

if ~any(length(time)~=size(data,1) || length(time)~=size(data,2))
    error('time and data has different length')
end

[~,~,dd] = datevec(time);

ibreak = find(dd==1);

for i = 1:length(ibreak)-1
    
    iwin = ibreak(i):ibreak(i+1)-1;
    
    if size(data,1) == length(time)
        res(i,:) = mean(data(iwin,:),1);
    end
    
    if size(data,2) == length(time)
        res(:,i) = mean(data(:,iwin),2);
    end
    
end

time = time(ibreak(1:end-1));

end