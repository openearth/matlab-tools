function nc_kickstarter_data_add(ncfile, dims, vars)
%NC_KICKSTARTER_ADDDATA  Adds data previously read to design netCDF file into a netCDF file
%
%   Adds data previously read by the nc_kickstarter_data_read function into
%   the netCDF file that is generated with the help of that read function.
%   It also determines whether dimension bounds variables are available and
%   fill them.
%
%   Syntax:
%   nc_kickstarter_adddata(ncfile, dims, vars)
%
%   Input:
%   ncfile    = Path to netCDF file where data should be added
%   dims      = Structure with dimension data (e.g. struct('x',x,'y',y))
%   vars      = Structure with variable data (e.g. struct('depth',d))
%
%   Output:
%   none
%
%   Example
%   nc_kickstarter_adddata(ncfile, dims, vars)
%
%   See also nc_kickstarter_data_read, nc_kickstarter

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 27 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% add dims and vars

if exist(ncfile, 'file')
    
    % add dims
    f = fieldnames(dims);
    for i = 1:length(f)
        if nc_isvar(ncfile,f{i})
            nc_varput(ncfile,f{i},dims.(f{i}));
        end
        
        % add bounds
        bnd = [f{i} '_bounds'];
        if nc_isvar(ncfile,bnd) && numel(dims.(f{i})) > 1
            nc_varput(ncfile,bnd,nc_cf_cor2bounds(dims.(f{i})));
        end
    end
    
    % add vars
    f = fieldnames(vars);
    for i = 1:length(f)
        if nc_isvar(ncfile,f{i})
            nc_varput(ncfile,f{i},vars.(f{i}));
        end
    end
else
    error('File does not exist [%s]',ncfile);
end