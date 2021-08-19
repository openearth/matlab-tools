%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17444 $
%$Date: 2021-08-02 21:26:54 +0200 (Mon, 02 Aug 2021) $
%$Author: chavarri $
%$Id: z_interpolated_from_polyline.m 17444 2021-08-02 19:26:54Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/z_interpolated_from_polyline.m $
%
%Given a polyline <[x_s,y_s]> with values <[z_s]>, it finds
%the value <z> associated to the point <[x,p]>.
%
function z=z_interpolated_from_polyline(x,y,x_s,y_s,z_s)

[min_dist,x_d_min,y_d_min,~,xc,~,~,~,~]=p_poly_dist(x,y,x_s,y_s);
xc=max([ones(size(xc)),xc],[],2);
dist_p2o=sqrt((x_d_min  -x_s(xc)).^2+(y_d_min  -y_s(xc)).^2);
dist_p2p=sqrt((x_s(xc+1)-x_s(xc)).^2+(y_s(xc+1)-y_s(xc)).^2);
frac=dist_p2o./dist_p2p;
z=z_s(xc,:)+frac.*(z_s(xc+1,:)-z_s(xc,:));

