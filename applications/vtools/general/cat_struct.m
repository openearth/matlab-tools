%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19059 $
%$Date: 2023-07-17 18:44:36 +0200 (Mon, 17 Jul 2023) $
%$Author: chavarri $
%$Id: input_D3D_layout.m 19059 2023-07-17 16:44:36Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/input_D3D_layout.m $
%
%Concatenate data in structure. 

function struct1=cat_struct(struct1,struct2)

dim=1;

fn=fieldnames(struct1);
for kf=1:numel(fn)
    struct1.(fn{kf})=cat(dim,struct1.(fn{kf}),struct2.(fn{kf}));
end %kf

end %function