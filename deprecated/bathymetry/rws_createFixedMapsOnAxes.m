function ah = rws_createFixedMapsOnAxes(ah, urls, varargin)
error('This function is deprecated in favour of grid_orth_createFixedMapsOnAxes')
%rws_CREATEFIXEDMAPSONAXES   plot fixed maps retrieved from OPeNDAP server to any arbitrary axes
%
% See also: rws_getDataInPolygon, rws_getFixedMapOutlines, rws_identifyWhichMapsAreInPolygon, getDataFromNetCDFGrid


% --------------------------------------------------------------------
% Copyright (C) 2004-2009 Delft University of Technology
% Version:      Version 1.0, February 2004
%     Mark van Koningsveld
%
%     m.vankoningsveld@tudelft.nl
%
%     Hydraulic Engineering Section
%     Faculty of Civil Engineering and Geosciences
%     Stevinweg 1
%     2628CN Delft
%     The Netherlands
%
% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Lesser General Public
% License as published by the Free Software Foundation; either
% version 2.1 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA
% --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$

%% make the axes to use the current one
axes(ah);
set (ah, varargin{:}); % make sure it is properly tagged

%% for each available url get the actual_range and creat a patch
for i = 1:length(urls)
    x_range = nc_getvarinfo(urls{i}, 'x');
    y_range = nc_getvarinfo(urls{i}, 'y');
    
    if any(ismember({y_range.Attribute.Name}, 'actual_range')) && ...
       any(ismember({x_range.Attribute.Name}, 'actual_range'))
        x_range = str2num(x_range.Attribute(ismember({x_range.Attribute.Name}, 'actual_range')).Value);
        y_range = str2num(y_range.Attribute(ismember({y_range.Attribute.Name}, 'actual_range')).Value);
    else
        x       = nc_varget(urls{i}, 'x');
        y       = nc_varget(urls{i}, 'y');
        x_range = [min(x) max(x)];
        y_range = [min(y) max(y)];
    end
    ph = patch([x_range(1) x_range(2) x_range(2) x_range(1) x_range(1)], ...
               [y_range(1) y_range(1) y_range(2) y_range(2) y_range(1)], 'k');
    set(ph, 'edgecolor', 'r', 'facecolor', 'none');
    drawnow
    tickmap('xy');
    set(ph,'tag',urls{i});
end

tickmap ('xy','texttype','text')
box on

 %% EOF
