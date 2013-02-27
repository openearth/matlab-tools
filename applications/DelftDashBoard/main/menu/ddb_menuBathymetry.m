function ddb_menuBathymetry(hObject, eventdata, handles)
%DDB_MENUBATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_menuBathymetry(hObject, eventdata, handles)
%
%   Input:
%   hObject   =
%   eventdata =
%   handles   =
%
%
%
%
%   Example
%   ddb_menuBathymetry
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%

handles=getHandles;

lbl=get(hObject,'Label');

h=get(hObject,'Parent');
hp=get(h,'Parent');
if hp~=1
    h=hp;
end
ch=get(h,'Children');
set(ch,'Checked','off');
for ii=1:length(ch)
    chc=get(ch(ii),'children');
    if ~isempty(chc)
        set(chc,'Checked','off');
    end
end

set(hObject,'Checked','on');
p=get(hObject,'Parent');
pp=get(p,'Parent');
ppp=get(pp,'Parent');
if ppp==1
    ch=get(pp,'Children');
    set(ch,'ForegroundColor',[0 0 0]);    
    set(p,'ForegroundColor',[0 0 1]);    
else
    ch=get(p,'Children');
    set(ch,'ForegroundColor',[0 0 0]);    
end
iac=strmatch(lbl,handles.bathymetry.longNames,'exact');

if ~strcmpi(handles.screenParameters.backgroundBathymetry,handles.bathymetry.datasets{iac})
    handles.screenParameters.backgroundBathymetry=handles.bathymetry.datasets{iac};
    set(handles.GUIHandles.textBathymetry,'String',['Bathymetry : ' handles.bathymetry.longNames{iac} '   -   Datum : ' handles.bathymetry.dataset(iac).verticalCoordinateSystem.name]);
    setHandles(handles);
    ddb_updateDataInScreen;
end

