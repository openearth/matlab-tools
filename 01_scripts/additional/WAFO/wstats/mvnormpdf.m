function pdf = mvnormpdf(X,m,S)
%MVNORMPDF Multivariate Normal probability density function.  
%
% CALL: pdf = mvnormpdf(X,m,S)
%
%   X = matrix of evaluation points
%   m = mean              (default zero vector)
%   S = Covariance matrix (default identity matrix)
%
% Example: % Bivariate Gaussian distribution
% x = linspace(-5,5);
% [X1 X2] = meshgrid(x);
% f = reshape(mvnormpdf([X1(:),X2(:)]),100,100);
% [area,epsi] = simpson(x,f);
% [area2,epsi2] = simpson(x,area);
%
%See also  wnormpdf

%History
% Revised pab 11nov2003  
% By pab 2002  
error(nargchk(1,3,nargin))


[n,d]=size(X);

if nargin<2|isempty(m),
  m = zeros(1,d);
end
if nargin<3|isempty(S),
  S = eye(d);
end
if any(d~=size(S))
  error(sprintf('Covariance matrix must have %d dimensions',d))
end



den = (2*pi*det(S))^(d/2);
if den< eps,
  error('Covariance matrix singular')
end
Xn = X-m(ones(n,1),:);
pdf = zeros(n,1);

% new and fast call
pdf = exp(-0.5*sum((Xn(:,:)/S).*Xn(:,:) ,2))/den;
return

% old call slow
S1 = inv(S);
for ix=1:n
  pdf(ix) = exp(-0.5*Xn(ix,:)*S1*(Xn(ix,:).'))/den;
end
