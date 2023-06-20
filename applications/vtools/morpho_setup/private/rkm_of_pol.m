%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18966 $
%$Date: 2023-05-26 09:39:44 +0200 (Fri, 26 May 2023) $
%$Author: chavarri $
%$Id: interpolate_bed_level_from_xlsx.m 18966 2023-05-26 07:39:44Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/morpho_setup/interpolate_bed_level_from_xlsx.m $
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
