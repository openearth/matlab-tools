function ddb_Delft3DFLOW_generateLayers(varargin)
%DDB_DELFT3DFLOW_GENERATELAYERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_generateLayers(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_generateLayers
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
if isempty(varargin)
    ddb_zoomOff;
    % Make new GUI
    handles=getHandles;
    xmldir=handles.Model(md).xmlDir;
    xmlfile='Delft3DFLOW.generatelayers.xml';
    if strcmpi(handles.Model(md).Input(ad).layerType,'z')
        handles.Model(md).Input(ad).layerOption=1;
    end
    for k=1:handles.Model(md).Input(ad).KMax
        handles.Model(md).Input(ad).layerStrings{k}=num2str(handles.Model(md).Input(ad).thick(k),'%8.3f');
    end
    [handles,ok]=newGUI(xmldir,xmlfile,handles,'iconfile',[handles.settingsDir '\icons\deltares.gif']);
    if ok
        setHandles(handles);
        setUIElement('delft3dflow.domain.domainpanel.grid.sumlayers');
        setUIElement('delft3dflow.domain.domainpanel.grid.layertable');
    end
    setUIElements('delft3dflow.domain.domainpanel.grid');
else
    opt=varargin{1};
    switch lower(opt)
        case{'generatelayers'}
            generateLayers;
        case{'pushok'}
            handles=getTempHandles;
            handles.ok=1;
            setTempHandles(handles);
            close(gcf);
        case{'pushcancel'}
            handles=getTempHandles;
            handles.ok=0;
            setTempHandles(handles);
            close(gcf);
    end
end

%%
function generateLayers

handles=getTempHandles;

switch handles.Model(md).Input(ad).layerOption
    case 1
        % Increasing from surface
        thick=generateLayerThickness('kmax',handles.Model(md).Input(ad).KMax,'type',handles.Model(md).Input(ad).layerType, ...
            'zbot',handles.Model(md).Input(ad).zBot,'ztop',handles.Model(md).Input(ad).zTop, ...
            'thicktop',handles.Model(md).Input(ad).thickTop);
    case 2
        % Increasing from bottom
        thick=generateLayerThickness('kmax',handles.Model(md).Input(ad).KMax,'type',handles.Model(md).Input(ad).layerType, ...
            'zbot',handles.Model(md).Input(ad).zBot,'ztop',handles.Model(md).Input(ad).zTop, ...
            'thickbot',handles.Model(md).Input(ad).thickBot);
    case 2
        % Increasing from top and bottom
        thick=generateLayerThickness('kmax',handles.Model(md).Input(ad).KMax,'type',handles.Model(md).Input(ad).layerType, ...
            'zbot',handles.Model(md).Input(ad).zBot,'ztop',handles.Model(md).Input(ad).zTop, ...
            'thicktop',handles.Model(md).Input(ad).thickTop,'thickbot',handles.Model(md).Input(ad).thickBot);
    case 4
        % Equidistant
        thick=generateLayerThickness('kmax',handles.Model(md).Input(ad).KMax,'type',handles.Model(md).Input(ad).layerType, ...
            'zbot',handles.Model(md).Input(ad).zBot,'ztop',handles.Model(md).Input(ad).zTop);
end

handles.Model(md).Input(ad).thick=thick';

for k=1:handles.Model(md).Input(ad).KMax
    handles.Model(md).Input(ad).layerStrings{k}=num2str(handles.Model(md).Input(ad).thick(k),'%8.3f');
end

setTempHandles(handles);

setUIElement('testje.listlayers');



