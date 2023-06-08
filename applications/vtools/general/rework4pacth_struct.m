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