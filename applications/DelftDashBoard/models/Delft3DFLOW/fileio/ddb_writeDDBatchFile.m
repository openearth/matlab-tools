function ddb_writeDDBatchFile(ddfile)
%DDB_WRITEDDBATCHFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_writeDDBatchFile(ddfile)
%
%   Input:
%   ddfile =
%
%
%
%
%   Example
%   ddb_writeDDBatchFile
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
fid = fopen('batch_flw_dd.bat','wt');

if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\deltares_hydro.exe'],'file')
    
    fprintf(fid,'%s\n','@ echo off');
    fprintf(fid,'%s\n','set argfile=config_flow2d3d_dd.ini');
    fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
    fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
    fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
    fclose(fid);
    
    % Write config file
    fini=fopen('config_flow2d3d_dd.ini','w');
    fprintf(fini,'%s\n','[FileInformation]');
    fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
    fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
    fprintf(fini,'%s\n','   FileVersion      = 00.01');
    fprintf(fini,'%s\n','[Component]');
    fprintf(fini,'%s\n','   Name                = flow2d3d');
    fprintf(fini,'%s\n',['   DDBfile             = ' ddfile]);
    fclose(fini);
    
else
    
    if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\trisim.exe'],'file')
    elseif exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\delftflow.exe'],'file')
        fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
        fprintf(fid,'%s\n','set argfile=delft3d-flow_args.txt');
        fprintf(fid,'%s\n',['echo -c ' ddfile ' >%argfile%']);
        fprintf(fid,'%s\n','%exedir%\delftflow.exe %argfile% dummy delft3d');
    end
    
end

