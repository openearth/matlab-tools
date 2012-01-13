function ddb_NestingToolbox_nestHD1(varargin)
%DDB_NESTINGTOOLBOX_NESTHD1  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_NestingToolbox_nestHD1(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_NestingToolbox_nestHD1
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
    setUIElements('nestingpanel.nesthd1');
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nesthd1'}
            nestHD1;
    end
end

%%
function nestHD1

handles=getHandles;

fid=fopen('nesthd1.inp','wt');
fprintf(fid,'%s\n',handles.Model(md).Input(ad).grdFile);
fprintf(fid,'%s\n',handles.Model(md).Input(ad).encFile);
fprintf(fid,'%s\n',handles.Toolbox(tb).Input.grdFile);
fprintf(fid,'%s\n',handles.Toolbox(tb).Input.encFile);
fprintf(fid,'%s\n',handles.Toolbox(tb).Input.bndFile);
fprintf(fid,'%s\n',handles.Toolbox(tb).Input.admFile);
fprintf(fid,'%s\n','ddtemp.obs');
fclose(fid);

system([handles.Toolbox(tb).dataDir 'nesthd1 < nesthd1.inp']);

[name,m,n] = textread('ddtemp.obs','%21c%f%f');

nr=handles.Model(md).Input(ad).nrObservationPoints;
k=0;
for i=1:length(m)
    nm=deblank(name(i,:));
    ii=strmatch(nm,handles.Model(md).Input(ad).observationPointNames,'exact');
    if isempty(ii)
        k=k+1;
        handles.Model(md).Input(ad).observationPoints(k).name=nm;
        handles.Model(md).Input(ad).observationPoints(k).M=m(i);
        handles.Model(md).Input(ad).observationPoints(k).N=n(i);
        handles.Model(md).Input(ad).observationPoints(k).x=handles.Model(md).Input(ad).gridXZ(m(i),n(i));
        handles.Model(md).Input(ad).observationPoints(k).y=handles.Model(md).Input(ad).gridYZ(m(i),n(i));
        handles.Model(md).Input(ad).observationPointNames{k}=handles.Model(md).Input(ad).observationPoints(k).name;
    end
end
delete('nesthd1.inp');
try
    delete('ddtemp.obs');
end
handles.Model(md).Input(ad).nrObservationPoints=length(handles.Model(md).Input(ad).observationPoints);

handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints','domain',ad,'visible',1,'active',0);

setHandles(handles);

