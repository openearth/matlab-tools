function fname = xb_write_sh_scripts(lpath, rpath, varargin)
%XB_WRITE_SH_SCRIPTS  Writes SH scripts to run applications on H5 cluster using MPI
%
%   Writes SH scripts to run applications on H5 cluster. Optionally
%   includes statements to run applications using MPI.
%
%   Syntax:
%   fname = xb_write_sh_scripts(lpath, rpath, varargin)
%
%   Input:
%   lpath     = Local path to store scripts
%   rpath     = Path to store scripts seen from H4/H5 cluster
%   varargin  = name:       Name of the run
%               binary:     Binary to use
%               nodes:      Number of nodes to use (1 = no MPI)
%               mpitype:    Type of MPI application (MPICH2/OpenMPI)
%
%   Output:
%   fname     = Name of start script
%
%   Preferences:
%   mpitype   = Type of MPI application (MPICH2/OpenMPI)
%
%               Preferences overwrite default options (not explicitly
%               defined options) and can be set and retrieved using the
%               xb_setpref and xb_getpref functions.
%
%   Example
%   fname = xb_write_sh_scripts(lpath, rpath, 'binary', 'bin/xbeach')
%   fname = xb_write_sh_scripts(lpath, rpath, 'binary', 'bin/xbeach', 'nodes', 4)
%
%   See also xb_run_remote

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 10 Feb 2011
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
    'cluster', 'h5', ... 
    'binary', '', ...
    'version', 'trunk', ...
    'nodes', 1, ...
    'queuetype', 'normal-i7', ...
    'mpitype', '' ...
);

OPT = setproperty(OPT, varargin{:});

[fdir, name, fext] = fileparts(OPT.binary);

% make slashes unix compatible
OPT.binary = strrep(OPT.binary, '\', '/');

% set preferences
if isempty(OPT.mpitype); OPT.mpitype = xb_getprefdef('mpitype', 'MPICH2'); end;

%% write mpi script
fname = 'mpi.sh';

if strcmpi(OPT.cluster,'h4') && ~ismember(OPT.binary(1), {'/' '~' '$'})
    OPT.binary = ['$(pwd)/' OPT.binary];
end

fid = fopen(fullfile(lpath, 'mpi.sh'), 'w');

switch upper(OPT.mpitype)
    case 'OPENMPI'
        fprintf(fid,'#!/bin/sh\n');
        fprintf(fid,'#$ -cwd\n');
        fprintf(fid,'#$ -j yes\n');
        fprintf(fid,'#$ -V\n');
        fprintf(fid,'#$ -N %s\n', OPT.name);
        fprintf(fid,'#$ -m ea\n');
        fprintf(fid,'#$ -q %s\n', OPT.queuetype);
        fprintf(fid,'#$ -pe distrib %d\n\n', OPT.nodes);
        
        switch OPT.cluster
            case 'h5'                
                fprintf(fid,'hostFile="$JOB_NAME.h$JOB_ID"\n\n');
                fprintf(fid,'cat $PE_HOSTFILE | while read line; do\n');
                fprintf(fid,'   echo $line | awk ''{print $1 " slots=" $4}''\n');
                fprintf(fid,'done > $hostFile\n\n');
                xb_write_sh_scripts_xbversions(fid, 'version', OPT.version)
                fprintf(fid,'mpirun -report-bindings -np %d -map-by core -hostfile $hostFile xbeach\n\n', (OPT.nodes*4+1));
                fprintf(fid,'rm -f $hostFile\n');
        end
        fprintf(fid,'mpdallexit\n');
otherwise
        error(['Unknown MPI type [' OPT.mpitype ']']);
end

fclose(fid);
end