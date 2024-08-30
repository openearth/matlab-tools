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

function F=fcn_enloss_equilibrium(X,d1,crest_height,wsben,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,q,flg_obj,flagp,dllname,VillemonteCD3)

wsbov=X;

[E_us,u_us,h_us]=fcn_energy(wsbov,q,crest_height);
[E_ds,u_ds,h_ds]=fcn_energy(wsben,q,crest_height);

dte=calllib(dllname,'fcn_enloss',d1,crest_height,u_us,h_us,wsben,wsbov,iflagweir,crestl,rmpben,rmpbov,veg,VillemonteCD1,VillemonteCD2,iflagcriteriumvol,iflaglossvol,flagp,VillemonteCD3);

E_us_c=E_ds+dte;
h_us_c=h_ds+dte;

switch flg_obj
    case 1        
        f_us_c=E_us_c;
        f_us=E_us;
    case 2
        f_us_c=h_us_c;
        f_us=h_us;
end

% F=(E_us-E_us_c)^2;
% F=E_us-E_us_c;
F=-f_us+f_us_c;

if F==0
    F=1*f_us;
end
end

