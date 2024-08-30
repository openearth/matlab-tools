%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%

function [dte,volk,E_us,E_ds,wsbov,u_us,qc_v]=fcn_enloss(dllname,d1,crest_height,wsben,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,q,flg_obj,flagp,VillemonteCD3)

opts = optimset('display', 'off');

F=@(X)fcn_enloss_equilibrium(X,d1,crest_height,wsben,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,q,flg_obj,flagp,dllname,VillemonteCD3);

x1=fminbnd(F,wsben-1e-4,wsben+0.5);
x0=wsben-1e-4;

if sign(F(x0))==sign(F(x1))
    wsbov=NaN;
else
    wsbov=fzero(F,[x0,x1],opts);
end

[E_us,u_us,h_us]=fcn_energy(wsbov,q,crest_height);
[E_ds,u_ds,h_ds]=fcn_energy(wsben,q,crest_height);

if h_us<h_ds || E_us<0 || E_ds<0 || isnan(wsbov)
%                 dte(ki,kfw)=NaN;
%                 volk(ki,kfw)=NaN;
    E_us=NaN;
    dte=NaN;
    volk=NaN;
else
    dte=calllib(dllname,'fcn_enloss',d1,crest_height,u_us,h_us,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,flagp,VillemonteCD3); 
    volk=calllib(dllname,'fcn_volkomen',d1,crest_height,u_us,h_us,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,flagp,VillemonteCD3); 
end

hc_loc=wsben-crest_height;
qc_v=sqrt(9.81)*hc_loc.^(3/2); %h_crest=2/3*E_crest

end %function