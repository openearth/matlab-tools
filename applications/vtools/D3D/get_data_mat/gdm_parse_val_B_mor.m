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
%If a variable requests `val_B_mor`, add as requested variable `ba_mor`.

function flg_loc=gdm_parse_val_B_mor(flg_loc,simdef)

if any(flg_loc.do_val_B_mor)
    flg_loc.var=cat(2,reshape(flg_loc.var,1,numel(flg_loc.var)),'ba_mor');
    flg_loc=gdm_add_flags_plot(flg_loc);
end

end %function 