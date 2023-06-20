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
%

function rkm_pol=rkm_of_pol(rkm,br)

ds_pol=polygon_ds;
ds_m=ds_pol/1000;
rkm_pol=round(rkm/ds_m)*ds_m;

switch br
    case 'WL'
        rkm_pol=max(rkm,867.5);
end

end
