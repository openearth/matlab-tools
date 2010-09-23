function ddb_OPeNDAPBrowserToolbox
% DDB_OPENDAPBROWSERTOOLBOX  useful browser to scan through OPeNDAP catalogs

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

disp('Initialising ... please wait!')

handles=getHandles;

ddb_plotTideDatabase(handles,'activate');

%% draw items on gui
% generate outline
uipanel('Title','OPeNDAP Browser','Units','pixels','Position',[20 20 1560 160],'Tag','UIControl');

% list with remaining urls
handles.GUIHandles.ListNcFiles                  = uicontrol(gcf,'Style','listbox',   'String','',                           'Position',   [ 30  30 300 130],'BackgroundColor',[1 1 1],'Tag','UIControl');

% search box
handles.GUIHandles.SearchText                   = uicontrol(gcf,'Style','edit',      'String','Enter search text here ...', 'Position', [350 140 140  20] ,'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.Pushddb_FindDataset          = uicontrol(gcf,'Style','pushbutton','String','Find dataset',               'Position', [525 140 110 20]  ,'Tag','UIControl');
set(handles.GUIHandles.Pushddb_FindDataset,  'Callback',{@ddb_OPeNDAPsearchcatalog});

% box displaying selected dataset
handles.GUIHandles.SelectedURL                  = uicontrol(gcf,'Style','edit',      'String','',                           'Position', [350 110 550  20] ,'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

SetUIBackgroundColors;
setHandles(handles);

%% initialise ncfile list
fns          = dir([fileparts(which(mfilename('fullpath'))) filesep '*.nc']);
ncfiles      = cellstr([char(repmat({[fileparts(which(mfilename('fullpath'))) filesep]}, size(fns))), char({fns.name}')]);

if length(ncfiles)>1
    catalog  = nc_cf_merge_catalogs('filenames', ncfiles);
else
    catalog  = nc2struct(ncfiles{:});
end
% struct2nc('WorldWaves_catalog.nc',catalog)

ids = abs(catalog.geospatialCoverage_eastwest(:,1))<500;
fields       = fieldnames(catalog);
for i = 1:length(fields)
    D.(fields{i}) = catalog.(fields{i})(ids,:);
end
catalog = D; clear D

% put available URL's in listbox
set(handles.GUIHandles.ListNcFiles,'string',catalog.urlPath)

%% sort catalog entries on size
C            = catalog; clear catalog

xll          = C.geospatialCoverage_eastwest(:,1);
yll          = C.geospatialCoverage_northsouth(:,1);
xur          = C.geospatialCoverage_eastwest(:,2);
yur          = C.geospatialCoverage_northsouth(:,2);

sizes        = sqrt((xur - xll).^2 + (yur - yll).^2);
[dummy, ids] = sort(sizes, 'descend');

fields       = fieldnames(C);
for i = 1:length(fields)
    D.(fields{i}) = C.(fields{i})(ids,:);
end
C = D; clear D

%% put catalog data in userdata of search button
set(handles.GUIHandles.Pushddb_FindDataset,'userdata',C)

%% plot data from catalog
% plot grids as a rectangle
id =   C.geospatialCoverage_eastwest(:,1) ~= C.geospatialCoverage_eastwest(:,2);
cntr = 0;
for j = find(id)'
    cntr = cntr + 1;
    ph(cntr) = patch( ...
        [C.geospatialCoverage_eastwest(j,1) C.geospatialCoverage_eastwest(j,2) C.geospatialCoverage_eastwest(j,2) C.geospatialCoverage_eastwest(j,1) C.geospatialCoverage_eastwest(j,1)], ...
        [C.geospatialCoverage_northsouth(j,1) C.geospatialCoverage_northsouth(j,1) C.geospatialCoverage_northsouth(j,2) C.geospatialCoverage_northsouth(j,2) C.geospatialCoverage_northsouth(j,1)], ...
        'r');
    set(ph(cntr), 'facecolor','r','edgecolor','k','tag', 'OPeNDAPGrid', 'FaceAlpha', .25)
    set(ph(cntr),'ButtonDownFcn',{@ddb_OPeNDAPclbkobj},'userdata',C.urlPath(j));
end

% plot stations as a point
id = C.geospatialCoverage_eastwest(:,1) == C.geospatialCoverage_eastwest(:,2);
cntr = 0;
for j = find(id)'
    cntr = cntr + 1;
    ph(cntr) = rectangle('position', [C.geospatialCoverage_eastwest(j,1), C.geospatialCoverage_northsouth(j,1), .1, .1], 'Curvature', [1,1]);
    set(ph(cntr), 'facecolor','r','edgecolor','k','tag', 'OPeNDAPPoint')
    set(ph(cntr),'ButtonDownFcn',{@ddb_OPeNDAPclbkobj},'userdata',C.urlPath(j));
end


ddb_OPeNDAPorderobjects