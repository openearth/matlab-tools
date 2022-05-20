%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18016 $
%$Date: 2022-05-03 16:22:21 +0200 (Tue, 03 May 2022) $
%$Author: chavarri $
%$Id: NC_read_map.m 18016 2022-05-03 14:22:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_map.m $
%
%

function var_str=D3D_var_num2str_structure(varname,simdef)

var_str=D3D_var_num2str(varname);
if simdef.D3D.structure==1
    switch var_str
        case 'bl'
            var_str='DPS';
    end
end

end
