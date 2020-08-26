%--------------------------------------------------------------------------
%
% LunarEclipseFlag: Returns a 2 char. string indicating the possibility of
%                   a lunar eclipse
%
% Input:
%   beta      Ecliptic latitude of the Moon [rad]
%
% Output:   
%   out       Eclipse flag
%
% Last modified:   2015/08/12   M. Mahooti
% 
%--------------------------------------------------------------------------
function out = LunarEclipseFlag (beta)

b = abs(beta);

if (b>0.028134)
    out = '  ';
    return;   % No lunar eclipse possible
end
if (b<0.006351)
    out = 't ';
    return;   % Total lunar eclipse certain
end
if (b<0.009376)
    out = 't?';
    return;   % Possible total eclipse
end
if (b<0.015533)
    out = 'p ';
    return;   % Partial lunar eclipse certain
end
if (b<0.018568)
    out = 'p?';
    return;   % Possible partial eclipse
end
if (b<0.025089)
    out = 'p ';
    return;   % Penumbral lunar eclipse certain
end

out = 'P?';   % Possible penumbral lunar eclipse

