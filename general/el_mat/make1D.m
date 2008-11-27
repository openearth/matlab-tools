function Y = make1D(X)
%MAKE1D
%
% same as Y = X(:) but very useful in
% expressions with subindexing like 
% Y = make1d(X(m1:m2,n1:n2,k1:k2))
%
% G.J. de Boer, 2004
%
% See also: reshape

%Y = reshape(X,[prod(size(X)),1]);

Y = X(:);