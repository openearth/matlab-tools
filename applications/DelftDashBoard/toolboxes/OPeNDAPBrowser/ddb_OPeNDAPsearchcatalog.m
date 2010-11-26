function ddb_OPeNDAPsearchcatalog(handles,opt)
% OPENDAP_SEARCH_CATALOG Routine searches the catalog of the opendap browser based on a search keyword
%
% See also opendap_browser

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

%% get data from userdata
handles           = getHandles;
C                 = get(handles.GUIHandles.Pushddb_FindDataset, 'userdata' );
srchtxt           = get(handles.GUIHandles.SearchText,'string');

%% search the dataset
index             = ( ...
    ~cellfun(@isempty, cellfun(@strfind, lower(C.urlPath),         repmat({lower(srchtxt)},size(C.title)), 'UniformOutput', false) ) | ...
    ~cellfun(@isempty, cellfun(@strfind, lower(C.title),           repmat({lower(srchtxt)},size(C.title)), 'UniformOutput', false) ) | ...
    ~cellfun(@isempty, cellfun(@strfind, lower(C.standard_names),  repmat({lower(srchtxt)},size(C.title)), 'UniformOutput', false) ) | ...
    ~cellfun(@isempty, cellfun(@strfind, lower(C.institution),     repmat({lower(srchtxt)},size(C.title)), 'UniformOutput', false) ) ...
);

set(handles.GUIHandles.ListNcFiles,'string',C.urlPath(index),'value',1)

%% create coloring depending on selection
obj1              = findobj(gca, 'type', 'patch');     obj1userdata  = get(obj1, 'userdata');
obj2              = findobj(gca, 'type', 'rectangle'); obj2userdata  = get(obj2, 'userdata');
obj12             = [obj1; obj2];                      obj12userdata = get(obj12,'userdata');

clrid12           = ismember( vertcat(obj12userdata{:}), C.urlPath(index) ); 
if ~isempty(obj1userdata)
    clrid1            = ismember( vertcat(obj1userdata{:}),  C.urlPath(index) ); % selected patches
else
    clrid1 = [];
end

if ~isempty(obj2userdata)
    clrid2            = ismember( vertcat(obj2userdata{:}),  C.urlPath(index) ); % selected rectangles
else
    clrid2 = [];
end
% first set all shapes to their unselected form
try set(obj1,         'facecolor', [1 0 0], 'FaceAlpha', .25); end           % not selected - red (patch)
try set(obj2,         'facecolor', [1 0 0] );                  end           % not selected - red (rectangle)

% next set selected shapes to the selected form 
try set(obj1(clrid1), 'facecolor', [0 1 0], 'FaceAlpha', 1);   end           % selected - green (patch)
try set(obj2(clrid2), 'facecolor', [0 1 0]);                   end           % selected - green (rectangle)

ddb_OPeNDAPorderobjects

%% if no results are returned place all available files in the listbox
if sum(clrid12) == 0
    set(handles.GUIHandles.ListNcFiles,'string',C.urlPath,'value',1)
end

