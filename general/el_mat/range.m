function y = range(x,varargin)
%RANGE  difference between maximum and minimum values.
%
%   Y = range(X) returns the range of the values in X.  For a vector input,
%   Y is the difference between the maximum and minimum values.  For a
%   matrix input, Y is a vector containing the range for each column.  For
%   N-D arrays, range operates along the first non-singleton dimension.
%
%   Y = range(X,   dim) and
%   Y = range(X,[],dim) operate along the dimension dim.
%
%   Y = range(X,0) is same as range(x(:))
%
%   Just like min(...) and max(...), range(...) treats NaNs 
%   as missing values, and ignores them.
%
%   See also MAX, MIN, STD, MEAN, RSS, RMS, RANGESIGNED, IQR, MAD

%   © G.J. de Boer, Dec 2004, Delft University of Technology


if nargin < 2
   y = max(x) - min(x);
else
   if nargin==2
      dim = varargin{1};
   elseif nagrin==3
      dim = varargin{2}; % to have same syntax as min and max
   end
   
   if dim==0
      y = max(x(:)) - min(x(:));
   else
     y = max(x,[],dim) - min(x,[],dim);
   end
end
