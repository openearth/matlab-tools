function [x, y, z, result, mess] = ncgen_checkFcn_surface(x, y, z, varargin)
%NCGEN_CHECKFCN_SURFACE  Checks raw surface data for meeting the ncgen requirements.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ncgen_checkFcn_surface(varargin)
%
%   Input: For <keyword,value> pairs call ncgen_checkFcn_surface() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ncgen_checkFcn_surface
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Kees den Heijer
%
%       kees.denheijer@deltares.nl
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
% Created: 04 Jul 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT = struct(...
    'fname', '',...
    'grid_cellsize_x', NaN,...
    'grid_cellsize_y', NaN,...
    'grid_offset', 0,...
    'sort_x', true,...
    'sort_y', true,...
    'filter_x', false,...
    'filter_y', false,...
    'squares', false);
% return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

%% code
result = struct(...
    'issorted_x', {{false, 'order of x not checked'}},...
    'issorted_y', {{false, 'order of y not checked'}},...
    'equidistant_x', {{false, 'equidistance of x not checked'}},...
    'equidistant_y', {{false, 'equidistance of y not checked'}},...
    'cellsize', {{false, 'cellsize not checked'}},...
    'match_x', {{false, 'matching of x not checked'}},...
    'match_y', {{false, 'matching of y not checked'}});

%% check whether x is in ascending order
if ~issorted(x)
    result.issorted_x = {issorted(x) 'x not in ascending order'};
    if OPT.sort_x
        % make sure X is sorted in ascending order
        [x, ix] = sort(x);
        z = z(:,ix);
        result.issorted_x = {issorted(x) 'x sorted in ascending order and z changed accordingly'};
    end
else
    result.issorted_x = {issorted(x) 'x is in ascending order'};
end

%% derive cell size and check wheter x grid is equidistant
cellsizex = unique(diff(x));
if ~isscalar(cellsizex)
    result.equidistant_x = {false, 'cellsize in x direction is not constant'};
else
    result.equidistant_x = {true, sprintf('cellsize in x direction is constant (value = %g)', cellsizex)};
end

%% check whether y is in ascending order
if ~issorted(y)
    result.issorted_y = {issorted(y) 'y not in ascending order'};
    if OPT.sort_y
        % make sure y is sorted in ascending order
        [y, iy] = sort(y);
        z = z(iy,:);
        result.issorted_y = {issorted(y) 'y sorted in ascending order and z changed accordingly'};
    end
else
    result.issorted_y = {issorted(y) 'y is in ascending order'};
end

%% derive cell size and check wheter y grid is equidistant
cellsizey = unique(diff(y));
if ~isscalar(cellsizey)
    result.equidistant_y = {false, 'cellsize in y direction is not constant'};
else
    result.equidistant_y = {true, sprintf('cellsize in y direction is constant (value = %g)', cellsizey)};
end

%% check whether cell are squares
cellsize = unique([cellsizex cellsizey]);
if ~isscalar(cellsize)
    if OPT.squares
        % cells are supposed to be squares, but aren't
        result.cellsize = {false, sprintf('cellsizes in x (%g) and y (%g) direction are different', cellsizex, cellsizey)};
    else
        % cells are rectangular, but that's not considered as a problem
        result.cellsize = {true, sprintf('cellsizes in x (%g) and y (%g) direction are different', cellsizex, cellsizey)};
    end
else
    result.cellsize = {true, sprintf('cells are squares (size = %g)', cellsize)};
end

%% check whether data cell size matches supposed size
if ~isequal(cellsizex, OPT.grid_cellsize_x)
    result.match_x = {false, sprintf('x cellsize (%g) differs from the supposed size (%g)', cellsizex, OPT.grid_cellsize_x)};
    if OPT.filter_x
        TODO('try to filter the x values')
    end
else
    result.match_x = {true, sprintf('cell size in x direction is %g', cellsizex)};
end

%% check whether data cell size matches supposed size
if ~isequal(cellsizey, OPT.grid_cellsize_y)
    result.match_y = {false, sprintf('y cellsize (%g) differs from the supposed size (%g)', cellsizey, OPT.grid_cellsize_y)};
    if OPT.filter_y
        TODO('try to filter the x values')
    end
else
    result.match_y = {true, sprintf('cell size in y direction is %g', cellsizey)};
end

%%
if ~all(mod(x-OPT.grid_offset, cellsizex) == 0)
    result.offset_x = {false, 'x offset is wrong'};
end

if ~all(mod(y-OPT.grid_offset, cellsizey) == 0)
    result.offset_y = {false, 'y offset is wrong'};
end

%%
idx = cell2mat(struct2cell(structfun(@(d) d{1}, result, 'uniformoutput', false)));

if any(~idx)
    mess = sprintf('%s\n', OPT.fname);
    fnames = fieldnames(result);
    for i = 1:length(fnames)
        if ~result.(fnames{i}){1}
            mess = sprintf('%s  %s\n', mess, result.(fnames{i}){2});
        end
    end
    result = false;
else
    mess = '';
    result = true;
end