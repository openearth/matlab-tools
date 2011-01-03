function xb = xb_run(xb, varargin)
%XB_RUN  Runs a XBeach model locally
%
%   Writes a XBeach structure to disk, retrieves a XBeach binary file and
%   runs it at a certain location. Supports the use of MPI using MPICH2.
%
%   TODO: MPI support
% 
%   Syntax:
%   xb_run(xb)
%
%   Input:
%   xb        = XBeach input structure
%   varargin  = binary:     XBeach binary to use
%               nodes:      Number of nodes to use in MPI mode (1 = no mpi)
%               netcdf:     Flag to use netCDF output (default: false)
%               path:       Path to the XBeach model
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb_run(xb)
%   xb_run(xb, 'path', 'path_to_model/')
%
%   See also xb_run_remote, xb_get_bin

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
    'name', ['xb_' datestr(now, 'YYYYmmddHHMMSS')], ...
    'binary', '', ...
    'nodes', 1, ...
    'netcdf', false, ...
    'path', '.' ...
);

OPT = setproperty(OPT, varargin{:});

%% write model

fpath = fullfile(OPT.path, 'params.txt');

xb_write_input(fpath, xb);

%% retrieve binary

if isempty(OPT.binary)
    if isunix()
        bin_type = 'unix';
    else
        bin_type = 'win32';
    end

    if OPT.nodes > 1
        bin_type = [bin_type ' mpi'];
    end

    if OPT.netcdf
        bin_type = [bin_type ' netcdf'];
    end
    
    OPT.binary = xb_get_bin('type', bin_type);
end

%% run model

if isunix()
    if OPT.nodes > 1
        error('MPI support is not yet implemented, sorry!'); % TODO
    else
        % start xbeach
        [r messages] = system(['cd ' OPT.path ' && ' OPT.binary]);
        
        % get current running xbeach instances
        [r tasklist] = system(['ps | grep -i xbeach$']);
        re = regexp(tasklist, '\n(?<pid>\d+)\s+', 'names');
        pids = cellfun(@str2num, {re.pid});
        
        % determine new instance
        pid = pids(end);
    end
else
    if OPT.nodes > 1
        apps = get_app_list;
        
        if any(strfilter(apps, '*MPICH2*'))
            error('MPICH2 installed, but not supported yet');
        elseif any(strfilter(apps, '*OpenMI*'))
            error('OpenMI installed, but not supported yet');
        else
            error('No supported MPI application installed');
        end
    else
        % start xbeach
        [r messages] = system(['cd ' OPT.path ' && start ' OPT.binary]);
        
        % get current running xbeach instances
        [r tasklist] = system('tasklist /FI "IMAGENAME eq xbeach.exe"');
        re = regexp(tasklist, 'xbeach.exe\s+(?<pid>\d+)', 'names');
        pids = cellfun(@str2num, {re.pid});
        
        % determine new instance
        if ~isempty(pids)
            pid = pids(end);
        else
            pid = 0;
        end
    end
end

%% create xbeach structure

xb = xb_empty();
xb = xb_set(xb, ...
    'path', abspath(fpath), ...
    'id', pid, ...
    'name', OPT.name, ...
    'nodes', OPT.nodes, ...
    'binary', OPT.binary, ...
    'netcdf', OPT.netcdf, ...
    'messages', messages);
xb = xb_meta(xb, mfilename, 'run', OPT.path);