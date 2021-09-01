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

function tri_f=delaunay_inpolygon(xp,yp,xy_pol)

tri=delaunayTriangulation(xp,yp);
circ=circumcenter(tri);
inp=inpolygon(circ(:,1),circ(:,2),xy_pol(:,1),xy_pol(:,2));
tri_o=tri.ConnectivityList;
tri_f=tri_o;
tri_f(~inp,:)=[];

end %function
