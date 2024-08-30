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
%Interpolate cumulative grain size distribution at different sieve sizes. 
%
%np  = number of data points (e.g., river kilometers); 
%nf  = number of original (measured) size fractions;
%nfm = number of interpolated (modelled) characteristic size fractions;
%
%INPUT:
%   cum_mea    = original (measured) cumulative fraction [-] [double(np,nf)]
%   dsieve_mea = original (meaured) sieve sizes [m] [double(1,nf)]
%   dk_mod     = interpolated (modelled) characteristic size fractions [m] [double(1,nfm)]

function [cum_mod,frac_mod,dsieve_mod]=interpolate_grain_size_distribution(cum_mea,dsieve_mea,dk_mod)

%% PARSE

np=numel(dsieve_mea);
if np~=size(cum_mea,2)
    error('Number of sieve sizes is does not match with cumulative fractions.')
end

%% CALC

%compute sieve sizes of model
%make sure it is in increasing size
if ~mono_increase(dk_mod)
    dk_mod=fliplr(dk_mod);
end
dsieve_mod=sqrt(dk_mod(1:end-1).*dk_mod(2:end));

%make sure measured data is in incresing size
if ~mono_increase(dsieve_mea)
    dsieve_mea=fliplr(dsieve_mea);
    cum_mea=fliplr(cum_mea);
end

%interpolate fractions at dsieve model
np=size(cum_mea,1); %number of points (rkm) where data is given
nfs=numel(dsieve_mod);
cum_mod=NaN(np,nfs);
for kp=1:np
    cum_mod(kp,:)=interp_line_vector(dsieve_mea,cum_mea(kp,:),dsieve_mod,NaN);
end %kp
cum_mod=[zeros(np,1),cum_mod];
frac_aux=abs(diff(cum_mod,1,2));
frac_mod=[frac_aux,1-sum(frac_aux,2)];

end %function