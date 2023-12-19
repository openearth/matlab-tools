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
%Parse all flags. Called in create mat and plot. 

function flg_loc=gdm_parse_summerbed(flg_loc,simdef)

flg_loc=gdm_default_flags(flg_loc);

flg_loc=gdm_parse_sediment_transport(flg_loc,simdef);

flg_loc=gdm_parse_stot(flg_loc,simdef);

flg_loc=gdm_parse_val_B_mor(flg_loc,simdef);

flg_loc=gdm_parse_val_B(flg_loc,simdef);

end