function Y = make1D(X,varargin)
%MAKE1D   reshape multi-dimensional matrix to vector
%
% same as Y = X(:) but very useful in
% expressions with subindexing like 
% Y = make1d(X(m1:m2,n1:n2,k1:k2))
%
% Y = make1D(x,'row')      returns a row    [1 x length(y)]
% Y = make1D(x,'col<umn>') returns a column [length(y) x 1]
%
% See also: RESHAPE, PERMUTE, SQUEEZE

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

% G.J. de Boer, 2004

%Y = reshape(X,[prod(size(X)),1]);

Y = X(:); % [column x 1]
if nargin > 1
    if strcmpi(varargin{1}(1:3),'row')
        Y = Y'; % [1 x row]
    end
end