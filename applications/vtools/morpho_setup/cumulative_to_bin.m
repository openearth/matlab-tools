%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Convert (sediment) fractions from cumulative to bins.
%
%NOTATION:
%   -nx = number of points (x, rkm)
%   -ns = number of sieves 
%
%INPUT:
%   -cum = cumulative fractions [nx,ns]
%   -dsieve = sieve sizes [1,ns];
%
%OUTPUT:
%   -bin = fraction in bin [nx,ns-1]
%   -dk  = bin characteristic sizes [1,ns-1]

function [bin,dk]=cumulative_to_bin(cum,dsieve)

[nx,ns]=size(cum);

%make sure measured data is in incresing size
if ~mono_increase(dsieve)
    dsieve=fliplr(dsieve);
    cum=fliplr(cum);
end

if any(cum(:,1)~=0)
    %deal with this case adding a grain size and a one
    error('All fractions must be 0 for the smallest grain size.')
end
if any(cum(:,end)~=1)
    %deal with this case adding a grain size and a one
    error('All fractions must be 1 for the smallest grain size.')
end

% cum=[zeros(nx,1),cum];
bin=abs(diff(cum,1,2));
% bin=[bin,1-sum(bin,2)];

dk=sqrt(dsieve(1:end-1).*dsieve(2:end));

end %function
