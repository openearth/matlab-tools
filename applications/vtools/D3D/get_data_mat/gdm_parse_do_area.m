%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19010 $
%$Date: 2023-06-20 17:14:57 +0200 (Tue, 20 Jun 2023) $
%$Author: kosters $
%$Id: gdm_parse_sediment_transport.m 19010 2023-06-20 15:14:57Z kosters $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_parse_sediment_transport.m $
%
%By default, do area plot to sediment transport per size fraction to
%have a stack. 

function flg_loc=gdm_parse_do_area(flg_loc,simdef)

if isfield(flg_loc,'do_area')==0
    flg_loc.do_area=zeros(size(flg_loc.var));
end
bol_stot=strcmp('stot',flg_loc.var);
flg_loc.do_area(bol_stot)=true;

end %function
