function y = nancumsum(x,dim)
% FORMAT: Y = NANCUMSUM(X,DIM)
% 
%    Cumulative sum of values ignoring NaNs
%
%    NANCUMSUM(X,DIM) calculates the mean along any dimension of the N-D array
%    X ignoring NaNs.  If DIM is omitted NANCUMSUM averages along the first
%    non-singleton dimension of X.
%
%    Similar replacements exist for NANMEAN, NANSTD NANSUM, NANMEDIAN, 
%    NANMIN, and NANMAX which are all part of the NaN-suite.
%
%    Derived from NANSUM, by Jan Gläscher.
%
%    See also CUMSUM

% -------------------------------------------------------------------------
%    $Revision: 342 $ $Date: 2009-04-07 16:25:01 +0200 (Tue, 07 Apr 2009) $

if isempty(x)
	y = [];
	return
end

if nargin < 2
	dim = min(find(size(x)~=1));
	if isempty(dim)
		dim = 1;
	end
end

% Replace NaNs with zeros.
nans = isnan(x);
x(isnan(x)) = 0;

% Protect against all NaNs in one dimension
count = size(x,dim) - sum(nans,dim);

if count==0
y = nan(size(x));
else
y = cumsum(x,dim);    
end


% $Id: nancumsum.m 342 2009-04-07 14:25:01Z boer_g $
