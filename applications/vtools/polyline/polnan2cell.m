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

function piles=polnan2cell(piles_nan)

nan_p=isnan(piles_nan(:,1));
nx=size(piles_nan,1);
idx_n=[0;find(nan_p);nx+1];
np=sum(nan_p)+1;
piles=cell(np,1);
for kp=1:np
    piles{kp,1}=piles_nan(idx_n(kp)+1:idx_n(kp+1)-1,:);
end
