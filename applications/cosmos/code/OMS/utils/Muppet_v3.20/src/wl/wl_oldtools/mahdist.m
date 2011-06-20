function result=Mahdist(x),
% compute Mahalanobis distance

[r,c] = size(x);                % size of input
m = sum(x,1)/r;                 % mean of rows
z = x - m(ones(1,r),:);         % centered values
covx = (z'*z)/(r-1);            % variance matrix
result = sqrt( real( sum( z/covx.*conj(z), 2 ) ) );
