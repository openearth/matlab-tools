function ddb_ModelMakerToolbox_roughness(varargin)
%DDB_MODELMAKERTOOLBOX_ROUGHNESS  One line description goes here.
%
%   More detailed description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    setHandles(handles);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'generateroughness'}
            generateRoughness;
    end
    
end

%% 
function generateRoughness

handles=getHandles;

model=handles.activeModel.name;

[filename, pathname, filterindex] = uiputfile('*.rgh', 'Roughness File Name',[handles.model.(model).domain(ad).attName '.rgh']);

if pathname~=0

    d=handles.model.(model).domain(ad).depth;
    rgh=zeros(size(d));
    rgh(rgh==0)=NaN;    
    rgh(d>handles.toolbox.modelmaker.roughness.landelevation)=handles.toolbox.modelmaker.roughness.landroughness;
    rgh(isnan(rgh))=handles.toolbox.modelmaker.roughness.searoughness;
    ddb_wldep('write',[pathname filename],rgh,'negate','n');
    ddb_wldep('append',[pathname filename],rgh,'negate','n');
    
    handles.model.(model).domain(ad).uniformRoughness=0;
    if strcmpi(pwd,pathname(1:end-1))
        handles.model.(model).domain(ad).rghFile=filename;
    else
        handles.model.(model).domain(ad).rghFile=[pathname filename];
    end
    
    setHandles(handles);

end
