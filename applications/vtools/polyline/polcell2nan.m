%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17478 $
%$Date: 2021-09-09 17:44:11 +0200 (Thu, 09 Sep 2021) $
%$Author: chavarri $
%$Id: polnan2cell.m 17478 2021-09-09 15:44:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/polnan2cell.m $
%

function pol_nan=polcell2nan(pol_cell)

np=numel(pol_cell);
pol_nan=[];
ndim=size(pol_cell{1,1},2);
nanm=NaN(1,ndim);
for kp=1:np
    pol_nan=cat(1,pol_nan,pol_cell{kp,1},nanm);
end
