function [x y z] = xb_grid_trim(x, y, z, varargin)
%XB_GRID_TRIM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_grid_trim(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_grid_trim
%
%   See also 

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
% Created: 15 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

if ndims(z) ~= 2; error(['Dimensions of elevation matrix incorrect [' num2str(ndims(z)) ']']); end;

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% trim grid

% remove nan's in two dimensions
for n = 1:2
    
    % index cells
    idx = {':' ':'};
    idxs = {':' ':'};
    idxs{n} = [];
    
    for i = 1:size(z,n)
        idx{n} = i;
        if all(isnan(z(idx{:})))
            idxs{n} = [idxs{n} i];
        end
    end
    
    % remove nan columns/rows
    x(idxs{:}) = [];
    y(idxs{:}) = [];
    z(idxs{:}) = [];
end