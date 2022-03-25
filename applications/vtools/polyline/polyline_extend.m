%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17804 $
%$Date: 2022-03-02 09:37:25 +0100 (Wed, 02 Mar 2022) $
%$Author: chavarri $
%$Id: angle_difference.m 17804 2022-03-02 08:37:25Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/angle_difference.m $
%

function pli_ext=polyline_extend(pli_loc,ds)

ang_pli=angle_polyline(pli_loc(:,1),pli_loc(:,2));
pol_ext_x0=pli_loc(1,1)+cos(ang_pli(1)+pi)*ds;
pol_ext_xf=pli_loc(2,1)+cos(ang_pli(1)   )*ds;
pol_ext_y0=pli_loc(1,2)+sin(ang_pli(2)+pi)*ds;
pol_ext_yf=pli_loc(2,2)+sin(ang_pli(2)   )*ds;
pli_ext=[pol_ext_x0,pol_ext_y0;pol_ext_xf,pol_ext_yf];