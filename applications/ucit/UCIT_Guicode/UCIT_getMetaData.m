function [d] = UCIT_getMetaData(type)
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
% See also: ucit, UCIT_plotDotsInPolygon

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

if ~isnumeric(type)
    OPT = type;
    datatype = OPT.datatype;
    type = 2;
end

%% TRANSECT
if type == 1
    if ~(strcmp(UCIT_getInfoFromPopup('TransectsArea')    ,'Select area ...') && ...
            strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),'Lidar Data US'  ))
        
        %% get metadata
        
        getDataFromDatabase = false;
        
        % try to get metadata variable d from userdata UCIT console
        d = [];
        try % to find metadata
            d = get(findobj('tag','UCIT_mainWin'),'Userdata');
        end
        
        % set areaname
        if strcmp(UCIT_getInfoFromPopup('TransectsArea'),'Oregon'),areaid = 'Oregon';elseif strcmp(UCIT_getInfoFromPopup('TransectsArea'),'Washington');areaid = 'Washington';end
        
        % if no data was on UCIT console yet (or if it is the wrong data) reload from database
        if ~isempty(d) % Check to see if some data is available in d ...
            
            % ... if the datatype info as well as the soundingID data matches with the
            % values in the gui the data will not have to be collected again
            if strcmp(UCIT_getInfoFromPopup('TransectsDatatype'), 'Jarkus Data') &&  ~strcmp(d.datatypeinfo(1), UCIT_getInfoFromPopup('TransectsDatatype')) || ...
                    strcmp(UCIT_getInfoFromPopup('TransectsDatatype'), 'Lidar Data US') && (~strcmp(d.datatypeinfo(1), UCIT_getInfoFromPopup('TransectsDatatype')) || ...
                    ~strcmp(areaid        , UCIT_getInfoFromPopup('TransectsArea')))
                
                % ... if there is not a match the data will have to be collected again
                disp('Data needs to be collected from database again ... please wait!')
                getDataFromDatabase = true;
            end
        else % ... if there is no data in d the data will have to be collected again
            getDataFromDatabase = true;
        end
        
        %% if getDataFromDatabase == true get the metadata and store it in the userdata of the UCIT console
        
        if getDataFromDatabase
            
            d = [];
            datatypes     = UCIT_getDatatypes;
            ind           = find(strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),datatypes.transect.names));
            url           = datatypes.transect.urls{ind};
            ldb           = datatypes.transect.ldbs{ind};
            axis_settings = datatypes.transect.axes{ind};
            
            
            if strcmp(UCIT_getInfoFromPopup('TransectsDatatype'),'Lidar Data US')
                url   = url{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
                ldb   = ldb{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
                axis_settings = axis_settings{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
                extra = datatypes.transect.extra{ind};
                extra = extra{strcmp(datatypes.transect.areas{2},UCIT_getInfoFromPopup('TransectsArea'))};
            end
            
            crossshore = nc_varget(url, 'cross_shore');
            alongshore = nc_varget(url, 'alongshore');
            areacodes  = nc_varget(url, 'areacode');
            areanames  = nc_varget(url, 'areaname');
            years      = nc_varget(url, 'time');
            ids        = nc_varget(url, 'id');
            
            areanames  = cellstr(areanames);
            transectID = cellstr(num2str(ids));
            soundingID = cellstr(num2str(years));
            
            if strcmp(UCIT_getInfoFromPopup('TransectsDatatype'), 'Jarkus Data')
                
                contours(:,1) = nc_varget(url, 'x',[0 0                   ],[length(alongshore) 1]);
                contours(:,2) = nc_varget(url, 'x',[0 length(crossshore)-1],[length(alongshore) 1]);
                contours(:,3) = nc_varget(url, 'y',[0 0                   ],[length(alongshore) 1]);
                contours(:,4) = nc_varget(url, 'y',[0 length(crossshore)-1],[length(alongshore) 1]);
                d.area        = areanames;
                
            elseif strcmp(UCIT_getInfoFromPopup('TransectsDatatype'), 'Lidar Data US')
                
                contours = nc_varget(url, 'contour'); % if you want all lidar data use UCIT_getLidarMetaData
                d.area   = repmat({UCIT_getInfoFromPopup('TransectsArea')},length(areanames),1);
                d.extra  = extra;
                
            end
            
            d.datatypeinfo = repmat({UCIT_getInfoFromPopup('TransectsDatatype')},length(alongshore),1);
            d.contour      = [contours(:,1) contours(:,2) contours(:,3) contours(:,4)];
            d.areacode     = areacodes;
            d.soundingID   = soundingID;
            d.transectID   = transectID;
            d.year         = years;
            d.ldb          = ldb;
            d.axes         = axis_settings;
            
            set(findobj('tag','UCIT_mainWin'),'UserData',d);
        else
            disp('Data gathered from gui-data UCIT console')
        end
    else
        d = [];
        errordlg('Select an area first')
    end
    
    %% GRID
elseif type == 2
    
    %% get metadata
    
    getDataFromDatabase = false;
    
    % try to get metadata variable d from userdata UCIT console
    d = [];
    try % to find metadata
        d = get(findobj('tag','UCIT_mainWin'),'Userdata');
    end
    
    % if no data was on UCIT console yet (or if it is the wrong data) reload from database
    if ~isempty(d) % Check to see if some data is available in d ...
        
        % ... if the datatype info matches with the values in the gui the data will not have to be collected again
        if ~strcmp(d.datatypeinfo, UCIT_getInfoFromPopup('GridsDatatype'))
            
            % ... if there is not a match the data will have to be collected again
            disp('Data needs to be collected from database again ... please wait!')
            getDataFromDatabase = true;
        end
    else % ... if there is no data in d the data will have to be collected again
        getDataFromDatabase = true;
    end
    
    %% if getDataFromDatabase == true get the metadata and store it in the userdata of the UCIT console
    
    if getDataFromDatabase
        d               = [];
        datatypes       = UCIT_getDatatypes;
        if ~exist('datatype')
            d.datatypeinfo  = UCIT_getInfoFromPopup('GridsDatatype');
            if strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'AHN100')% temporary workaround until catalogfile AHN fixed
                temp_url = d.urls{1};d.urls = [];d.urls{1} = temp_url;
            elseif strcmp(UCIT_getInfoFromPopup('GridsDatatype'),'AHN250')
                temp_url = d.urls{2};d.urls = [];d.urls{1} = temp_url;
            end
        else
            d.datatypeinfo  = datatype;
        end
        ind             = find(strcmp(d.datatypeinfo,datatypes.grid.names));
        if isempty(ind)
            datatypes.grid.names
            error(['Please use correct name of datatype'])
        end
        url             = datatypes.grid.urls{ind};
        d.catalog       = datatypes.grid.catalog{ind}; % need for grid_2D_orthogonal toolbox
        d.ldb           = datatypes.grid.ldbs{ind};
        d.axes          = datatypes.grid.axes{ind};
        d.cellsize      = datatypes.grid.cellsize{ind};
        d.urls = opendap_catalog(datatypes.grid.catalog{ind});
        OPT2 = grid_orth_getMapInfoFromDataset(d.catalog);
        d.contour = [OPT2.x_ranges OPT2.y_ranges] ;
        d.names        = d.urls;
        d.x_ranges     = OPT2.x_ranges;
        d.y_ranges     = OPT2.y_ranges;
        
        set(findobj('tag','UCIT_mainWin'),'UserData',d);
    else
        disp('Data gathered from gui-data UCIT console')
    end
else
    d = [];
    errordlg('Select an area first')
end

if exist('OPT') 
    d.datatype = OPT.datatype;
    d.thinning = OPT.thinning;
    d.timewindow = OPT.timewindow;
    d.inputyears = OPT.inputyears;
    d.min_coverage = OPT.min_coverage;
    d.type = OPT.type;
end

