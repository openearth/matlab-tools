function OPT = grid_orth_getPolygon(OPT)
%GRID_ORTH_GETPOLYGON Allows user to select and save a polygon.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

ah = findobj('type','axes','tag',OPT.tag);
try delete(findobj(ah,'tag','selectionpoly'));  end %#ok<*TRYNC> delete any remaining poly

% if no polygon is available yet draw one
if isempty(OPT.polygon)
    % make sure the proper axes is current
    try axes(ah); end
    
    jjj = menu({'Zoom to your place of interest first.',...
        'Next select one of the following options.',...
        'Finish clicking of a polygon with the <right mouse> button.'},...
        '1. click a polygon',...
        '2. click a polygon and save to ldb file',...
        '3. load a polygon from ldb file',...
        '4. click a polygon and save to mat file',...
        '5. load a polygon from mat file' ...
        );
    
    if jjj~=3 ||jjj~=5
        % draw a polygon using polydraw making sure it is tagged properly
        disp('Please click a polygon from which to select data ...')
        [x,y] = polydraw('g','linewidth',2,'tag','selectionpoly');
        
    elseif jjj==3
        % load and plot a polygon
        [fileName, filePath] = uigetfile({'*.ldb','Delt3D landboundary file (*.ldb)'},'Pick a landboundary file');
        [x,y]=landboundary_da('read',fullfile(filePath,fileName));
        x = x';
        y = y';
    elseif jjj==5
        % load and plot a polygon
        [fileName, filePath] = uigetfile({'*.mat','Two column xy array (*.mat)'},'Pick a polygon');
        load(fullfile(filePath,fileName));
        x = polygon(:,1)';
        y = polygon(:,2)';
    end
    
    % save polygon
    if jjj==2
        [fileName, filePath] = uiputfile({'*.ldb','Delt3D landboundary file (*.ldb)'},'Specifiy a landboundary file',...
            ['polygon_',datestr(now)]);
        landboundary_da('write',fullfile(filePath,fileName),x,y);
    end
    if jjj==4                       
        if isfield(OPT, 'polygondir') % needed when this routine is called from generateVolumeDevelopment
            polygondir = OPT.polygondir;
            if ~exist(polygondir)
                mkpath(polygondir)
            end
        else
            polygondir = [];
        end
        [fileName, filePath] = uiputfile([polygondir filesep 'polygon_',datestr(now,'yyyy-mm-dd_HH.MM.ss') '.mat'],'Specify a polygon');
        
        polygon = [x' y']; %#ok<NASGU>
        save(fullfile(filePath,fileName),'polygon');
    end
    
    % combine x and y in the variable polygon and close it
    OPT.polygon = [x' y'];
    OPT.polygon = [OPT.polygon; OPT.polygon(1,:)];
    
else
    
    x = OPT.polygon(:,1);
    y = OPT.polygon(:,2);
    
end
