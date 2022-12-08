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