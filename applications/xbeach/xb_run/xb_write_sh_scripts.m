function fname = xb_write_sh_scripts(lpath, rpath, varargin)
%XB_WRITE_SH_SCRIPTS  Writes SH scripts to run applications on H4 cluster using MPI
%
%   Writes SH scripts to run applications on H4 cluster. Optionally
%   includes statements to run applications using MPI.
%
%   Syntax:
%   fname = xb_write_sh_scripts(lpath, rpath, varargin)
%
%   Input:
%   lpath     = Local path to store scripts
%   rpath     = Path to store scripts seen from h$ cluster
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
    'binary', '', ...
    'nodes', 1, ...
    'queuetype', 'normal', ...
    'mpitype', '' ...
);

OPT = setproperty(OPT, varargin{:});

[fdir name fext] = fileparts(OPT.binary);

% make slashes unix compatible
OPT.binary = strrep(OPT.binary, '\', '/');

% set preferences
if isempty(OPT.mpitype); OPT.mpitype = xb_getprefdef('mpitype', 'MPICH2'); end;

%% write start script

fname = [name '.sh'];

fid = fopen(fullfile(lpath, fname), 'w');

fprintf(fid,'#!/bin/sh\n');
fprintf(fid,'cd %s\n', rpath);
fprintf(fid,'. /opt/sge/InitSGE\n');
fprintf(fid,'. /opt/intel/fc/10/bin/ifortvars.sh\n');
% fprintf(fid,'dos2unix mpi.sh\n');
if strcmp(OPT.queuetype,'normal')
    fprintf(fid,'qsub -V -N %s mpi.sh\n', OPT.name);
elseif strcmp(OPT.queuetype,'normal-i7')
    fprintf(fid,'qsub -V -N %s -q normal-i7 mpi.sh\n', OPT.name);
else
    error(['Unknown queue type [' OPT.mpitype ']. Possible types are: normal & normal-i7']);
end

fprintf(fid,'exit\n');

fclose(fid);

%% write mpi script

if ~ismember(OPT.binary(1), {'/' '~' '$'})
    OPT.binary = ['$(pwd)/' OPT.binary];
end

fid = fopen(fullfile(lpath, 'mpi.sh'), 'w');

switch upper(OPT.mpitype)
    case 'OPENMPI'
        fprintf(fid,'#!/bin/bash\n');
        fprintf(fid,'#$ -cwd\n');
        fprintf(fid,'#$ -N %s\n', OPT.name);
        fprintf(fid,'#$ -pe distrib %d\n', OPT.nodes);

        fprintf(fid,'. /opt/sge/InitSGE\n');
        fprintf(fid,'export LD_LIBRARY_PATH=/opt/intel/Compiler/11.0/081/lib/ia32:/opt/netcdf-4.1.1/lib:/opt/hdf5-1.8.5/lib:$LD_LIBRARY_PATH\n');

        if OPT.nodes > 1
            fprintf(fid,'export LD_LIBRARY_PATH="/opt/openmpi-1.4.3-gcc/lib/:${LD_LIBRARY_PATH}"\n');
            fprintf(fid,'export PATH="/opt/mpich2/bin/:${PATH}"\n');
            if strcmp(OPT.queuetype,'normal')
                fprintf(fid,'export NSLOTS=`expr $NSLOTS \\* 2`\n');
            elseif strcmp(OPT.queuetype,'normal-i7')
                fprintf(fid,'export NSLOTS=`expr $NSLOTS \\* 4`\n');
            else
                error(['Unknown queue type [' OPT.mpitype ']. Possible types are: normal & normal-i7']);
            end
            fprintf(fid,'awk ''{print $1":"1}'' $PE_HOSTFILE > $(pwd)/machinefile\n');
            %fprintf(fid,'awk ''{print $1":"1}'' $PE_HOSTFILE >> $(pwd)/machinefile\n');
            fprintf(fid,'mpdboot -n $NHOSTS --rsh=/usr/bin/rsh -f $(pwd)/machinefile\n');
            fprintf(fid,'mpirun -np $NSLOTS %s >> %s.log 2>&1\n', OPT.binary, name);
            fprintf(fid,'mpdallexit\n');
        else
            fprintf(fid,'%s >> %s.log 2>&1\n', OPT.binary, name);
        end
    case 'MPICH2'
        fprintf(fid,'#!/bin/sh\n');
        if OPT.nodes > 1
            fprintf(fid,'#$ -cwd\n');
            fprintf(fid,'#$ -N %s\n', OPT.name);
            fprintf(fid,'#$ -pe mpich2 %d\n', OPT.nodes);
        end
        
        fprintf(fid,'. /opt/sge/InitSGE\n');
        fprintf(fid,'export LD_LIBRARY_PATH=/opt/intel/Compiler/11.0/081/lib/ia32:/opt/netcdf-4.1.1/lib:/opt/hdf5-1.8.5/lib:$LD_LIBRARY_PATH\n');

        if OPT.nodes > 1
            fprintf(fid,'export MPICH2_ROOT=/opt/mpich2\n');
            fprintf(fid,'export PATH=$MPICH2_ROOT/bin:$PATH\n');
            fprintf(fid,'export MPD_CON_EXT="sge_$JOB_ID.$SGE_TASK_ID"\n');

            fprintf(fid,'mpirun -machinefile $TMPDIR/machines -n $NSLOTS %s >> %s.log\n', OPT.binary, name);
        else
            fprintf(fid,'%s >> %s.log 2>&1\n', OPT.binary, name);
        end
otherwise
        error(['Unknown MPI type [' OPT.mpitype ']']);
end

fclose(fid);