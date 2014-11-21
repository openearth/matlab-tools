function xb_write_sh_scripts_xbversions(FileID, varargin)
%XB_WRITE_SH_SCRIPTS_XBVERSIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_write_sh_scripts_xbversions(varargin)
%
%   Input: For <keyword,value> pairs call xb_write_sh_scripts_xbversions() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_write_sh_scripts_xbversions
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
% Created: 21 Nov 2014
% Created with Matlab version: 8.4.0.150421 (R2014b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Settings
OPT = struct( ...
    'version',      1.21    ...
    );

OPT = setproperty(OPT, varargin{:});

%% write version specifics to sh script

switch OPT.version
    % Define seperate cases for all different available versions
    case 1.21
        % XBeach v1.21 Groundhog Day release
        fprintf(FileID,'module load gcc/4.9.1\n');
        fprintf(FileID,'module load hdf5/1.8.13_gcc_4.9.1\n');
        fprintf(FileID,'module load netcdf/v4.3.2_v4.4.0_gcc_4.9.1\n');
        fprintf(FileID,'module load /opt/xbeach/openmpi/1.8.1_gcc_4.9.1\n');
        fprintf(FileID,'module load /u/bieman/privatemodules/xbeach-groundhogday_gcc_4.9.1_1.8.1_HEAD\n\n');
    case 1.20
        % XBeach v1.20 Sinterklaas release
        fprintf(FileID,'module load gcc/4.9.1\n');
        fprintf(FileID,'module load hdf5/1.8.13_gcc_4.9.1\n');
        fprintf(FileID,'module load netcdf/v4.3.2_v4.4.0_gcc_4.9.1\n');
        fprintf(FileID,'module load /opt/xbeach/openmpi/1.8.1_gcc_4.9.1\n');
        fprintf(FileID,'module load /u/bieman/privatemodules/xbeach-sinterklaas_gcc_4.9.1_1.8.1_HEAD\n\n');
    case 1.19
        % XBeach v1.19 Easter release
        fprintf(FileID,'module load gcc/4.9.1\n');
        fprintf(FileID,'module load hdf5/1.8.13_gcc_4.9.1\n');
        fprintf(FileID,'module load netcdf/v4.3.2_v4.4.0_gcc_4.9.1\n');
        fprintf(FileID,'module load /opt/xbeach/openmpi/1.8.1_gcc_4.9.1\n');
        fprintf(FileID,'module load /u/bieman/privatemodules/xbeach-easter_gcc_4.9.1_1.8.1_HEAD\n\n');
    case 'groundhogday_old'
        fprintf(FileID,'module load mpich2-x86_64\n');
        fprintf(FileID,'module load xbeach/xbeach121-gcc44-netcdf41-mpi10\n\n');
    case 'wtisettings'
        fprintf(FileID,'module load gcc/4.9.1\n');
        fprintf(FileID,'module load hdf5/1.8.13_gcc_4.9.1\n');
        fprintf(FileID,'module load netcdf/v4.3.2_v4.4.0_gcc_4.9.1\n');
        fprintf(FileID,'module load /opt/xbeach/openmpi/1.8.1_gcc_4.9.1\n');
        fprintf(FileID,'module load /u/bieman/privatemodules/xbeach-wtisettings_gcc_4.9.1_1.8.1_HEAD\n\n');
    otherwise
        % assume that OPT.version contains the complete
        % module name
        fprintf(FileID,'module load gcc/4.9.1\n');
        fprintf(FileID,'module load hdf5/1.8.13_gcc_4.9.1\n');
        fprintf(FileID,'module load netcdf/v4.3.2_v4.4.0_gcc_4.9.1\n');
        fprintf(FileID,'module load /opt/xbeach/openmpi/1.8.1_gcc_4.9.1\n');
        fprintf(FileID,'module load %s\n\n',OPT.version);
end