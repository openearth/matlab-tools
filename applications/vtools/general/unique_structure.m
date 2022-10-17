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