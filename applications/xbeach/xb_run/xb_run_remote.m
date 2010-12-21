function xb = xb_run_remote(xb, varargin)
%XB_RUN_REMOTE  Runs a XBeach model remote on the H4 cluster
%
%   Writes a XBeach structure to disk, retrieves a XBeach binary file and
%   runs it at a remote location accessed by SSH (by default, H4 cluster).
%   Supports the use of MPI.
%
%   TODO: UNIX SUPPORT
%
%   Syntax:
%   xb_run_remote(xb)
%
%   Input:
%   varargin  = name:       Name of the model run
%               binary:     XBeach binary to use
%               nodes:      Number of nodes to use in MPI mode (1 = no mpi)
%               netcdf:     Flag to use netCDF output (default: false)
%               ssh_host:   Host name of remote computer
%               ssh_user:   Username for remote computer
%               ssh_pass:   Password for remote computer
%               ssh_prompt: Boolean indicating if password prompt should be
%                           used
%               path_local: Local path to the XBeach model
%               path_remote:Path to XBeach model seen from remote computer
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb_run_remote(xb)
%   xb_run_remote(xb, 'path_local', 'u:\', 'path_remote', '~/')
%
%   See also xb_run, xb_get_bin

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
    'ssh_host', 'h4', ...
    'ssh_user', '', ...
    'ssh_pass', '', ...
    'ssh_prompt', false, ...
    'path_local', 'u:\', ...
    'path_remote', '~/' ...
);

OPT = setproperty(OPT, varargin{:});

%% write model

% make model directory
fpath = fullfile(OPT.path_local, OPT.name);

if ~exist(fpath,'dir'); mkdir(fpath); end;
if ~exist(fullfile(fpath, 'bin'),'dir'); mkdir(fullfile(fpath, 'bin')); end;

xb_write_input(fullfile(fpath, 'params.txt'), xb);

rpath = [OPT.path_remote '/' OPT.name];

%% retrieve binary

if isempty(OPT.binary)
    bin_type = 'unix';

    if OPT.nodes > 1
        bin_type = [bin_type ' mpi'];
    end

    if OPT.netcdf
        bin_type = [bin_type ' netcdf'];
    end
    
    OPT.binary = xb_get_bin('type', bin_type);
end

% move downloaded binary to destination directory
if exist(OPT.binary, 'dir') == 7
    copyfile(fullfile(OPT.binary, '*'), fullfile(fpath, 'bin'));
else
    copyfile(OPT.binary, fullfile(fpath, 'bin'));
end

%% write run scripts

% write start script
fid = fopen(fullfile(fpath, 'xbeach.sh'), 'wt');

fprintf(fid,'#!/bin/sh\n');
fprintf(fid,'cd %s\n', rpath);
fprintf(fid,'. /opt/sge/InitSGE\n');
fprintf(fid,'. /opt/intel/fc/10/bin/ifortvars.sh\n');
fprintf(fid,'dos2unix mpi.sh\n');
fprintf(fid,'qsub -V -N %s mpi.sh\n', OPT.name);

fprintf(fid,'exit\n');

fclose(fid);

% write mpi script
fid = fopen(fullfile(fpath, 'mpi.sh'), 'wt');

fprintf(fid,'#!/bin/bash\n');
fprintf(fid,'#$ -cwd\n');
fprintf(fid,'#$ -N %s\n', OPT.name);
fprintf(fid,'#$ -pe distrib %d\n', OPT.nodes);

fprintf(fid,'. /opt/sge/InitSGE\n');
fprintf(fid,'export LD_LIBRARY_PATH=/opt/intel/Compiler/11.0/081/lib/ia32:/opt/netcdf-4.1.1/lib:/opt/hdf5-1.8.5/lib\n');

if OPT.nodes > 1
    fprintf(fid,'export LD_LIBRARY_PATH="/opt/openmpi-1.4.3-gcc/lib/:${LD_LIBRARY_PATH}"\n');
    fprintf(fid,'export PATH="/opt/mpich2/bin/:${PATH}"\n');
    fprintf(fid,'export NSLOTS=`expr $NSLOTS \\* 2`\n');
    fprintf(fid,'awk ''{print $1":"1}'' $PE_HOSTFILE > $(pwd)/machinefile\n');
    fprintf(fid,'awk ''{print $1":"1}'' $PE_HOSTFILE >> $(pwd)/machinefile\n');
    fprintf(fid,'mpdboot -n $NHOSTS --rsh=/usr/bin/rsh -f $(pwd)/machinefile\n');
    fprintf(fid,'mpirun -np $NSLOTS $(pwd)/bin/xbeach >> xbeach.log 2>&1\n');
    fprintf(fid,'mpdallexit\n');
else
    fprintf(fid,'$(pwd)/bin/xbeach >> xbeach.log 2>&1\n');
end

fclose(fid);

%% prompt for password

if OPT.ssh_prompt
    [OPT.ssh_user OPT.ssh_pass] = xb_login;
end

%% run model

if isunix()
    error('Unix support not yet implemented, sorry!'); % TODO
else
    exe_path = fullfile(fileparts(which(mfilename)), 'plink.exe');
    
    cmd = sprintf('%s %s@%s -pw %s "dos2unix %s/xbeach.sh && %s/xbeach.sh"', ...
        exe_path, OPT.ssh_user, OPT.ssh_host, OPT.ssh_pass, rpath, rpath);
end

% [retcode messages] = system(cmd);

% extract job number and name
if retcode == 0
    s = regexp(messages, 'Your job (?<id>\d+) \("(?<name>.+)"\) has been submitted', 'names');

    job_id = str2num(s.id);
    job_name = s.name;
else
    error(['Submitting remote job failed [' cmd ']']);
end

%% create xbeach structure

sub = xb_empty();
sub = xb_set(sub, 'host', OPT.ssh_host, 'user', OPT.ssh_user, 'pass', OPT.ssh_pass);
sub = xb_meta(sub, mfilename, 'host');

xb = xb_empty();
xb = xb_set(xb, ...
    'path', fpath, ...
    'id', job_id, ...
    'name', job_name, ...
    'nodes', OPT.nodes, ...
    'binary', OPT.binary, ...
    'netcdf', OPT.netcdf, ...
    'ssh', sub, ...
    'messages', messages);
xb = xb_meta(xb, mfilename, 'run', fpath);