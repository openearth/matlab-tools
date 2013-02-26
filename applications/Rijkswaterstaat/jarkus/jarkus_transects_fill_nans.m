function jarkus_transects_fill_nans(ncfile, varargin)
%JARKUS_TRANSECTS_FILL_NANS  Fill nan-values in jarkus transects with surrounding data and write to netcdf.
%
%   Fill nan-values as much as possible with surrounding data. (1)
%   interpolate linear in cross-shore direction; (2) interpolate linear in
%   time; (3) extrapolate with nearest neighbour method in time.
%   The resulting data is written to the (source) netcdf file, which thus
%   should be a local file.
%   The min and max cross-shore and altitude measurements variables
%   are updated as well.
%
%   Syntax:
%   jarkus_transects_fill_nans(varargin)
%
%   Input: 
%   ncfile  = path to local ncfile
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_transects_fill_nans
%
%   See also jarkus_interpolatenans

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl
%
%       Deltares
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
% Created: 25 Feb 2013
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% read available transect id's
trh = jarkus_transects(...
    'output', {'id'},...
    'url', ncfile);

multiWaitbar('Interpolating transects',0)

for idx = 1:length(trh.id)
    % loop over all id's
    id = trh.id(idx);
    tr = jarkus_transects('id', id, 'url', ncfile);
    % interpolate in cross-shore direction
    tric = jarkus_interpolatenans(tr);
    % interpolate in time
    trit0 = jarkus_interpolatenans(tric,...
        'interp', 'time',...
        'dim', 1);
    % extrapolate in time with nearest neighbour method
    trit1 = jarkus_interpolatenans(trit0,...
        'interp', 'time',...
        'dim', 1,...
        'method', 'nearest',...
        'extrap', true);
    % update min and max cross-shore measurement
    nnid = mat2cell(~isnan(squeeze(trit1.altitude)), ones(size(trit1.time)), length(trit1.cross_shore));
    [mincsm, maxcsm] = cellfun(@(x) deal(min(trit1.cross_shore(x)), max(trit1.cross_shore(x))), nnid);
    % update min and max altitude measurement
    minz = nanmin(squeeze(trit1.altitude),2);
    maxz = nanmax(squeeze(trit1.altitude),2);

    % write to netcdf file
    nc_varput(ncfile, 'altitude', trit1.altitude, [1 idx 1]-1)
    nc_varput(ncfile, 'min_cross_shore_measurement', mincsm, [1 idx]-1);
    nc_varput(ncfile, 'max_cross_shore_measurement', maxcsm, [1 idx]-1);
    nc_varput(ncfile, 'min_altitude_measurement', minz, [1 idx]-1);
    nc_varput(ncfile, 'max_altitude_measurement', maxz, [1 idx]-1);
    
    multiWaitbar('Interpolating transects', idx/length(trh.id),...
        'label', sprintf('Interpolating transects; transect %i', tr.id));
end

%% put info about the modifications in the history
D = dir(ncfile);
timestr = datestr(D.datenum, 'ddd mmm dd hh:MM:SS yyyy');
histstr = nc_attget(ncfile, nc_global, 'history');
nc_attput(ncfile, nc_global, 'history', sprintf('%s: %s applied; %s\n%s', timestr, '$Id$', 'NaN values successively  (1) cross-shore linear interpolated, (2) linear interpolated in time and (3) nearest neighbour extrapolated in time', histstr));