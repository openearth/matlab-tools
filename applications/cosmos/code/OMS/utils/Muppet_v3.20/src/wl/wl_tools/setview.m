function setview(varargin), % ax,az,el,dist,roll);
% SETVIEW sets azimuth angle, elevation angle and distance
%   Allows rotation at different distances than the default
%   You can specify either all:
%     SETVIEW (AxesHandle, Azimuth,                          Elevation, Distance, Roll)
%     SETVIEW (AxesHandle, [Azimuth,Elevation,Distance,Roll]                          )
%   Or only Azimuth, Elevation and Distance
%     SETVIEW (AxesHandle, Azimuth,                          Elevation, Distance      )
%     SETVIEW (AxesHandle, [Azimuth,Elevation],              Distance                 )
%     SETVIEW (AxesHandle, [Azimuth,Elevation,Distance]                               )
%   Or only Azimuth, Elevation angles
%     SETVIEW (AxesHandle, Azimuth,                          Elevation                )
%     SETVIEW (AxesHandle, [Azimuth,Elevation]                                        )
%   Or only the distance:
%     SETVIEW (AxesHandle, Distance                                                   )
%   SETVIEW(..., 'eldir',Dir)

% (c) copyright 1998, H.R.A. Jagers, University of Twente / Delft Hydraulics

Input=varargin;
if length(Input)>1,
  if strcmp(Input{end-1},'eldir'),
    eldir=Input{end};
    Input(end-1:end)=[];
  else,
    eldir=3;
  end;
end;
Nargin=length(Input);

if Nargin==5,
  % ax, az, el, dist and roll as entered
  [ax,az,el,dist,roll]=deal(Input{:});
elseif Nargin==4,
  % ax, az, el and dist as entered
  [ax,az,el,dist]=deal(Input{:});
  roll=0;
elseif Nargin==3,
  % {ax, az, el} or {ax, [az, el], dist}
  if isequal(size(Input{2}),[1 2]), % {ax, az, el}
    [ax,az,el]=deal(Input{:});
    [az2,el2,dist2,roll2]=getview(ax,eldir);
    dist=dist2;
    roll=roll2;
  else, % {ax, [az el], dist}
    ax=Input{1};
    dist=Input{3};
    el=Input{2}(2);
    az=Input{2}(1);
    [az2,el2,dist2,roll2]=getview(ax,eldir);
    roll=roll2;
  end;
elseif Nargin==2,
  % {ax, [az el dist]} or {ax, [az el]} or {ax, dist} or {ax,[aaz wl dist roll]}
  if isequal(size(Input{2}),[1 4]), % {ax, [az el dist roll]}
    ax=Input{1};
    roll=Input{2}(4);
    dist=Input{2}(3);
    el=Input{2}(2);
    az=Input{2}(1);
  elseif isequal(size(Input{2}),[1 3]), % {ax, [az el dist]}
    ax=Input{1};
    dist=Input{2}(3);
    el=Input{2}(2);
    az=Input{2}(1);
    [az2,el2,dist2,roll2]=getview(ax,eldir);
    roll=roll2;
  elseif isequal(size(Input{2}),[1 2]), % {ax, [az el]}
    ax=Input{1};
    [az2,el2,dist2,roll2]=getview(ax,eldir);
    dist=dist2;
    el=Input{2}(2);
    az=Input{2}(1);
    roll=roll2;
  else, % {ax, dist}
    ax=Input{1};
    [az2,el2,dist2,roll2]=getview(ax,eldir);
    dist=Input{2};
    az=az2;
    el=el2;
    roll=roll2;
  end;
% elseif nargin==1,
else,
  error('incorrect number of input arguments');
end;

axDir=[2 3 1;3 1 2;1 2 3];
axDir=axDir(eldir,:);

dar=get(ax,'dataaspectratio');
ct=get(ax,'cameratarget');

az=az*pi/180;
el=el*pi/180;
viewVec(axDir(1))=dist*cos(el)*sin(az);
viewVec(axDir(2))=-dist*cos(el)*cos(az);
viewVec(axDir(3))=dist*sin(el);
roll=roll*pi/180;
zDir=[0 0 0];
zDir(axDir(3))=1;

vDir=(viewVec)/norm(viewVec);
zRollUp=zDir-sum(zDir.*vDir)*vDir;
if norm(zRollUp)~=0,
  zRollUp=zRollUp/norm(zRollUp);
end;
zRollHor=-cross(zRollUp,vDir);
if norm(zRollHor)~=0,
  zRollHor=zRollHor/norm(zRollHor);
end;
cuv=cos(roll)*zRollUp+sin(roll)*zRollHor;

cp=ct+viewVec.*dar;
if norm(cuv)==0, % el==90 or el==-90
  cuv(axDir(1))=sin(az);
  cuv(axDir(2))=-cos(az);
  cuv(axDir(3))=0;
  cuv=cuv.*dar;
else,
  cuv=cuv/norm(cuv).*dar;
end;
set(ax,'cameraposition',cp,'cameraupvector',cuv);
