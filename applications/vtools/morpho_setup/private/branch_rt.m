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

function br_s=branch_rt(br,rkm_s)

switch br
    case {'WL','BO','NI'}
        if rkm_s>960.15
            br_s='NI';
        elseif rkm_s>952.85
            br_s='BO';
        else
            br_s='WL';
        end
    otherwise
        error('do')
end

end %function
