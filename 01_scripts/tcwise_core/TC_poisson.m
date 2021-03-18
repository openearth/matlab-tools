function [r] = TC_poisson(lambda_in,nyears)
% Random arrays from the Poisson distribution.
lambda      = ones(nyears,1)*lambda_in;
r           = zeros([nyears,1],'single');
j           = find(lambda < 999);
p           = zeros(numel(j),1);

if isempty(j)
   disp('Warning: Nr of cyclones per year in basin is to large (999), check input (TC_poisson.m)') 
end 

if lambda(1) > 25
   disp('Warning: Nr of cyclones per year in basin is larger than 25, check whether this is realistic (TC_poisson.m)') 
end

while ~isempty(j)
    p = p - log(rand(numel(j),1));
    t = (p < lambda(j));
    j = j(t);
    p = p(t);
    r(j) = r(j) + 1;
end
end

