%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 38 $
%$Date: 2021-10-21 14:34:13 +0200 (Thu, 21 Oct 2021) $
%$Author: chavarri $
%$Id: main_bring_data_back.m 38 2021-10-21 12:34:13Z chavarri $
%$HeadURL: file:///P:/11206813-007-kpp2021_rmm-3d/E_Software_Scripts/00_svn/file_movement/main_bring_data_back.m $
%
%Get unique elements of structure

function stru_out=unique_structure(stru_in,fields)

fn=fieldnames(stru_in);
idx_fn=find_str_in_cell(fn,fields);
nel=numel(stru_in);
nfn=numel(idx_fn);
caux=cell(nel,nfn);
for kfn=1:nfn
    caux(:,kfn)={stru_in.(fn{idx_fn(kfn)})};
end
[u,idx_u]=unique(cell2table(caux));
stru_out=stru_in(idx_u);

end %function