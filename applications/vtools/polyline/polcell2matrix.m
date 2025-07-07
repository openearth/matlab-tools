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