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

function [vpara,vperp]=project_vector(veast,vnorth,angle_track)

veast=reshape(veast,1,[]);
vnorth=reshape(vnorth,1,[]);
angle_track=reshape(angle_track,1,[]);

vpara=veast.*cos(angle_track)+vnorth.*sin(angle_track);
vperp=veast.*sin(angle_track)-vnorth.*cos(angle_track);
