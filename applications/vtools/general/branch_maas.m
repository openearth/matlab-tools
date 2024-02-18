%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19243 $
%$Date: 2023-11-20 11:49:45 +0100 (Mon, 20 Nov 2023) $
%$Author: chavarri $
%$Id: branch_rijntakken.m 19243 2023-11-20 10:49:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/branch_rijntakken.m $
%
%Branch name of the Maas.

function br=branch_maas(rkm)
np=numel(rkm);
br=cell(np,1);
for kp=1:np
    if rkm(kp)<230.5
        br{kp,1}='MA';
    else
        br{kp,1}='BM';
    end
end

end %function