function dcdz = sedimentdcdz(epsilonscw, ws, c)
%SEDIMENTDCDZ computes the vertical sediment concentration gradient based
% on a sediment mixing coefficient, the fall velocity of the sediment and
% the concentration
%
% Input:
%   epsilonscw:   sediment mixing (m^2/s)
%   ws:           sediment fall velocity (m/s)
%   c:            volume concentration (m^3/m^3)
%
% Output:
%   dcdz:         concentration gradient
%
% Example:
%   see sedimentdcdz_demo
%
% Alkyon 2008, Bart Grasmeijer (grasmeijer@alkyon.nl)
%
% 

c0 = 0.65;
dcdz = -(1 - c)^5 * c * ws / (epsilonscw * (1 + (c / c0)^0.8 - 2 * (c / c0)^0.4));
