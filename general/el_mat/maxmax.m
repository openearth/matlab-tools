function [varargout] = maxmax(x,varargin);
%MAXMAX    Calculates minimum of all dimensions of an array.
%
%   max_of_x = maxmax(x) calculates maximum of all dimensions
%   of array x. Similar to max(array(:)), but useful when you 
%   would like to have the maximum of a subset of an n-dimensional 
%   array, in which case it is not possible to use a single
%   colon symbol ':' to treat the array as 1-dimensional.
%
%   max_of_x = maxmax(x,'no_inf') does not take into account +Inf
%   if such a value is present in the array. So
%   minmin = ([+Inf,1]) is 1;
%
%    Example:
%    maxmax(array(1:floor(end/2),ceil(end/2):end,:))
%
%   See also: MINMIN
%
%   G.J. de Boer, Delft Univeristy of Technology
%   Feb 2004, version 1.0

if nargin == 2
   x(isinf(x))=nan;
end

 varargout = {max(x(:))};
%varargout = {max(reshape(x,prod(size(x)),1))};
