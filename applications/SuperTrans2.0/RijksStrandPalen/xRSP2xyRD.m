function [xRD,yRD] = xRSP2xyRD(xRSP,section,transectNr)
%XRSP2XYRD   transform RijskStrandPalen coordinates to RD coordinates
%
%    [xRD,yRD] = xRSP2xyRD(xRSP,section,transectNr)
%
%   section and transectNr can be either single values, or arrays of the
%   same length as xRD
%
%See also: convertCoordinatesNew

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% load raai data
fid = fopen('raaien.txt', 'r');
data = textscan(fid, '%n %n %n %n %n', 'headerlines', 1);
fclose(fid);


%% loop through data
for ii = 1:length(transectNr)
    try
        ind(ii) = find(data{:,1}== section(ii)&data{:,2}==transectNr(ii)*10);
    catch
        error('could not convert section %d, transect number %d', section(ii), transectNr(ii))
    end
end

%% convert coordinates
alpha = data{5}(ind)/180*pi/100;
x0 = data{3}(ind)/100;
y0 = data{4}(ind)/100;
xRD = x0 + xRSP.*sin(alpha);
yRD = y0 + xRSP.*cos(alpha);
end

%% EOF

