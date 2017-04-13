function y = rms(x,dim)
%RMS	Root mean square.
%
% For vectors, RMS(x) returns the root mean square.
% For matrices, RMS(X) is a row vector containing the
% root mean square of each column.
%
% RMS(X,DIM) takes the rms along the dimension DIM of X. 
%
%See also: MEAN, MAX, MIN, STD, NANRMS

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

id = isnan(x);
x(id) = [];

if nargin==1
 y = sqrt(mean(x.^2));
else
 y = sqrt(mean(x.^2,dim));
end
%y = sqrt( sum(x.^2)/length(x));
