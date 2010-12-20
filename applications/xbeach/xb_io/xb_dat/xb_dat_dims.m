function [dims names type] = xb_dat_dims(filename, varargin)
%XB_DAT_DIMS  Returns the lengths of all dimensions of a XBeach DAT file
%
%   Returns an array with the lengths of all dimensions of a XBeach DAT
%   file. The functionality works similar to the Matlab size() function on
%   variables.
%
%   Syntax:
%   dims = xb_dat_dims(filename, varargin)
%
%   Input:
%   filename    = Filename of DAT file
%   varargin    = ftype:    datatype of DAT file (double/single)
%
%   Output:
%   dims        = Array with lengths of dimensions
%   names       = Cell array with names of dimensions (x/y/t/d/gd/theta)
%   type        = String identifying the type of DAT file
%                 (wave/sediment/graindist/bedlayers/point/2d)
%
%   Example
%   dims = xb_dat_dims(filename)
%
%   See also xb_dat_read, xb_dat_type, xb_read_dat

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
% Created: 06 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'ftype', 'double' ...
);

OPT = setproperty(OPT, varargin{:});

bytes = struct( ...
    'integer', 1, ...
    'single', 4, ...
    'double', 8 ...
);

%% read file and model info

if ~exist(filename, 'file')
    error(['File does not exist [' filename ']']);
end

[fdir fname fext] = fileparts(filename);

if isempty(fdir); fdir = '.'; end;

d = xb_read_dims(fdir);
f = dir(fullfile(filename));

if ~isfield(d, 'nx') || ~isfield(d, 'ny') || ~isfield(d, 'nt')
    error('Primary dimensions x, y and/or t unknown');
end

byt = bytes.(OPT.ftype);

%% determine dimensions

if regexp(fname, '^(point|rugau)\d+$')
    
    % point data
    nvars = floor(f.bytes/byt/d.ntp)-1;
    dims = [d.ntp nvars+1];
    names = {'t' 'variables'};
    type = 'point';
else

    % determine space dimensions
    nx = d.nx+1;
    ny = d.ny+1;

    % determine time dimension
    if regexp(fname, '_(mean|max|min|var)$')
        nt = d.ntm;
    else
        nt = d.nt;
    end

    % set minimal dimensions
    dims = [nx ny nt];
    names = {'x' 'y' 't'};
    type = '2d';

    if f.bytes < prod(dims)*byt
        % smaller than minimal, adjust time assuming file is incomplete
        warning(['File is smaller than minimum size, probably incomplete [' filename ']']);

        nt = floor(f.bytes/byt/nx/ny);
        dims = [nx ny nt];
    elseif f.bytes > prod(dims)*byt
        % larger than minimal dimensions, search alternatives
        
        ads = [d.ntheta d.nd d.ngd d.nd*d.ngd];
        
        cat = { {'cgx' 'cgy' 'cx' 'cy' 'ctheta' 'ee' 'thet' 'costhet' 'sinthet' 'sigt' 'rr'} ...
                {'dzbed'} ...
                {'ccg' 'ccbg' 'Tsg' 'Susg' 'Svsg' 'Subg' 'Svbg' 'ceqbg' 'ceqsg' 'ero' 'depo_im' 'depo_ex'} ...
                {'pbbed'} ...
        };
    
        i = ismember(ads, f.bytes/byt/prod(dims));

        if sum(i) == 0
            % no match, use filename and adjust time
            for j = 1:length(cat)
                if any(strcmpi(fname, cat{j}))
                    i(:) = false;
                    i(j) = true;
                    break;
                end
            end
            
            if any(i)
                nt = floor(f.bytes/byt/nx/ny/ads(i));
            end
        end
        
        if sum(i) > 1
            % multiple matches, use filename
            for j = find(i)
                if j > length(cat); continue; end;
                if any(strcmpi(fname, cat{j}))
                    i(:) = false;
                    i(j) = true;
                    break;
                end
            end
        end
                
        if sum(i) == 1
            % single match, use it
            switch find(i)
                case 1
                    % waves
                    dims = [nx ny d.ntheta nt];
                    names = {'x' 'y' 'theta' 't'};
                    type = 'wave';
                case 2
                    % sediments
                    dims = [nx ny d.nd nt];
                    names = {'x' 'y' 'd' 't'};
                    type = 'sediment';
                case 3
                    % grain distribution
                    dims = [nx ny d.ngd nt];
                    names = {'x' 'y' 'gd' 't'};
                    type = 'graindist';
                case 4
                    % bed layers
                    dims = [nx ny d.nd d.ngd nt];
                    names = {'x' 'y' 'd' 'gd' 't'};
                    type = 'bedlayers';
                otherwise
                    % huh?!
                    dims = [];
            end
        else
            % no name match, no size match, assume it is a normal x,y,t dat
            % file that is too long
            dims = [nx ny nt];
            names = {'x' 'y' 't'};
            type = '2d';
        end
    end
end

if isempty(dims)
    warning(['Dimensions could not be determined [' filename ']']);
    
    names = {};
    type = 'unknown';
end
