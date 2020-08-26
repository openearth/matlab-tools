%------------------------------------------------------------------------------
%
% SolarEclipseFlag: Returns a 2 char. string indicating the possibility of 
%                   a solar eclipse
%
% Input:
%   beta      Ecliptic latitude of the Moon in [rad]
%
% Output:
%   out       Eclipse flag
%
% Last modified:   2015/08/12   M. Mahooti
% 
%------------------------------------------------------------------------------
function out = SolarEclipseFlag (beta)

b = abs(beta);

if (b>0.027586)
    out = '  '; % No solar eclipse possible
    return;
end
if (b<0.015223)
    out = 'c '; % Central eclipse certain
    return;   
end
if (b<0.018209)
    out = 'c?'; % Possible central eclipse
    return;
end
if (b<0.024594)
    out = 'p '; % Partial solar eclipse certain
    return;
end

out = 'p?';     % Possible partial solar eclipse

