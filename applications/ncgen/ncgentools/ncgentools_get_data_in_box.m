function [data, netcdf_index, OPT] = ncgentools_get_data_in_box(netcdf_index, varargin)
%NCGENTOOLS_GET_DATA_IN_BOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ncgentools_get_data_in_box(netcdf_index, varargin)
%
%   Input:
%   netcdf_index  = netcdf netcdf_index structire, or a path
%   varargin =
%
%   Example
%   ncgentools_get_data_in_box
%
%     netcdf_index = ncgentools_get_data_in_box('D:\products\nc\rijkswaterstaat\vaklodingen\combined');
%     [data, netcdf_index, OPT] = ncgentools_get_data_in_box(netcdf_index,...
%         'x_range',[-inf inf],...
%         'y_range',[-inf inf],...
%         't_range',[-inf inf],...
%         'x_stride',20,...
%         'y_stride',20);
%   surf(data.x,data.y,data.z)
%   view(2)
%   shading flat
%
%   See also
%      
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%          tda@vanoord.com
%   
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 12 Jun 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT.x_range    = [];
OPT.y_range    = [];
OPT.t_range    = [];
OPT.t_method   = 'last_in_range';
OPT.x_stride   = 1;
OPT.y_stride   = 1;
    
OPT = setproperty(OPT,varargin{:});

if nargin==0;
    data = OPT;
    return;
end
%% error check and initialization

if nargin>1;
    % exit function when the ranges are not specified
    assert(numel(OPT.x_range) == 2 &&  numel(OPT.y_range) == 2 && numel(OPT.t_range) == 2,'x,y and t range must all be specified as two element vectors')
end

% build index if a path is specified
if ischar(netcdf_index)
    netcdf_index = generate_netcdf_index(netcdf_index);
    % if the fnction is called with a single argument, return the netcdf_index
    if nargin == 1
        data = netcdf_index;
        return
    end
end

% replace -inf / +inf ranges in x and y with smalles/largest actual range
if isinf(OPT.x_range(1)); OPT.x_range(1) = min(netcdf_index.projectionCoverage_x(:)); end
if isinf(OPT.x_range(2)); OPT.x_range(2) = max(netcdf_index.projectionCoverage_x(:)); end
if isinf(OPT.y_range(1)); OPT.y_range(1) = min(netcdf_index.projectionCoverage_y(:)); end
if isinf(OPT.y_range(2)); OPT.y_range(2) = max(netcdf_index.projectionCoverage_y(:)); end

%% search data
files_to_search = find(...
netcdf_index.projectionCoverage_x(:,1) <= OPT.x_range(2) & ...
netcdf_index.projectionCoverage_x(:,2) >= OPT.x_range(1) & ...
netcdf_index.projectionCoverage_y(:,1) <= OPT.y_range(2) & ...
netcdf_index.projectionCoverage_y(:,2) >= OPT.y_range(1))';

x = min(netcdf_index.projectionCoverage_x(:)) + .5 * netcdf_index.resolution_x : netcdf_index.resolution_x * OPT.x_stride : max(OPT.x_range);
x(x<min(OPT.x_range)) = [];
y = min(netcdf_index.projectionCoverage_y(:)) + .5 * netcdf_index.resolution_y : netcdf_index.resolution_y * OPT.y_stride: max(OPT.y_range);
y(y<min(OPT.y_range)) = [];

data.z = nan(length(y),length(x));


% last before
% linear interpolated
% merged in range 

