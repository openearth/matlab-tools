function [az,el,dist,roll]=getview(ax,eldir);
% GETVIEW returns azimuth angle, elevation angle and distance
%   Allows rotation at different distances than the default
%   [Azimuth,Elevation,Distance]=GETVIEW(AxesHandle)
%   [Angles,Distance]=GETVIEW(AxesHandle) returns Angles=[Azimuth Elevation]
%   View=GETVIEW(AxesHandle) returns View=[Azimuth Elevation Distance]

% (c) copyright 1998, H.R.A. Jagers, University of Twente / Delft Hydraulics

switch nargin,
case 0,
  ax=gca;
case 1,
  eldir=3;
end;
dar=get(ax,'dataaspectratio');
cp=get(ax,'cameraposition');
ct=get(ax,'cameratarget');
viewVec=(ct-cp)./dar;
dist=norm(viewVec);
viewVec=viewVec/dist;
cuv=get(ax,'cameraupvector')./dar;

axDir=[2 3 1;3 1 2;1 2 3];
axDir=axDir(eldir,:);

el=-180*atan2(viewVec(axDir(3)),sqrt(sum(viewVec(axDir([1 2])).^2)))/pi;
if (el==90) | (el==-90),
  cuv=get(ax,'cameraupvector')./dar;
  cuv=cuv/norm(cuv);
  az=-180*atan2(sign(el)*cuv(axDir(1)),sign(el)*cuv(axDir(2)))/pi;
  roll=0;
else,
  zDir=[0 0 0];
  zDir(axDir(3))=1;
  zRollUp=zDir-sum(zDir.*viewVec)*viewVec;
  zRollUp=zRollUp/norm(zRollUp);
  zRollHor=cross(zRollUp,viewVec);
  zRollHor=zRollHor/norm(zRollHor);
  roll=180*atan2(sum(cuv.*zRollHor),sum(cuv.*zRollUp))/pi;
  az=-180*atan2(viewVec(axDir(1)),viewVec(axDir(2)))/pi;
end;

if nargout<2,
  az=[az el dist roll];
elseif nargout==2,
  az=[az el];
  el=dist;
elseif nargout==3,
  % az, el and dist as computed
else,
  % az, el, dist and roll as computed
end;