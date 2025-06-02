%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17760 $
%$Date: 2022-02-14 10:51:28 +0100 (Mon, 14 Feb 2022) $
%$Author: chavarri $
%$Id: polcell2nan.m 17760 2022-02-14 09:51:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/polcell2nan.m $
%

function mat=polcell2matrix(pol_cell)

np=numel(pol_cell);
npoints_cell=cellfun(@(X)size(X,1),pol_cell);
max_points=max(npoints_cell);
mat=NaN(max_points,np,2);
for kp=1:np
    xy_loc=pol_cell{kp};
    np_loc=size(xy_loc,1);
    mat(1:np_loc,kp,1)=xy_loc(:,1);
    mat(1:np_loc,kp,2)=xy_loc(:,2);
end

end %function