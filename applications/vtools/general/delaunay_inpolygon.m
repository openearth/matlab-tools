%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17305 $
%$Date: 2021-05-20 22:33:45 +0200 (Thu, 20 May 2021) $
%$Author: chavarri $
%$Id: figure_layout.m 17305 2021-05-20 20:33:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
%

function tri_f=delaunay_inpolygon(xp,yp,xy_pol)

tri=delaunayTriangulation(xp,yp);
circ=circumcenter(tri);
inp=inpolygon(circ(:,1),circ(:,2),xy_pol(:,1),xy_pol(:,2));
tri_o=tri.ConnectivityList;
tri_f=tri_o;
tri_f(~inp,:)=[];

end %function
