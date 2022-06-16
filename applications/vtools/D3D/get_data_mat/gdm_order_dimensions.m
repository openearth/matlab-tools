%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18154 $
%$Date: 2022-06-14 05:40:14 +0200 (Tue, 14 Jun 2022) $
%$Author: chavarri $
%$Id: labels4all.m 18154 2022-06-14 03:40:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/labels4all.m $
%
%dimension 1 of <data.val> must be faces.

function data=gdm_order_dimensions(fid_log,data)

if isfield(data,'dimensions') %read from EHY
    str_sim_c=strrep(data.dimensions,'[','');
    str_sim_c=strrep(str_sim_c,']','');
    tok=regexp(str_sim_c,',','split');
    idx_f=find_str_in_cell(tok,{'mesh2d_nFaces'});
    dim=1:1:numel(tok);
    dimnF=dim;
    dimnF(dimnF==idx_f)=[];
    data.val=permute(data.val,[idx_f,dimnF]);
else
    size_val=size(data.val);
    if size_val(1)==1 && size_val(2)>1
        data.val=data.val';
        messageOut(fid_log,'It seems faces are not in first dimension. I am permuting the vector.')
    end
end


end %function