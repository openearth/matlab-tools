%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (di, 08 sep 2020) $
%$Author: chavarri $
%$Id: rework4patch.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/rework4patch.m $
%
%Rework input from scatter to patch

function [x,y,c]=rework4pacth_struct(data)

%% PARSE

%To do:
%create a general `rework4patch` that depending on the type of input calls
%`rework4path` or `rewrok4patch_struct` and the output is always of the 
%same type

%% CALC
[~,ns,nl]=size(data.val);

npol=ns*nl;
x=NaN(4,npol);
y=x;
c=NaN(1,npol);

kpol=0;
for ks=1:ns
    for kl=1:nl
        kpol=kpol+1;

        x(1,kpol)=data.Scor(ks);
        x(2,kpol)=data.Scor(ks+1);
        x(3,kpol)=data.Scor(ks+1);
        x(4,kpol)=data.Scor(ks);

        y(1,kpol)=data.Zint(1,ks,kl+1);
        y(2,kpol)=data.Zint(1,ks,kl+1);
        y(3,kpol)=data.Zint(1,ks,kl);
        y(4,kpol)=data.Zint(1,ks,kl);

        c(1,kpol)=data.vel_mag(1,ks,kl);
    end
end

end %function