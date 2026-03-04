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

function var_2_v=gdm_STO_variables_label(fid_log,flg_loc)

nst=numel(flg_loc.sedtrans); 
var_2_v=cell(1,nst);

for kst=1:nst
    var_2_v{kst}='stot'; %the variable name under `var` has the name as input for the sediment transport relation. `var_2` contains the name understood for writing the labels. 
end

end %function