function UCIT_DC_loadRelevantInfo2Popup(type,PopupNR)
%UCIT_DC_LOADRELEVANTINFO2POPUP   This routine loads info from the database to the next popup
%
% This routine loads info from the database to the next popup
%
% syntax:    
%    UCIT_DC_loadRelevantInfo2Popup(type,PopupNR)
%
% input: 
%    type = variable identifying which kind of data is selected
%        1: transects
%        2: grids
%        3: lines
%        4: points
%    PopupNR = values range from 1:4
%
% output:       
%    function has no output  
%
% example:      
% 	UCIT_DC_loadRelevantInfo2Popup(1,1)
% 
% see also UCIT_DC_getInfoFromPopup

% --------------------------------------------------------------------
% Copyright (C) 2004-2008 Delft University of Technology
% Version:  $Date$ (Version 1.0, January 2006)
%     M.van Koningsveld
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

datatypes = UCIT_getDatatypes;
     
if type==1&&PopupNR==1
    %% TRANSECTS 
    % *** set TransectsDatatype

     
    % manufacture the string for in the popup menu
    string{length(datatypes.transect.names)+1}=[]; string{1}='Select datatype ...';
    for i=1:length(datatypes.transect.names)
        string{i+1}=datatypes.transect.names{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','TransectsDatatype'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_DC_resetValuesOnPopup(1,0,1,1,1,1);
    
    set(findobj('tag','UCIT_mainWin'),'Userdata',[]); % test
    
elseif type==1&&PopupNR==2
    % *** set TransectsArea
    objTag='TransectsDatatype';[popupValue, info]=UCIT_DC_getInfoFromPopup(objTag);
    
    if info.value==1
        UCIT_DC_loadRelevantInfo2Popup(1,1);
        return
    end

    % get info from database  
    
    if strcmp(UCIT_DC_getInfoFromPopup('TransectsDatatype'),'Jarkus Data')
        % get from single netCDF file
        areanames = nc_varget(datatypes.transect.urls{find(strcmp(UCIT_DC_getInfoFromPopup(objTag),datatypes.transect.names))}, 'areaname');
        areas = unique(cellstr(areanames));
    else
        areas = {'Oregon','Washington'};
    end
    
    % manufacture the string for in the popup menu
    string{max(size(areas))+1}=[]; string{1}='Select area ...';
    for i = 1:max(size(areas))
        string{i+1}=areas{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','TransectsArea'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_DC_resetValuesOnPopup(1,0,0,1,1,0)

    % find available actions for this datatype
    UCIT_DC_findAvailableActions(1)
   
elseif type==1&&PopupNR==3
    % *** set TransectsTransectID
    objTag='TransectsDatatype';
    
    % get info from database   
    areanames = nc_varget(datatypes.transect.urls{find(strcmp(UCIT_DC_getInfoFromPopup(objTag),datatypes.transect.names))}, 'areaname');
    ids = nc_varget(datatypes.transect.urls{find(strcmp(UCIT_DC_getInfoFromPopup(objTag),datatypes.transect.names))}, 'id');
    id_match = cellfun(@(x) (strcmp(x, UCIT_DC_getInfoFromPopup('TransectsArea'))==1), {cellstr(areanames)}, 'UniformOutput',false);
    transectIDs = {ids(id_match{1})- unique(round(ids(id_match{1})/1000000))*1000000}; % convert back from uniqu id

        
    % manufacture the string for in the popup menu
    string{max(size(transectIDs))+1}=[]; string{1}='Select transect ID ...';
    for i = 1:max(size(transectIDs))
        string{i+1}=transectIDs{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','TransectsTransectID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_DC_resetValuesOnPopup(1,0,0,0,1,0)

elseif type==1&&PopupNR==4
    % *** set TransectsSoundingID
    % get info from database
    objTag='TransectsDatatype';
    years = nc_varget(datatypes.transect.urls{find(strcmp(UCIT_DC_getInfoFromPopup(objTag),datatypes.transect.names))}, 'time');    
    soundingIDs = {datestr(years+datenum(1970,1,1))};
        
    % manufacture the string for in the popup menu
    string{max(size(soundingIDs))+1}=[]; string{1}='Select date ...';
    for i = 1:max(size(soundingIDs))
        string{i+1}=soundingIDs{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','TransectsSoundingID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');

elseif type==2&&PopupNR==1
    %% GRIDS
    % *** set GridsDataType
    % get info from database
    datatypes = DBgetUniqueFields('grid','datatypeinfo');
    datatypes = sort(datatypes);
    
    % manufacture the string for in the popup menu
    string{length(datatypes)+1}=[]; string{1}='Select datatype ...';
    for i=1:length(datatypes)
        string{i+1}=datatypes{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','GridsDatatype'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_DC_resetValuesOnPopup(2,0,1,1,1,1)

elseif type==2&&PopupNR==2
    % *** set GridsName
    objTag='GridsDatatype';[popupValue, info]=UCIT_DC_getInfoFromPopup(objTag);
    if info.value==1
        UCIT_DC_loadRelevantInfo2Popup(2,1);
        return
    end

    % get info from database
    names = DBgetUniqueFields('grid','name',{...
        'datatypeinfo',UCIT_DC_getInfoFromPopup('GridsDatatype')});
    names=sort(names);

    % manufacture the string for in the popup menu
    string{max(size(names))+1}=[]; string{1}='Select name ...';
    for i = 1:max(size(names))
        string{i+1}=names{i};
    end
    
    % fill the proper popup menu and reset others if required
    if length(string)==2
        set(findobj('tag','GridsName'), 'string', string, 'value', 2, 'enable', 'on', 'backgroundcolor', 'w');
        UCIT_DC_loadRelevantInfo2Popup(2,3);    
    else
        set(findobj('tag','GridsName'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
        UCIT_DC_resetValuesOnPopup(2,0,0,1,1,0)
    end

    % fill the proper popup menu and reset others if required
%     set(findobj('tag','GridsName'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');

    UCIT_DC_findAvailableActions(2)

elseif type==2&&PopupNR==3
    % *** set GridsInterval
    % get info from database
    intervals = DBgetUniqueFields('grid','year',{...
        'datatypeinfo',UCIT_DC_getInfoFromPopup('GridsDatatype'),...
        'name',UCIT_DC_getInfoFromPopup('GridsName')});
    intervals=sort(intervals);

    % manufacture the string for in the popup menu
    string{max(size(intervals))+1}=[]; string{1}='Select interval ...';
    for i = 1:max(size(intervals))
        string{i+1}=intervals{i};
    end
    
    % fill the proper popup menu and reset others if required
    if length(string)==2
        set(findobj('tag','GridsInterval'), 'string', string, 'value', 2, 'enable', 'on', 'backgroundcolor', 'w');
        UCIT_DC_loadRelevantInfo2Popup(2,4);
    else
        set(findobj('tag','GridsInterval'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
        UCIT_DC_resetValuesOnPopup(2,0,0,0,1,0)
    end

elseif type==2&&PopupNR==4
    % *** set GridsSoundingID
    % get info from database
    soundingIDs = DBgetUniqueFields('grid','soundingID',{...
        'datatypeinfo',UCIT_DC_getInfoFromPopup('GridsDatatype'),...
        'name',UCIT_DC_getInfoFromPopup('GridsName'),...
        'year',UCIT_DC_getInfoFromPopup('GridsInterval')});
    soundingIDs=sort(soundingIDs);
    % manufacture the string for in the popup menu
    string{max(size(soundingIDs))+1}=[]; string{1}='Select date ...';
    for i = 1:max(size(soundingIDs))
        string{i+1}=soundingIDs{i};
    end
    
    % fill the proper popup menu and reset others if required
    if length(string)==2
        set(findobj('tag','GridsSoundingID'), 'string', string, 'value', 2, 'enable', 'on', 'backgroundcolor', 'w');
    else
        set(findobj('tag','GridsSoundingID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    end
    
elseif type==3&&PopupNR==1
    %% LINES
    % set LinesDataType
    datatypes = DBgetUniqueFields('line','datatypeinfo');
    datatypes=sort(datatypes);
    
    % manufacture the string for in the popup menu
    string{length(datatypes)+1}=[]; string{1}='Select datatype ...';
    for i=1:length(datatypes)
        string{i+1}=datatypes{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','LinesDatatype'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_DC_resetValuesOnPopup(3,0,1,1,1,1)

elseif type==3&&PopupNR==2
    % set LinesName
    objTag='LinesDatatype';[popupValue, info]=UCIT_DC_getInfoFromPopup(objTag);
    if info.value==1
        UCIT_DC_loadRelevantInfo2Popup(3,1);
        return
    end

    % get info from database
    areas = DBgetUniqueFields('line','area',{...
        'datatypeinfo',UCIT_DC_getInfoFromPopup('LinesDatatype')});
    areas = sort(areas);

    % manufacture the string for in the popup menu
    string{max(size(areas))+1}=[]; string{1}='Select name ...';
    for i = 1:max(size(areas))
        string{i+1}=areas{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','LinesArea'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_DC_resetValuesOnPopup(3,0,0,1,1,0)

    UCIT_DC_findAvailableActions(3)    

elseif type==3&&PopupNR==3
    % set GridsInterval
    % set GridsInterval
    soundingIDs = DBgetUniqueFields('line','soundingID',{...
        'datatypeinfo',UCIT_DC_getInfoFromPopup('LinesDatatype'),...
        'area',UCIT_DC_getInfoFromPopup('LinesArea')});
    soundingIDs=sort(soundingIDs);
    
    % manufacture the string for in the popup menu
    string{max(size(soundingIDs))+1}=[]; string{1}='Select soundingID ...';
    for i = 1:max(size(soundingIDs))
        string{i+1}=soundingIDs{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','LinesSoundingID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_DC_resetValuesOnPopup(3,0,0,0,1,0)

elseif type==3&&PopupNR==4
    % set LinesLineID
    % set LinesSoundingID
    lineID = DBgetUniqueFields('line','lineID',{...
        'datatypeinfo',UCIT_DC_getInfoFromPopup('LinesDatatype'),...
        'area',UCIT_DC_getInfoFromPopup('LinesArea'),...
        'soundingID',UCIT_DC_getInfoFromPopup('LinesSoundingID')});
    
    % manufacture the string for in the popup menu
    [lineID]=parseStringOnToken(lineID,';');
    string{max(size(lineID))+1}=[]; string{1}='All';
    for i = 1:max(size(lineID))
        string{i+1}=lineID{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','LinesLineID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    
elseif type==4&&PopupNR==1
    %% POINTS
    % get info from database
    datatypes = DBgetUniqueFields('point','datatypeinfo');
    datatypes=sort(datatypes);
    
    % manufacture the string for in the popup menu
    string{length(datatypes)+1}=[]; string{1}='Select datatype ...';
    for i=1:length(datatypes)
        string{i+1}=datatypes{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','PointsDatatype'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_DC_resetValuesOnPopup(4,0,1,1,1,1)

elseif type==4&&PopupNR==2
    objTag='PointsDatatype';[popupValue, info]=UCIT_DC_getInfoFromPopup(objTag);
    if info.value==1
        UCIT_DC_loadRelevantInfo2Popup(4,1);
        return
    end

    % get info from database
    names = DBgetUniqueFields('point','station',{...
        'datatypeinfo',UCIT_DC_getInfoFromPopup('PointsDatatype')});
    names=sort(names);

    % manufacture the string for in the popup menu
    string{max(size(names))+1}=[]; string{1}='Select station ...';
    for i = 1:max(size(names))
        string{i+1}=names{i};
    end
    
    % fill the proper popup menu and reset others if required
    set(findobj('tag','PointsStation'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    UCIT_DC_resetValuesOnPopup(4,0,0,1,1,0)

    UCIT_DC_findAvailableActions(4)
    
elseif type==4&&PopupNR==3
    % set GridsSoundingID
    soundingIDs = DBgetUniqueFields('point','soundingID',{...
        'datatypeinfo',UCIT_DC_getInfoFromPopup('PointsDatatype'),...
        'station',UCIT_DC_getInfoFromPopup('PointsStation')});
    soundingIDs=sort(soundingIDs);
    
    % manufacture the string for in the popup menu
    string{max(size(soundingIDs))+1}=[]; string{1}='All';% string{1}='Select date ...';
    for i = 1:max(size(soundingIDs))
        string{i+1}=soundingIDs{i};
    end
    
    % fill the proper popup menu and reset others if required
    if length(string)==2
        set(findobj('tag','PointsSoundingID'), 'string', string, 'value', 2, 'enable', 'on', 'backgroundcolor', 'w');
    else
        set(findobj('tag','PointsSoundingID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    end

    UCIT_DC_resetValuesOnPopup(4,0,0,0,1,0)
    UCIT_DC_loadRelevantInfo2Popup(4,4);
    
elseif type==4&&PopupNR==4
    % set GridsInterval
    if strcmp(UCIT_DC_getInfoFromPopup('PointsSoundingID'),'All')
        dataID = DBgetUniqueFields('point','dataID',{...
            'datatypeinfo',UCIT_DC_getInfoFromPopup('PointsDatatype'),...
            'station',UCIT_DC_getInfoFromPopup('PointsStation')});
        dataID=sort(dataID);
    else
        dataID = DBgetUniqueFields('point','dataID',{...
            'datatypeinfo',UCIT_DC_getInfoFromPopup('PointsDatatype'),...
            'station',UCIT_DC_getInfoFromPopup('PointsStation'),...
            'soundingID',UCIT_DC_getInfoFromPopup('PointsSoundingID')});
        dataID=sort(dataID);
    end
    % manufacture the string for in the popup menu
    string{max(size(dataID))+1}=[]; string{1}='All';
    for i = 1:max(size(dataID))
        string{i+1}=dataID{i};
    end
    
    % fill the proper popup menu and reset others if required
    if length(string)==2
        set(findobj('tag','PointsDataID'), 'string', string, 'value', 2, 'enable', 'on', 'backgroundcolor', 'w');
    else
        set(findobj('tag','PointsDataID'), 'string', string, 'value', 1, 'enable', 'on', 'backgroundcolor', 'w');
    end

end