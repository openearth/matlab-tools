function ddb_NestingToolbox_Delft3DWAVE_nest1(varargin)
%ddb_NestingToolbox_Delft3DWAVE_nest1

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'','Click Make Observation Points in order to generate observation points in the overall grid', ...
                'The overall model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nest1'}
            nest1;
    end
end

%%
function nest1

handles=getHandles;

if isempty(handles.toolbox.nesting.grdFile)
    ddb_giveWarning('text','Please first load grid file of nested model!');
    return
end

if isempty(handles.toolbox.nesting.depFile)
    ddb_giveWarning('text','Please first load depth file of nested model!');
    return
end

if isempty(handles.Model(md).Input.domains(awg).gridx)
    ddb_giveWarning('text','Please first load or create model grid!');
    return    
end

[xg,yg,enc,cs,nodatavalue] = wlgrid('read',handles.toolbox.nesting.grdFile);
depth = wldep('read',handles.toolbox.nesting.depFile,[size(xg,1)+1 size(xg,2)+1]);
depth=depth(1:end-1,1:end-1);

bnd=findboundarysectionsonregulargrid(xg,yg);

nbnd=length(bnd);

nlocsets=handles.Model(md).Input.nrlocationsets;

% File name locations file
[filename, pathname, filterindex] = uiputfile('*.loc','File name locations file (length of file name should be less than 5 characters!)');
if ~pathname==0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    if nlocsets>0
        ii=strmatch(filename,handles.Model(md).Input.locationfile,'exact');
    else
        ii=[];
    end
    if isempty(ii)
        % New location set
        nlocsets=nlocsets+1;
    end
    handles.Model(md).Input.locationfile{nlocsets}=filename;
else
    return
end

handles.Model(md).Input.locationsets=ddb_initializeDelft3DWAVELocationSet(handles.Model(md).Input.locationsets,nlocsets);

np=0;
ithin=20;
for ibnd=1:ithin:nbnd
    m=bnd(ibnd).m1;
    n=bnd(ibnd).n1;
    % Check that depth at this point is greater than 0
    if depth(m,n)>0
        np=np+1;
        xp=xg(m,n);
        yp=yg(m,n);
        handles.Model(md).Input.locationsets(nlocsets).x(np)=xp;
        handles.Model(md).Input.locationsets(nlocsets).y(np)=yp;
    end
end

handles.Model(md).Input.locationsets(nlocsets).nrpoints=np;
for ii=1:np
    handles.Model(md).Input.locationsets(nlocsets).pointtext{ii}=num2str(ii);
end

handles.Model(md).Input.nrlocationsets=nlocsets;
handles.Model(md).Input.activelocationset=nlocsets;

% Save locations file
ddb_Delft3DWAVE_saveLocationFile(handles.Model(md).Input.locationfile{nlocsets},handles.Model(md).Input.locationsets(nlocsets));

handles.Model(md).Input.writespec2d=1;

handles=ddb_Delft3DWAVE_plotOutputLocations(handles,'plot','visible',1,'active',0);

setHandles(handles);

