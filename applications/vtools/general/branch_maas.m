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