%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 1780 $
%$Date: 2022-03-25 13:26:03 +0100 (Fri, 25 Mar 2022) $
%$Author: chavarri $
%$Id: maas_branches.m 1780 2022-03-25 12:26:03Z chavarri $
%$HeadURL: https://repos.deltares.nl/repos/RIVmodels/models/dflowfm/maas/01_scripts/maas_branches.m $
%

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