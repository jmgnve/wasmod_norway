function [time,res] = annualsum(time,data)
% ANNUALSUM Compute annual sum of values
%   [time,res] = annualmean(time,data)
%   time - vector in matlab time format
%   data - vector with values

if ~isvector(time)
    error('time not a vector');
end

if ~isvector(data)
    error('data not a vector');
end

if length(time)~=length(data)
    error('time and data has different length')
end

[~,mm,dd] = datevec(time);

ibreak = find(mm==10 & dd==1);

for i = 1:length(ibreak)-1
    
    iwin = ibreak(i):ibreak(i+1)-1;
    
    res(i,:) = sum(data(iwin));
    
end

time = time(ibreak(1:end-1));

end









