%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19659 $
%$Date: 2024-06-03 08:02:18 +0200 (Mon, 03 Jun 2024) $
%$Author: chavarri $
%$Id: D3D_create_simulation.m 19659 2024-06-03 06:02:18Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_create_simulation.m $
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
