%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16769 $
%$Date: 2020-11-05 11:40:08 +0100 (Thu, 05 Nov 2020) $
%$Author: chavarri $
%$Id: add_floodplane.m 16769 2020-11-05 10:40:08Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/bed_level_flume/add_floodplane.m $
%

function [vpara,vperp]=adcp_projectVelocity(data_block,idx_out2,angle_track,check_reverse)

% vmag=[data_block(~idx_out2).vmag];
veast=[data_block(~idx_out2).veast];
vnorth=[data_block(~idx_out2).vnorth];
% vvert=[data_block(~idx_out2).vvert];

vpara=veast.*cos(angle_track')+vnorth.*sin(angle_track');
vperp=veast.*sin(angle_track')-vnorth.*cos(angle_track');

%reverse direction
if check_reverse
    if nanmean(vperp(:))<0
       angle_track=angle_track+pi;
       vperp=-vperp;
       vpara=-vpara;
    end
end