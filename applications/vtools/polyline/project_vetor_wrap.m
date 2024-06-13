%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17754 $
%$Date: 2022-02-11 06:38:51 +0100 (vr, 11 feb 2022) $
%$Author: chavarri $
%$Id: angle_polyline.m 17754 2022-02-11 05:38:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/angle_polyline.m $
%
%Wrap around `project_vector` including computation of angle

function [val_para,val_perp]=project_vetor_wrap(x,y,val_x,val_y,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'npoints_angle',2)

parse(parin,varargin{:})

npoints_angle=parin.Results.npoints_angle;

%% CALC

angle_track=angle_polyline(x,y,npoints_angle,0);
val_para=NaN(size(val_x));
val_perp=val_para;
bol_nn=~isnan(angle_track);
[val_para(bol_nn),val_perp(bol_nn)]=project_vector(val_x(bol_nn),val_y(bol_nn),angle_track(bol_nn));

end %function