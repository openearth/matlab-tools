function fly(ax,CamPosition,ViewAhead,ViewLevel,StepSize,ViewAngle,AVI),
% FLY moves the camera along a specifed path
%   Usage: FLY(AxesHandle,CameraPath,ViewAhead,ViewLevel, ...
%              StepSize,ViewAngle,AVI);
%   Default: FLY(AxesHandle,CameraPath,5,0,1,60,0);
%   moves the camera of the specified axes object
%   along the specified path. CameraPath is a
%   N x 3 matrix containing X,Y, and Z locations
%   of the camera as columns. The ViewAhead
%   argument determines the view direction of the
%   camera. It is directed at the point on the
%   camera path that is reached in ViewAhead steps.
%   ViewLevel to look slightly up or down.

if nargin<2,
  error('Not enough input arguments.');
end;
if nargin<7,
  AVI=0;
end;
if nargin<6,
  ViewAngle=60;
end;
if nargin<5,
  StepSize=1;
end;
if nargin<4,
  ViewLevel=0;
end;
if nargin<3,
  ViewAhead=5;
end;

set(ax,'cameraviewangle',ViewAngle, ...
        'projection','perspective');
set(allchild(ax),'clipping','off');

%L=line(CamPosition(:,1),CamPosition(:,2),CamPosition(:,3),'parent',ax);

for i=1:StepSize:(size(CamPosition,1)-ViewAhead),
  set(ax,'cameraposition',CamPosition(i,:), ...
          'cameratarget',CamPosition(i+ViewAhead,:)+[0 0 ViewLevel]);
  drawnow;
  if AVI,
    clipboard(get(ax,'parent'));
  end;
end;

%delete(L);