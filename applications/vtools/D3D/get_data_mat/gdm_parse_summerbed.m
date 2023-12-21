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
%Parse all flags. Called in create mat and plot. 

function flg_loc=gdm_parse_summerbed(flg_loc,simdef)

flg_loc=gdm_default_flags(flg_loc);

flg_loc=gdm_parse_sediment_transport(flg_loc,simdef);

flg_loc=gdm_parse_stot(flg_loc,simdef);

flg_loc=gdm_parse_val_B_mor(flg_loc,simdef);

flg_loc=gdm_parse_val_B(flg_loc,simdef);

end