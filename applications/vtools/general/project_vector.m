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

function [vpara,vperp]=project_vector(veast,vnorth,angle_track)

veast=reshape(veast,1,[]);
vnorth=reshape(vnorth,1,[]);
angle_track=reshape(angle_track,1,[]);

vpara=veast.*cos(angle_track)+vnorth.*sin(angle_track);
vperp=veast.*sin(angle_track)-vnorth.*cos(angle_track);
