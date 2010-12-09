function fpath = xb_get_bin(varargin)
%XB_GET_BIN  Retrieves a XBeach binary from a remote source
%
%   Retrieves a XBeach binary from a remote source. By default this is the
%   latest binary from the TeamCity build server. Several flavours of
%   binaries exist. By default the normal win32 binary is downloaded. A
%   custom host can be provided as well. Returns the location where the
%   downloaded binary can be found.
%
%   WARNING: SOME BINARY TYPES ARE STILL MISSING, SINCE NOT AVAILABLE IN
%   TEAMCITY YET
%
%   Syntax:
%   fpath = xb_get_bin(varargin)
%
%   Input:
%   varargin  = type:       Type of binary (win32/unix/mpi/netcdf).
%                           Multiple qualifiers separated by a space can be
%                           used. Specifying "custom" will use the host
%                           provided in the equally named varargin
%                           parameter.
%               host:       Host to be used in case of custom type.
%
%   Output:
%   fpath     = Path to downloaded executable
%
%   Example
%   fpath = xb_get_bin()
%   fpath = xb_get_bin('type', 'win32 mpi')
%   fpath = xb_get_bin('type', 'win32 netcdf')
%   fpath = xb_get_bin('type', 'win32 netcdf mpi')
%   fpath = xb_get_bin('type', 'unix netcdf mpi')
%   fpath = xb_get_bin('type', 'custom', 'host', ' ... ')
%
%   See also xb_run

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'type', 'win32', ...
    'host', '' ...
);

OPT = setproperty(OPT, varargin{:});

OPT.type = regexp(OPT.type, '\s+', 'split');

%% define default hosts

hosts = struct( ...
    'win32', 'https://build.deltares.nl/guestAuth/repository/downloadAll/bt147/.lastSuccessful/exe/artifacts.zip', ...
    'win32_mpi', 'https://build.deltares.nl/guestAuth/repository/downloadAll/bt155/.lastSuccessful/exe/artifacts.zip', ...
    'win32_mpi_netcdf', '', ...
    'win32_netcdf', 'https://build.deltares.nl/guestAuth/repository/downloadAll/bt204/.lastSuccessful/artifacts.zip', ...
    'unix', '', ...
    'unix_mpi', '', ...
    'unix_mpi_netcdf', '', ...
    'unix_netcdf', '' ...
);

%% determine host

host = '';
if ismember('custom', OPT.type)
    host = OPT.host;
else
    fnames = fieldnames(hosts);
    types = regexp(fnames, '_', 'split');
    for i = 1:length(types)
        if all(ismember(OPT.type, types{i}))
            if ~isempty(hosts.(fnames{i}))
                host = hosts.(fnames{i});
                break;
            end
        end
    end
end

if isempty(host)
    error(['No valid host found [' sprintf(' %s', OPT.type{:}) ' ]']);
end

%% retrieve data

[fhost fname fext] = fileparts(host);

tmpfile = tempname;
fpath = [tmpfile fext];
urlwrite(host, fpath);

% unzip, if zipped
if strcmpi(fext, '.zip')
    fpath = tmpfile;
    
    mkdir(fpath);
    unzip([fpath fext], fpath);
    
    % return exe dir, if it exists
    if exist(fullfile(fpath, 'exe'), 'dir')
        fpath = fullfile(fpath, 'exe');
    end
    
    % return filename if only one file unzipped
    if length(dir(fpath)) == 3
        d = dir(fpath);
        fpath = fullfile(fpath, d(3).name);
    else
        d = dir(fullfile(fpath, 'xbeach*'));
        if ~isempty(d)
            fpath = fullfile(fpath, d(1).name);
        end
    end
end
