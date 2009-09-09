%% Coordinate conversion from RSP to RD

%% Introduction
% Sometimes one has data in the RSP grid, and this needs to be converted to
% RD coordinates. You can use the function xRSP2xyRD for this. Almost
% everything is already in the help. 

help xRSP2xyRD

%% example
% Example of the function:

x          = -100:50:200;  % some coordinates
areacode   = 7;            % Noord-Holland
alongshore = 3800;         % near Egmond

[xRD,yRD] = xRSP2xyRD(x,areacode,alongshore)


