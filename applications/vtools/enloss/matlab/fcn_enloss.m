%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18945 $
%$Date: 2023-05-15 14:17:04 +0200 (Mon, 15 May 2023) $
%$Author: chavarri $
%$Id: D3D_gdm.m 18945 2023-05-15 12:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/D3D_gdm.m $
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