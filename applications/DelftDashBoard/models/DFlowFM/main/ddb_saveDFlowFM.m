function ddb_saveDFlowFM(opt)
%DDB_SAVEDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveDFlowFM(opt)
%
%   Input:
%   opt =
%
%
%
%
%   Example
%   ddb_saveDFlowFM
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
handles=getHandles;

switch lower(opt)
    case{'save'}
        inp=handles.Model(md).Input(ad);
        if ~isfield(handles.Model(md).Input(ad),'mduFile')
            handles.Model(md).Input(ad).mduFile=[handles.Model(md).Input(ad).runid '.mdu'];
        end
        ddb_saveMDU(handles.Model(md).Input(ad).mduFile,inp);
    case{'saveas'}
        [filename, pathname, filterindex] = uiputfile('*.mdf', 'Select MDU File','');
        if pathname~=0
            curdir=[lower(cd) '\'];
            if ~strcmpi(curdir,pathname)
                filename=[pathname filename];
            end
            ii=findstr(filename,'.mdu');
            handles.Model(md).Input(ad).runid=filename(1:ii-1);
            handles.Model(md).Input(ad).mduFile=filename;
            handles=ddb_saveMDU(handles,ad);
        end
end

setHandles(handles);

