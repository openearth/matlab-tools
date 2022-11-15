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

%search for first coordinate which is not nan
idx_nn=1;
while any(isnan(coordinates(idx_nn,:)))
    idx_nn=idx_nn+1;
end

idx_prev=idx_nn;
for kp=idx_nn+1:np
    if any(isnan(coordinates(kp,:)))
        dist(kp)=dist(idx_prev);
    else
        dist(kp)=dist(idx_prev)+sqrt((coordinates(kp,1)-coordinates(idx_prev,1)).^2+(coordinates(kp,2)-coordinates(idx_prev,2))^2);
        idx_prev=kp;
    end
end

end