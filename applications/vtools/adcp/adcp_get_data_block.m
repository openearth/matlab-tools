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

function out_s=adcp_get_data_block(data_block,varargin)

%% PARSE

flg.use_cords=0;
flg.correct_angle_track=0;
flg.limit_cs=Inf;

flg=setproperty(flg,varargin);

%% CALC

flg_loc=struct();
flg_loc.use_cords=flg.use_cords;
[s,idx_out2,cords_xy_4326,cords_xy_28992]=adcp_get_crosssection_distance(data_block,flg_loc);

%is cross section or longitudinal section
flg_loc=struct();
flg_loc.limit_cs=flg.limit_cs;
isCross=adcp_isCrossSection(s,flg_loc);

%angle of the track
angle_track=adcp_angleTrack(cords_xy_28992(:,1),cords_xy_28992(:,2),isCross);
if flg.correct_angle_track==1
    error('repare')
    %input for figure printing
    [ffolder,fname,~]=fileparts(in_p.fnameprint);

    in_p_angleTrackCross.fig_correction=0; %print figure with output of cross discharge
    in_p_angleTrackCross.fnameprint=fullfile(ffolder,sprintf('%s_correction.png',fname));
    in_p_angleTrackCross.title_str=in_p.title_str;

    angle_track=angleTrackCross(data_block,idx_out2,s,depth,angle_track,in_p_angleTrackCross);
end

depth_track=[data_block(~idx_out2).h1];
depth=data_block(1).depth;
vmag=[data_block(~idx_out2).vmag];
vvert=[data_block(~idx_out2).vvert];

%project velocity
[vpara,vperp]=adcp_projectVelocity(data_block,idx_out2,angle_track,1);

%turn profiles to downstream
if isCross && angle_track>0 && angle_track<pi
    [s,vmag,vvert,vpara,vperp,angle_track,cords_xy_4326,~,~]=adcp_flip_section(s,vmag,vvert,vpara,vperp,angle_track,cords_xy_4326,cords_x_28992,cords_y_28992,angle_track);
end

%compute streamwise and crosswise
if isCross
    vstream=vperp;
    vcross=vpara;
else
    vstream=vpara;
    vcross=vperp;
end

%matrix for plot
[s_m,d_m]=meshgrid(s,depth);

%compute discharge
ds=diff(cen2cor(s));
dh=diff(cen2cor(depth));
qloc_mag=vmag.*dh';
qmag=sum(qloc_mag,1,'omitnan');
Qmag=cumsum(qmag.*ds);

%% OUT

out_s=v2struct(s_m,d_m,s,vmag,vvert,vpara,vperp,vstream,vcross,angle_track,cords_xy_4326,cords_xy_28992,depth_track,qmag,Qmag);

end