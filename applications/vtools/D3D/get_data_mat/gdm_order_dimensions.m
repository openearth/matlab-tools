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