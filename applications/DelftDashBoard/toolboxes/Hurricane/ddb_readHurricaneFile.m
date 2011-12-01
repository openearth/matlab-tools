function handles = ddb_readHurricaneFile(handles, filename)
%DDB_READHURRICANEFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_readHurricaneFile(handles, filename)
%
%   Input:
%   handles  =
%   filename =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_readHurricaneFile
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
txt=ReadTextFile(filename);
npoi = 0;

handles.Toolbox(tb).Input.name='';

for i=1:length(txt)
    switch(lower(txt{i})),
        case{'name'}
            handles.Toolbox(tb).Input.name=txt{i+1};
        case{'inputoption'}
            handles.Toolbox(tb).Input.holland=str2double(txt{i+1});
        case{'initialeyespeed'}
            handles.Toolbox(tb).Input.initSpeed=str2double(txt{i+1});
        case{'initialeyedir'}
            handles.Toolbox(tb).Input.initDir=str2double(txt{i+1});
        case{'trackdata'}
            npoi=npoi+1;
            dat=txt{i+1};
            tim=txt{i+2};
            handles.Toolbox(tb).Input.date(npoi)=datenum([dat tim],'yyyymmddHHMMSS');
            handles.Toolbox(tb).Input.trY(npoi) =str2double(txt{i+3});
            handles.Toolbox(tb).Input.trX(npoi) =str2double(txt{i+4});
            handles.Toolbox(tb).Input.par1(npoi)=str2double(txt{i+5});
            handles.Toolbox(tb).Input.par2(npoi)=str2double(txt{i+6});
    end
end
handles.Toolbox(tb).Input.nrPoint=npoi;

