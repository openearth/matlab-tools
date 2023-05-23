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

function idx_f=D3D_search_index_in_dimension(data,varname)

if ~isfield(data,'dimensions')
    idx_f=NaN;
    return
end
str_sim_c=strrep(data.dimensions,'[','');
str_sim_c=strrep(str_sim_c,']','');
tok=regexp(str_sim_c,',','split');
idx_f=find_str_in_cell(tok,{varname});

end %function