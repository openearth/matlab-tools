function xb_run(xb, varargin)
%XB_RUN  Runs a XBeach model locally
%
%   Writes a XBeach structure to disk, retrieves a XBeach binary file and
%   runs it at a certain location. Supports the use of MPI using MPICH2.
%
%   TODO: MPI support
% 
%   Syntax:
%   xb_run()
%
%   Input:
%   varargin  = binary:     XBeach binary to use
%               nodes:      Number of nodes to use in MPI mode (1 = no mpi)
%               netcdf:     Flag to use netCDF output (default: false)
%               path:       Path to the XBeach model
%
%   Output:
%   none
%
%   Example
%   xb_run()
%   xb_run('path', 'path_to_model/')
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
        system(['cd ' OPT.path ' && ' OPT.binary]); % TODO
    else
        system(['cd ' OPT.path ' && ' OPT.binary]);
    end
else
    if OPT.nodes > 1
        system(['cd ' OPT.path ' && start ' OPT.binary]); % TODO
    else
        system(['cd ' OPT.path ' && start ' OPT.binary]);
    end
end
