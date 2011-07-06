function Y = make1D(X)
%MAKE1D   reshape multi-dimensial matrix as matrix(:)
%
% same as Y = X(:) but very useful in
% expressions with subindexing like 
% Y = make1d(X(m1:m2,n1:n2,k1:k2))
%
% See also: RESHAPE, PERMUTE

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

% G.J. de Boer, 2004

%Y = reshape(X,[prod(size(X)),1]);

Y = X(:);