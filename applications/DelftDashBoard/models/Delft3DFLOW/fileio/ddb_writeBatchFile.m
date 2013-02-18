function ddb_writeBatchFile(runid,varargin)
%DDB_WRITEBATCHFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_writeBatchFile(runid)
%
%   Input:
%   runid =
%
%
%
%
%   Example
%   ddb_writeBatchFile
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

mdwfile=[];
fname='batch_flow.bat';
for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'mdwfile'}
                mdwfile=varargin{ii+1};
                fname='batch_flow_wave.bat';
        end
    end
end

fid=fopen(fname,'w');

if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\d_hydro.exe'],'file')

    % New open-source version
    fprintf(fid,'%s\n','@ echo off');
    fprintf(fid,'%s\n','set argfile=config_flow2d3d.xml');
    fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
    fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
    
    if ~isempty(mdwfile)
        fprintf(fid,'%s\n','start %exedir%\d_hydro.exe %argfile%');
        fprintf(fid,'%s\n',[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\wave.exe ' mdwfile ' 1']);
    else
        fprintf(fid,'%s\n','%exedir%\d_hydro.exe %argfile%');
    end

    
    % Write xml config file
    fini=fopen('config_flow2d3d.xml','w');
    fprintf(fini,'%s\n','<?xml version=''1.0'' encoding=''iso-8859-1''?>');
    fprintf(fini,'%s\n','<DeltaresHydro start="flow2d3d">');
    fprintf(fini,'%s\n',['<flow2d3d MDFile = ''' runid '.mdf''></flow2d3d>']);
    fprintf(fini,'%s\n','</DeltaresHydro>');
    fclose(fini);

    % Write old config file
    fini=fopen('config_flow2d3d.ini','w');
    fprintf(fini,'%s\n','[FileInformation]');
    fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
    fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
    fprintf(fini,'%s\n','   FileVersion      = 00.01');
    fprintf(fini,'%s\n','[Component]');
    fprintf(fini,'%s\n','   Name                = flow2d3d');
    fprintf(fini,'%s\n',['   MDFfile             = ' runid]);
    fclose(fini);
    
elseif exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\deltares_hydro.exe'],'file')
    
    % New open-source version
    fprintf(fid,'%s\n','@ echo off');
    fprintf(fid,'%s\n','set argfile=config_flow2d3d.ini');
    fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
    fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
    
    if ~isempty(mdwfile)
        fprintf(fid,'%s\n','start %exedir%\deltares_hydro.exe %argfile%');
        fprintf(fid,'%s\n',[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\wave.exe ' mdwfile ' 1']);
    else
        fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
    end
    
    % Write config file
    fini=fopen('config_flow2d3d.ini','w');
    fprintf(fini,'%s\n','[FileInformation]');
    fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
    fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
    fprintf(fini,'%s\n','   FileVersion      = 00.01');
    fprintf(fini,'%s\n','[Component]');
    fprintf(fini,'%s\n','   Name                = flow2d3d');
    fprintf(fini,'%s\n',['   MDFfile             = ' runid]);
    fclose(fini);
    
else
    if exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\trisim.exe'],'file')
        fprintf(fid,'%s\n',['echo ' runid ' > runid ']);
        fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\tdatom.exe');
        fprintf(fid,'%s\n','%D3D_HOME%\%ARCH%\flow\bin\trisim.exe');
    elseif exist([getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\delftflow.exe'],'file')
        fprintf(fid,'%s\n',['set runid=' runid]);
        fprintf(fid,'%s\n',['set exedir=' getenv('D3D_HOME') '\' getenv('ARCH') '\flow\bin\']);
        fprintf(fid,'%s\n','set argfile=delft3d-flow_args.txt');
        fprintf(fid,'%s\n','echo -r %runid% >%argfile%');
        fprintf(fid,'%s\n','%exedir%\delftflow.exe %argfile% dummy delft3d');
        if ~isempty(mdwfile)
            fprintf(fid,'%s\n','start %exedir%\delftflow.exe %argfile% dummy delft3d');
            fprintf(fid,'%s\n',[getenv('D3D_HOME') '\' getenv('ARCH') '\wave\bin\wave.exe ' mdwfile ' 1']);
        else
            fprintf(fid,'%s\n','%exedir%\delftflow.exe %argfile% dummy delft3d');
        end
    else
        
        % Assume new open source version sits in c:\delft3d\w32\flow\bin\
        fprintf(fid,'%s\n','@ echo off');
        fprintf(fid,'%s\n','set argfile=config_flow2d3d.ini');
        fprintf(fid,'%s\n',['set exedir=c:\delft3d\w32\flow\bin\']);
        fprintf(fid,'%s\n','set PATH=%exedir%;%PATH%');
        if ~isempty(mdwfile)
            fprintf(fid,'%s\n','start %exedir%\deltares_hydro.exe %argfile%');
            fprintf(fid,'%s\n',['c:\delft3d\w32\flow\bin\wave\bin\wave.exe ' mdwfile ' 1']);
        else
            fprintf(fid,'%s\n','%exedir%\deltares_hydro.exe %argfile%');
        end
        
        % Write config file
        fini=fopen('config_flow2d3d.ini','w');
        fprintf(fini,'%s\n','[FileInformation]');
        fprintf(fini,'%s\n',['   FileCreatedBy    = ' getenv('USERNAME')]);
        fprintf(fini,'%s\n',['   FileCreationDate = ' datestr(now)]);
        fprintf(fini,'%s\n','   FileVersion      = 00.01');
        fprintf(fini,'%s\n','[Component]');
        fprintf(fini,'%s\n','   Name                = flow2d3d');
        fprintf(fini,'%s\n',['   MDFfile             = ' runid]);
        fclose(fini);
        
    end
end

fclose(fid);

