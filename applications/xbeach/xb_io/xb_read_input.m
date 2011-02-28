function xb = xb_read_input(filename, varargin)
%XB_READ_INPUT  Read XBeach parameter file and all files referred in it
%
%   Reads the XBeach settings from the params.txt file and all files that
%   are mentioned in the settings, like grid and wave definition files. The
%   settings are stored in a XBeach structure. The referred files are
%   stored in a similar sub-structure.
%
%   Syntax:
%   xb = xb_read_input(filename)
%
%   Input:
%   filename   = params.txt file name
%   varargin   = read_paths:        flag to determine whether relative
%                                   paths should be read and included in
%                                   the result structure
%
%   Output:
%   xb         = XBeach structure array
%
%   Example
%   xb = xb_read_input(filename)
%
%   See also xb_read_params, xb_read_waves

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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'read_paths', true ...
);

OPT = setproperty(OPT, varargin{:});

%% read params.txt

% user current directory, if no input is given
if ~exist('filename', 'var')
    filename = pwd;
end

if ~exist(filename, 'file')
    error(['File does not exist [' filename ']'])
end

if isdir(filename)
    % file is actually a directory, add params.txt
    filename = fullfile(filename, 'params.txt');
end

xb = xb_read_params(filename);

%% read referred files

if OPT.read_paths
    
    fdir = fileparts(filename);

    for i = 1:length(xb.data)
        if ischar(xb.data(i).value)
            fpath = fullfile(fdir, xb.data(i).value);

            if exist(fpath, 'file')
                switch xb.data(i).name
                    case {'bcfile'}
                        % read waves
                        value = xb_read_waves(fpath);
                    case {'zs0file'}
                        % read tide
                        value = xb_read_tide(fpath);
                    case {'xfile' 'yfile' 'depfile' 'ne_layer'}
                        % read bathymetry
                        value = xb_read_bathy(xb.data(i).name, fpath);
                    otherwise
                        % assume file to be a grid and try reading it
                        try
                            value = xb_empty();
                            value = xb_set(value, 'data', load(fpath));
                            value = xb_meta(value, mfilename, 'grid');
                        catch
                            % cannot read file, save filename only
                            value = fpath;
                        end
                end
                
                xb.data(i).value = value;
            end
        end
    end
end

% set meta data
xb = xb_meta(xb, mfilename, 'input', filename);
