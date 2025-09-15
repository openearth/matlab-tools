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

function gridInfo=gdm_grd_branch(gridInfo_all,branch_cell)

v2struct(gridInfo_all);

branch_2p_idx=get_branch_idx(branch_cell,branch_id);

tag={'','_edge'}; %node,edge

nne=numel(tag);
for knodeedge=1:nne %we apply to edges and nodes
    switch tag{knodeedge}
        case ''
            branch_loc=branch;
            offset_loc=offset;
            x_loc=x_node;
            y_loc=y_node;
        case '_edge'
            branch_loc=branch_edge;
            offset_loc=offset_edge;
            x_loc=x_edge;
            y_loc=y_edge;
        otherwise
            error('?')
    end

    offset_name=sprintf('offset%s',tag{knodeedge});
    idx_name=sprintf('idx%s',tag{knodeedge});
    xy_name=sprintf('xy%s',tag{knodeedge});

    [cord_br,o_br,idx_br_clean]=get_data_branch(branch_2p_idx,branch_loc,branch_length,offset_loc,x_loc,y_loc);

    gridInfo.(xy_name)=cord_br;
    gridInfo.(offset_name)=o_br;
    gridInfo.(idx_name)=idx_br_clean;

end %kedgendode

end %function

%%
%% FUNCTION
%%

function [cord_br,o_br,idx_br_clean]=get_data_branch(branch_2p_idx,branch_loc,branch_length,offset_loc,x_loc,y_loc)


%in FM1D, the branch id start at 0, while is starts at 1 in SOBEK3
% cte_br=1;
% if isempty(find(branch==0,1)) %sobek3;
%     cte_br=0;
% end

%in FM1D, the branch id start at 0, while is starts at 1 in SOBEK3
cte_br=0;
if ~isempty(find(branch_loc==0,1)) %fm;
    branch_2p_idx=branch_2p_idx-1;
    cte_br=1;
end

nb=numel(branch_2p_idx);

cord_br=[];
o_br=[];
last_dx_bm1=0;
o_br_end_bm1=0;
idx_br_clean=NaN(size(offset_loc));

for kb=1:nb
    idx_br=branch_loc==branch_2p_idx(kb); %logical indexes of intraloop branch
    br_length=branch_length(branch_2p_idx(kb)+cte_br); %total branch length. As the branches start counting on 0, in position n+1 we find the length of branch n.
        
    o_a1=offset_loc(idx_br);
    last_dx=br_length-o_a1(end);
    
    o_br=cat(1,o_br,o_a1+o_br_end_bm1+last_dx_bm1);
    
    last_dx_bm1=last_dx;
    o_br_end_bm1=o_br(end);
    
    x_node_a1=x_loc(idx_br);
    y_node_a1=y_loc(idx_br);
    
    cord_br=cat(1,cord_br,[x_node_a1,y_node_a1]);

    idx_br_clean(idx_br)=kb;
end

end %function