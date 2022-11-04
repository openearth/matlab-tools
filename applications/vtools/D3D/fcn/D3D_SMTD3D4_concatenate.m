%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18390 $
%$Date: 2022-09-27 12:07:53 +0200 (Tue, 27 Sep 2022) $
%$Author: chavarri $
%$Id: gdm_load_grid.m 18390 2022-09-27 10:07:53Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_grid.m $
%
%

function val=D3D_SMTD3D4_concatenate(val,val_aux,addnan)

s=size(val);
s_aux=size(val_aux);
if s_aux(2)>s(2) 
    NaN_add=NaN(s(1),s_aux(2)-s(2));
    val=cat(2,val,NaN_add); 
else
    NaN_add=NaN(s_aux(1),s(2)-s_aux(2));
    val_aux=cat(2,val_aux,NaN_add);
end

if addnan
    scf=size(val_aux,2);
    NaN_add=NaN(1,scf);
else
    NaN_add=[];
end
val=cat(1,val,NaN_add,val_aux);

end %function