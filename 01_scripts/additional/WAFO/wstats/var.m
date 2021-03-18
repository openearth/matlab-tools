function y = var(x, dim)
%VAR  Variance
%
%   CALL: v = var(X,dim);
%
%     v  = Sample variance (second central moment)
%     X  = data vector or matrix
%   dim = dimension to sum across. (default 1'st non-singleton dimension of X)
% 
% Example:
%    R = wgumbrnd(2,2,[],100,2);
%   var(R)
%
% See also  wskewness, wkurtosis, mean




if nargin < 2
    % The output size for [] is a special case when DIM is not given.
    if isequal(x,[]), y = NaN(class(x)); return; end

    % Figure out which dimension sum will work along.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = 1; end
end
n = size(x,dim);

% Will replicate out the mean of X to the same size as X.
tile = ones(1,max(ndims(x),dim)); tile(dim) = n;

% Unweighted variance
if 1 %isequal(w,0) || isequal(w,1)
    if  n > 1
        % The unbiased estimator: divide by (n-1).  Can't do this
        % when n == 0 or 1.
        denom = n - 1;
    else
        % The biased estimator: divide by n.
        denom = n; % n==0 => return NaNs, n==1 => return zeros
    end

    if n > 0
        xbar = sum(x, dim) ./ n;
        if isscalar(xbar)
            x0 = x - xbar;
        else
            x0 = x - repmat(xbar, tile);
        end
    else % prevent redundant divideByZero warnings
        x0 = x;
    end
    y = sum(abs(x0).^2, dim) ./ denom; % abs guarantees a real result

else
    error('MATLAB:var:invalidWgts','W must be a vector of nonnegative weights, or a scalar 0 or 1.');
end
%v = std(varargin{:}).^2;
return
