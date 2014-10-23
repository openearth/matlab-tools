function varargout = xb_write_sh_scripts_multiple(varargin)
%XB_WRITE_SH_SCRIPTS_MULTIPLE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_write_sh_scripts_multiple(varargin)
%
%   Input: For <keyword,value> pairs call xb_write_sh_scripts_multiple() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_write_sh_scripts_multiple
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 20 Oct 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings
OPT = struct( ...
    'name', ['xb_' datestr(now, 'YYYYmmddHHMMSS')], ...
    'cluster', 'h5', ... 
    'binary', '', ...
    'version', 1.21, ...
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
            fprintf(fid,'mpdboot -n $NHOSTS --rsh=/usr/bin/rsh -f $(pwd)/machinefile\n');
            fprintf(fid,'mpirun -np $NSLOTS %s \n', OPT.binary);
            fprintf(fid,'mpdallexit\n');
        else
            fprintf(fid,'%s\n', OPT.binary);
        end
    case 'MPICH2'
        fprintf(fid,'#!/bin/sh\n');
        if OPT.nodes > 1
            fprintf(fid,'#$ -cwd\n');
            fprintf(fid,'#$ -N %s\n', OPT.name);
            fprintf(fid,'#$ -pe distrib %d\n', OPT.nodes);
        else
            fprintf(fid,'#$ -cwd\n');
            fprintf(fid,'#$ -N %s\n', OPT.name);
        end
        
        switch OPT.cluster
            case 'h5'
                % when using h5, only the mpi.sh script is created
                fname = 'mpi.sh';
                fprintf(fid,'module load mpich2-x86_64\n');
                switch OPT.version
                    % Define seperate cases for all different available versions
                    case 1.21
                        fprintf(fid,'module load xbeach/xbeach121-gcc44-netcdf41-mpi10\n');
                end
                fprintf(fid,'module list\n');
                fprintf(fid,'pushd %s\n',rpath);
                fprintf(fid,'. /opt/ge/InitSGE\n');
                fprintf(fid,'awk ''{print $1":"1}'' $PE_HOSTFILE > $(pwd)/machinefile\n');
                fprintf(fid,'mpdboot -n %d -f $(pwd)/machinefile\n',OPT.nodes);
                fprintf(fid,'mpirun -n %d xbeach\n',OPT.nodes*4);
        end
        
        fprintf(fid,'mpdallexit\n');
        
        if strcmpi(OPT.cluster,'h5')
            fprintf(fid,'popd\n');
        end
otherwise
        error(['Unknown MPI type [' OPT.mpitype ']']);
end

fclose(fid);