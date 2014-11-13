function FileName = xb_write_sh_scripts_multiple(varargin)
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
    'name',         ['xb_' datestr(now, 'YYYYmmddHHMMSS')], ...
    'scriptNr',     [],                                     ...
    'cluster',      'h5',                                   ...
    'rundirLocal',  '',                                     ...
    'rundir',       '',                                     ...
    'subdirs',      '',                                     ...
    'version',      1.21,                                   ...
    'nodes',        1,                                      ...
    'queuetype',    'normal-i7'                             ...
    );

OPT = setproperty(OPT, varargin{:});

%% write mpi script
FileName = ['mpi' num2str(OPT.scriptNr) '.sh'];
fid = fopen(fullfile(OPT.rundirLocal, FileName), 'w');

fprintf(fid,'#!/bin/sh\n');
fprintf(fid,'#$ -cwd\n');
fprintf(fid,'#$ -N %s\n\n', OPT.name);

% when using h5, only the mpi.sh script is created
fprintf(fid,'module load gcc/4.9.1\n');
fprintf(fid,'module load hdf5/1.8.13_gcc_4.9.1\n');
fprintf(fid,'module load netcdf/v4.3.2_v4.4.0_gcc_4.9.1\n');

switch OPT.version
    % Define seperate cases for all different available versions
    case 1.21
        fprintf(fid,'module load xbeach/xbeach121-gcc44-netcdf41-mpi10\n\n');
    case 'wtisettings'
        fprintf(fid,'module load /u/bieman/privatemodules/xbeach-wtisettings_gcc_4.9.1_1.8.1_HEAD\n\n');
end

fprintf(fid,'rundir="%s"\n',OPT.rundir);
strs = '%s %s %s %s ';
subdirsstr = ['subdirs="' strs(1:(3*numel(OPT.subdirs))) '"\n\n'];
fprintf(fid,subdirsstr,OPT.subdirs{:});
fprintf(fid,'for i in $subdirs\n');
fprintf(fid,'do\n');
fprintf(fid,'    cd $rundir/$i\n');
fprintf(fid,'    pwd\n');
fprintf(fid,'    xbeach > xb.log &\n');
fprintf(fid,'    cd $OLDPWD\n');
fprintf(fid,'done\n');
fprintf(fid,'wait\n');

fclose(fid);