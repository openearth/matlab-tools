function ddb_saveOMSModel(handles)
%DDB_SAVEOMSMODEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_saveOMSModel(handles)
%
%   Input:
%   handles =
%
%
%
%
%   Example
%   ddb_saveOMSModel
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

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
dr=[handles.Toolbox(tb).Directory '\'];

if ~exist([dr handles.Toolbox(tb).ShortName],'dir')
    mkdir(dr,handles.Toolbox(tb).ShortName);
end

dr=[dr handles.Toolbox(tb).ShortName '\'];

if ~exist([dr 'input'],'dir')
    mkdir(dr,'input');
end
if ~exist([dr 'nesting'],'dir')
    mkdir(dr,'nesting');
end
if ~exist([dr 'lastrun'],'dir')
    mkdir(dr,'lastrun');
end
if ~exist([dr 'archive'],'dir')
    mkdir(dr,'archive');
end
if ~exist([dr 'restart'],'dir')
    mkdir(dr,'restart');
end

ddb_saveOMSModelData(handles);

ddb_saveMDFOMS(handles,ad);

if handles.Model(md).Input(ad).Waves
    ddb_saveMDWOMS(handles);
end

inpdir=[dr 'input\'];

name=handles.Toolbox(tb).ShortName;
% try
%     copyfile([handles.Toolbox(tb).Runid '.mdf'],inpdir);
% end
% try
%     copyfile([handles.Toolbox(tb).Runid '.mdw'],inpdir);
% end

extensions={'bnd','bch','bca','grd','enc','dep','dry','thd','ini'};

for i=1:length(extensions)
    try
        copyfile([name '.' extensions{i}],inpdir);
    end
end

if handles.Model(md).Input(ad).Waves
    ddb_writeDioConfig(inpdir);
end

if handles.Model(md).Input(ad).Wind
    fid=fopen([inpdir 'dummy.wnd'],'wt');
    fprintf(fid,'%s\n',' 0.0000000e+000  0.0000000e+000  0.0000000e+000');
    fprintf(fid,'%s\n',' 2.0000000e+006  0.0000000e+000  0.0000000e+000');
    fclose(fid);
end

