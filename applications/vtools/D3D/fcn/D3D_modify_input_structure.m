%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 15:24:14 +0200 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_simpath_mdf.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath_mdf.m $
%
%Gets as output the path to each file type
%
%INPUT
%   -
%

function loc=D3D_modify_input_structure(loc,var)

var_fn=fieldnames(var);
loc_fn=fieldnames(loc);

nb=numel(loc_fn);
for kb=1:nb
    loc_block=loc.(loc_fn{kb});
    if isstruct(loc_block)
        block_fn=fieldnames(loc_block);
        nkk=numel(block_fn);
        for kk=1:nkk
           idx=find_str_in_cell(var_fn,block_fn(kk));
           if ~isnan(idx)
               loc.(loc_fn{kb}).(block_fn{kk})=var.(var_fn{idx});
           end
        end
    end
end

end %function