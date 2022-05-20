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
%transforms structure data given as the x and y coordinates of the corners
%of quadrilateral cells and the value at the cell center into the faces,
%vertices and color matrix to be able to use patch to plot results. 

function [faces,vertices,col]=patchFormat(xcords,ycords,center_data)

nr=size(xcords,1);
nc=size(xcords,2);
np=numel(center_data);

faces=NaN(np,4); 
vertices=NaN(4*np,2); 
col=NaN(np,1);

idx_v=[1,2,3,4];
kp=1;
for kr=1:nr-1
    for kc=1:nc-1

        vertices(idx_v,:)=[xcords(kr  ,kc  ),ycords(kr  ,kc  );...
                           xcords(kr  ,kc+1),ycords(kr  ,kc+1);...
                           xcords(kr+1,kc+1),ycords(kr+1,kc+1);...
                           xcords(kr+1,kc  ),ycords(kr+1,kc  )];...
        faces(kp,:)=idx_v;
        col(kp,1)=center_data(kr,kc);

        idx_v=idx_v+4;
        kp=kp+1;
    end
end