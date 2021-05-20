%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 14:39:17 +0200 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: compute_distance_along_line.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/compute_distance_along_line.m $
%

function dist=compute_distance_along_line(coordinates)

np=size(coordinates,1);
dist=zeros(np,1);
for kp=2:np
    dist(kp)=dist(kp-1)+sqrt((coordinates(kp,1)-coordinates(kp-1,1)).^2+(coordinates(kp,2)-coordinates(kp-1,2))^2);
end

end