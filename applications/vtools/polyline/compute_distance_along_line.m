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

function dist=compute_distance_along_line(coordinates)

np=size(coordinates,1);
dist=zeros(np,1);
for kp=2:np
    dist(kp)=dist(kp-1)+sqrt((coordinates(kp,1)-coordinates(kp-1,1)).^2+(coordinates(kp,2)-coordinates(kp-1,2))^2);
end

end