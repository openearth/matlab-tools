%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18391 $
%$Date: 2022-09-27 13:13:00 +0200 (Tue, 27 Sep 2022) $
%$Author: chavarri $
%$Id: D3D_simpath.m 18391 2022-09-27 11:13:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath.m $
%

function stru=struct_assign_val(stru,str,val)

ns=numel(stru);
ni=numel(val);
if ni==1 %same value to all structure fields        
    vec=val.*ones(ns,1);
elseif ns==ni
    vec=val;
else
    error('The size of the vector is different than the size of the structure and it is not 1')
end

aux=num2cell(vec);
[stru.(str)]=aux{:};

end %function