for ii = files_to_search
    ncfile   = netcdf_index.urlPath{ii};
   
    x_nc     = ncread    (ncfile,netcdf_index.var_x);
    y_nc     = ncread    (ncfile,netcdf_index.var_y);
    t_nc     = nc_cf_time(ncfile,netcdf_index.var_t);
    
    % determine     t_start;
    t_sorted = issorted(t_nc);
    
    switch OPT.t_method
        case 'last_in_range'
            t_found = max(t_nc(t_nc<=OPT.t_range(2)));
            if ~isempty(t_found)
                t_start = find(t_nc == max(t_nc(t_nc<=OPT.t_range(2))));
            else
                t_start = [];
            end
            t_count = 1;
        case 'linear_interpolated'
            assert(t_sorted)
        case 'merged_in_range'
            assert(t_sorted)
    end
    if isempty(t_start); continue; end
    
    flip_x   = x_nc(1)>x_nc(end);
    flip_y   = y_nc(1)>y_nc(end);
    
    if flip_x; x_nc = x_nc(end:-1:1); end
    if flip_y; y_nc = y_nc(end:-1:1); end   
  
    % find the first index of x in range of nc_file
    try
        ix(1)    = find(x >= x_nc(1  ),1,'first');
        ix(2)    = find(x <= x_nc(end),1, 'last');
        iy(1)    = find(y >= y_nc(1  ),1,'first');
        iy(2)    = find(y <= y_nc(end),1, 'last');
    catch %#ok<CTCH>
        % this is when the is no relevant data in the nc file, even though
        % it seemed so from the projectionCoverage
        continue
    end
    
    % find indices in nc file
    ix_nc(1) = find(x_nc>=x(ix(1)),1,'first');
    ix_nc(2) = find(x_nc<=x(ix(2)),1, 'last');
    iy_nc(1) = find(y_nc>=y(iy(1)),1,'first');
    iy_nc(2) = find(y_nc<=y(iy(2)),1, 'last');
    
    % find indices in data.z
    nz_i(1)  = find(x == x_nc(ix_nc(1)),1);
    nz_i(2)  = find(x == x_nc(ix_nc(2)),1);
    mz_i(1)  = find(y == y_nc(iy_nc(1)),1);
    mz_i(2)  = find(y == y_nc(iy_nc(2)),1);
    
    % initialize
    start        = [nan nan nan];
    count        = [nan nan nan];
    stride       = [nan nan nan];
    
    % set start
    start(netcdf_index.dim_x) = ix_nc(1);
    start(netcdf_index.dim_y) = iy_nc(1);
    start(netcdf_index.dim_t) = t_start;
    
    % calculate count and stride
    count(netcdf_index.dim_x) = ix_nc(2) - start(netcdf_index.dim_x);
    count(netcdf_index.dim_y) = iy_nc(2) - start(netcdf_index.dim_y);
    count(netcdf_index.dim_t) = t_count;
    
    stride(netcdf_index.dim_x) = OPT.x_stride;
    stride(netcdf_index.dim_y) = OPT.y_stride;
    stride(netcdf_index.dim_t) = 1;
    
    % correct flipped dimensions for start and count
    if flip_x; start(netcdf_index.dim_x) = length(x_nc) + 1 - start(netcdf_index.dim_x) - count(netcdf_index.dim_x); end
    if flip_y; start(netcdf_index.dim_y) = length(y_nc) + 1 - start(netcdf_index.dim_y) - count(netcdf_index.dim_y); end
    
    count = count ./ stride + 1;
    count(netcdf_index.dim_t) = t_count;
    
    % read data from nc file
    z_tmp = ncread(ncfile,netcdf_index.var_z,start,count,stride);

    % permute data in correct order
    z_tmp = permute(z_tmp,[netcdf_index.dim_y,netcdf_index.dim_x,netcdf_index.dim_t]);
   
    % correct flipped dimensions for start and count
    if flip_x; z_tmp = flipdim(z_tmp,2); end
    if flip_y; z_tmp = flipdim(z_tmp,1); end
    
    data.z(mz_i(1):mz_i(2),nz_i(1):nz_i(2)) = z_tmp;
end

[data.x,data.y] = meshgrid(x,y);

function netcdf_index = generate_netcdf_index(netcdf_path)

%% run ncinfo command on all files and store in stricture info.
netcdf_index.urlPath = opendap_catalog(netcdf_path);
for ii = length(netcdf_index.urlPath):-1:1
    info(ii) = ncinfo(netcdf_index.urlPath{ii});
    multiWaitbar('Building catalog',(length(netcdf_index.urlPath)+1-ii)/length(netcdf_index.urlPath))
end
multiWaitbar('Building catalog','close');

%% collect attributes of interest from the structure
for ii = 1:length(info(1).Variables)
    var_att_names   = {info(1).Variables(ii).Attributes.Name};
    var_att_values  = {info(1).Variables(ii).Attributes.Value};
    n_stdname               = strcmp(var_att_names,'standard_name');
    if any(n_stdname)
        switch var_att_values{n_stdname}
            case 'projection_x_coordinate';  netcdf_index.var_x = info(1).Variables(ii).Name;
                n_resolution = strcmp({info(1).Variables(ii).Attributes.Name},'resolution');
                netcdf_index.resolution_x = info(1).Variables(ii).Attributes(n_resolution).Value;
            case 'projection_y_coordinate';  netcdf_index.var_y = info(1).Variables(ii).Name;
                n_resolution = strcmp({info(1).Variables(ii).Attributes.Name},'resolution');
                netcdf_index.resolution_y = info(1).Variables(ii).Attributes(n_resolution).Value;
            case 'time';                     netcdf_index.var_t = info(1).Variables(ii).Name;
            case {'elevation','altitude'};   netcdf_index.var_z = info(1).Variables(ii).Name;
        end
    end
end

%
dimensions = {info(1).Variables(strcmp(netcdf_index.var_z,{info(1).Variables.Name})).Dimensions.Name};
netcdf_index.dim_x      = find(strcmp(dimensions,netcdf_index.var_x));
netcdf_index.dim_y      = find(strcmp(dimensions,netcdf_index.var_y));
netcdf_index.dim_t      = find(strcmp(dimensions,netcdf_index.var_t));

att_names  = cellfun(@(s) {s.Name},{info.Attributes},'UniformOutput',false);
att_names  = vertcat(att_names {:});
att_values = cellfun(@(s) {s.Value},{info.Attributes},'UniformOutput',false);
att_values = vertcat(att_values{:});

netcdf_index.projectionCoverage_x = att_values(strcmp(att_names,'projectionCoverage_x'));
netcdf_index.projectionCoverage_x = vertcat(netcdf_index.projectionCoverage_x{:});

netcdf_index.projectionCoverage_y = att_values(strcmp(att_names,'projectionCoverage_y'));
netcdf_index.projectionCoverage_y = vertcat(netcdf_index.projectionCoverage_y{:});

netcdf_index.timeCoverage         = att_values(strcmp(att_names,'timeCoverage'));

