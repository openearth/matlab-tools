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
%If a variable requests `val_B`, add as requested variable `ba`.

function flg_loc=gdm_parse_val_B(flg_loc,simdef)

if any(flg_loc.do_val_B)
    flg_loc.var=cat(2,reshape(flg_loc.var,1,numel(flg_loc.var)),'ba');
    flg_loc=gdm_add_flags_plot(flg_loc);
end

end %function 