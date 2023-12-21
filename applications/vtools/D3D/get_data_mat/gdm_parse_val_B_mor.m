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
%If a variable requests `val_B_mor`, add as requested variable `ba_mor`.

function flg_loc=gdm_parse_val_B_mor(flg_loc,simdef)

if any(flg_loc.do_val_B_mor)
    flg_loc.var=cat(2,reshape(flg_loc.var,1,numel(flg_loc.var)),'ba_mor');
    flg_loc=gdm_add_flags_plot(flg_loc);
end

end %function 