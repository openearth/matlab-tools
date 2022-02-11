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

function angle_track=angle_polyline(cords_x,cords_y,ds,varargin)

%% PARSE

switch numel(varargin)
    case 0
        do_break=false;
    case 1
        do_break=varargin{1,1};
end

%% CALC

np=numel(cords_x);
if np<2
    angle_track=NaN;
    if do_break
        error('Cannot compute angle based on 1 point.')
    end 
    return
elseif np==2
    ds=1;
else
    rem2=rem(ds,2);
    if rem2~=0
        ds=round(ds/2)*2;
        warning('The number of points to average should be multiple of 2. Converted to %d',ds)
    end
end

dcords_xy=[cords_x(1+ds:end)-cords_x(1:end-ds),cords_y(1+ds:end)-cords_y(1:end-ds)];
angle_track=atan2(dcords_xy(:,2),dcords_xy(:,1));
if np==2
    angle_track=ones(np,1).*angle_track';
else
    angle_track=[angle_track(1)*ones(ds/2,1);angle_track;angle_track(end)*ones(ds/2,1)];
end