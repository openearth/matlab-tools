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
%This awesome recurrent functions finds the index of
%a cell array containin a certain string

function idx_cell=find_str_in_cell_deep(fname_or,fname_loc)


ne=numel(fname_or);
idx_cell=NaN;
for ke=1:ne
    if iscell(fname_or{ke,1})
        idx_cell=find_str_in_cell_deep(fname_or{ke,1},fname_loc);
        if ~isnan(idx_cell)
            idx_cell=cat(1,ke,idx_cell);
            return
        end
    else
        bol_empty=cellfun(@(x)isempty(x),fname_or);
        nv=numel(bol_empty);
        for kv=1:nv
            if bol_empty(kv)
                fname_or{kv,1}='';
            end
        end
        if ~isempty(fname_or{ke,1})
            idx_cell=find_str_in_cell(fname_or,fname_loc);
            if ~isnan(idx_cell)
                return
            end
        end
    end
end

end