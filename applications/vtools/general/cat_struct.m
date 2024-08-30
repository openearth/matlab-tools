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
%Concatenate data in structure. 

function struct1=cat_struct(struct1,struct2)

dim=1;

fn=fieldnames(struct1);
for kf=1:numel(fn)
    struct1.(fn{kf})=cat(dim,struct1.(fn{kf}),struct2.(fn{kf}));
end %kf

end %function