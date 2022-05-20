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

function var_str=D3D_var_num2str_structure(varname,simdef)

var_str=D3D_var_num2str(varname);
if simdef.D3D.structure==1
    switch var_str
        case 'bl'
            var_str='DPS';
    end
end

end
