function ddb_Delft3DWAVE_writeBatchFile(mdwfile)
%DDB_DELFT3DWAVE_WRITEBATCHFILE  Writes Delft3D-WAVE stand-alone batch file

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

fid=fopen('batch_wave.bat','w');

% if ~isempty(getenv('D3D_HOME'))
%     exedir=[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\'];
% else
%     exedir='c:\delft3d\w32\wave\bin\';
% end


fprintf(fid,'%s\n',['set waveexedir="' handles.model.delft3dwave.exedir '"']);
fprintf(fid,'%s\n',['%waveexedir%\wave.exe ' mdwfile ' 1']);


% fprintf(fid,'%s\n','@ echo off');

fclose(fid);
