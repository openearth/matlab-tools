function [xRD,yRD] = xRSP2xyRD(varargin)
%XRSP2XYRD   transform RijksStrandPalen coordinates to RD coordinates
%    
% depending on inputs arguments, function will be:
%    nargin = 3: [xRD,yRD] = xRSP2xyRD(xRSP,section,transectNr);
%    nargin = 4: [xRD,yRD] = xRSP2xyRD(x0,y0,alpha,xRSP); 
%
%   [xRD,yRD] = xRSP2xyRD(xRSP,section,transectNr)
%   section and transectNr can be either single values, or arrays of the
%   same length as xRSP
%
%   [xRD,yRD] = xRSP2xyRD(x0,y0,alpha,xRSP)
%   x0/y0: zero point coordinates of transect; can be either single values,
%          or arrays of the same length as xRSP.
%   alpha: orientation of the transect (direction of positive xRSP). Can be
%          either single values, or array of the same length as xRSP. 
%          (!) Beware of certain old transects where alpha is based on a 
%          (!) 400 degree system in stead of 'normal' 360 degrees
%
% See also: convertCoordinatesNew

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

%% get data from database
if nargin == 3;
    
    %assign varargin
    xRSP        = varargin{1}; 
    section     = varargin{2};
    transectNr  = varargin{3};
    
    % load raai data
    fid = fopen('raaien.txt', 'r');
    data = textscan(fid, '%n %n %n %n %n', 'headerlines', 1);
    fclose(fid);

    % loop through data
    for ii = 1:length(transectNr)
        try
            ind(ii) = find(data{:,1}== section(ii)&data{:,2}==round(transectNr(ii)));
        catch
            error('could not convert section %d, transect number %d', section(ii), transectNr(ii))
        end
    end

    % assign variables
    alpha = data{5}(ind)/100;
    x0 = data{3}(ind)/100;
    y0 = data{4}(ind)/100;
else
    %assign varargin
    x0      = varargin{1}; 
    y0      = varargin{2};
    alpha   = varargin{3};
    xRSP    = varargin{4};
end

%% convert coordinates

xRD = x0 + xRSP.*sind(alpha);
yRD = y0 + xRSP.*cosd(alpha);
end

%% EOF

