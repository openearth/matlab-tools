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

function branch_length=branch_length_sobek3(offset,branch)

branch_2p_idx=unique(branch);
nb=numel(branch_2p_idx);

branch_length=NaN(nb,1);

for kb=1:nb
    idx_br=branch==branch_2p_idx(kb); %logical indexes of intraloop branch
    off_br=offset(idx_br);
    branch_length(kb,1)=off_br(end);
end

end %function
