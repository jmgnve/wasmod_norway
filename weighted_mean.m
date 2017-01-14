function res = weighted_mean(x, weights, dim)
%WEIGHTED_MEAN Weighted mean
%   Take the weighted mean along the columns (dim = 1) or along the
%   rows (dim = 2)

% Scale sum of weights to unity

weights = weights / sum(weights);

% Compute average along columns

if dim == 1
    
    if size(x,1) ~= length(weights)
        error('Dimensions of x and dim mismatch')
    end
    
    weights = repmat(weights(:), 1, size(x, 2));
    
    res = sum(weights .* x, 1);
    
end

% Compute weights along rows

if dim == 2
    
    if size(x,2) ~= length(weights)
        error('Dimensions of x and dim mismatch')
    end
    
    weights = repmat(weights(:)', size(x, 1), 1);
    
    res = sum(weights .* x, 2);
    
end

end