function [d] = UCIT_getMetaData
%UCIT_GETMETADATA   this routine gets meta data from the most convenient place
%
% This routine gets meta data from the most convenient place. The most
% convenient place is the userdata of the UCIT console. If no data is
% available there or if the available data does not match the puldown
% selection on the UCIT console a database query is performed. At the end
% of this query the data will be stored in the userdata of the UCIT console
% again.
%
% input:
%    function has no input
%
% output:
%    function has no output
%
% see also ucit, displayTransectOutlines, plotDotsInPolygon

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% $Id$
% $Date$
% $Author$
% $Revision$

if ~(strcmp(UCIT_DC_getInfoFromPopup('TransectsArea'),'Select area ...') && strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),'Lidar Data US'))
    
    %% get metadata
    getDataFromDatabase = false;
    
    % try to get metadata variable d from userdata UCIT console
    d = [];
    try % to find metadata
        d = get(findobj('tag','UCIT_mainWin'),'Userdata');
    end
    
    % if no data was on UCIT console yet (or if it is the wrong data) reload from database
    if ~isempty(d) % Check to see if some data is available in d ...
        
        % ... if the datatype info as well as the soundingID data matches with the
        % values in the gui the data will not have to be collected again
        if strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'), 'Jarkus Data') && ~strcmp(d.datatypeinfo(1), UCIT_DC_getInfoFromPopup('TransectsDatatype')) || ...
                strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'), 'Lidar Data US') && (~strcmp(d.datatypeinfo(1), UCIT_DC_getInfoFromPopup('TransectsDatatype')) || ~strcmp(d.area(1), UCIT_DC_getInfoFromPopup('TransectsArea'))) 
            
            % ... if there is not a match the data will have to be collected again
            disp('data needs to be collected from database again ... please wait!')
            getDataFromDatabase = true;
        end
    else % ... if there is no data in d the data will have to be collected again
        getDataFromDatabase = true;
    end
    
    %% if getDataFromDatabase == true get the metadata and store it in the userdata of the UCIT console
    if getDataFromDatabase
        
        datatypes = UCIT_getDatatypes;
        url = datatypes.transect.urls{find(strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names))};
        
        if strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),'Lidar Data US')
            url = url{strcmp(datatypes.transect.areas{2},UCIT_DC_getInfoFromPopup('TransectsArea'))};
        end
        crossshore = nc_varget(url, 'cross_shore');
        alongshore = nc_varget(url, 'alongshore');
        areacodes  = nc_varget(url, 'areacode');
        areanames  = nc_varget(url, 'areaname');
        years  = nc_varget(url, 'time');
        ids = nc_varget(url, 'id');
        
        areanames = cellstr(areanames);
        transectID = cellstr(num2str(ids));
        soundingID = cellstr(num2str(years));
        
        if strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'), 'Jarkus Data')
            
            contours(:,1) = nc_varget(url, 'x',[0 0],[length(alongshore) 1]);
            contours(:,2) = nc_varget(url, 'x',[0 length(crossshore)-1],[length(alongshore) 1]);
            contours(:,3) = nc_varget(url, 'y',[0 0],[length(alongshore) 1]);
            contours(:,4) = nc_varget(url, 'y',[0 length(crossshore)-1],[length(alongshore) 1]);
            d.area = areanames;
            
        elseif strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'), 'Lidar Data US')
            
            contours = nc_varget(url, 'contour'); % if you want all lidar data use UCIT_getLidarMetaData
            d.area = repmat({UCIT_DC_getInfoFromPopup('TransectsArea')},length(areanames),1);
            
        end
        
        
        
        d.datatypeinfo = repmat({UCIT_DC_getInfoFromPopup('TransectsDatatype')},length(alongshore),1);
        d.contour =  [contours(:,1) contours(:,2) contours(:,3) contours(:,4)];
        d.areacode = areacodes;
        d.soundingID = soundingID;
        d.transectID = transectID;
        d.year = years;
        
        set(findobj('tag','UCIT_mainWin'),'UserData',d);
    else
        disp('data gathered from gui-data UCIT console')
    end
else
    d = [];
    errordlg('Select an area first')
end

