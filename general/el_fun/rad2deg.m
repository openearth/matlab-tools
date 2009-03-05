function deg = rad2deg(rad)
%RAD2DEG   conversion of degrees to radians
%
% Note the officla Mathworks RAD2DEG is part of the mapping toolbox.
%
%See also: DEG2RAD, ANGLE2DOMAIN, MAP

deg = (180/pi).*rad;

% eof