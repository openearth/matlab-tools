function alfa=computeAngleCorrection(x0,y0,csrc,ctar,CoordinateSystems,Operations)

% load('CoordinateSystems.mat');
% load('Operations.mat');

dx=0;
dy=0.1;

x1=x0+dx;
y1=y0+dy;

[x0,y0]=ConvertCoordinates(x0,y0,csrc.Name,csrc.Type,ctar.Name,ctar.Type,CoordinateSystems,Operations);
[x1,y1]=ConvertCoordinates(x1,y1,csrc.Name,csrc.Type,ctar.Name,ctar.Type,CoordinateSystems,Operations);

dx=x1-x0;
dy=y1-y0;

alfa=atan2(dy,dx)-0.5*pi;
