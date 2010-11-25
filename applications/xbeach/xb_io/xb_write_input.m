function xb_write_input(filename, xbSettings, varargin)
%XB_WRITE_INPUT  Write XBeach params.txt file and all files referred in it
%
%   Writes the XBeach settings from a XBeach structure in a parameter file.
%   Also the files that are referred to in the parameter file are written,
%   like grid and wave definition files.
%
%   Syntax:
%   xb_write_input(filename, xbSettings, varargin)
%
%   Input:
%   filename    = filename of parameter file
%   xbSettings  = XBeach structure array
%   varargin    = write_paths:  flag to determine whether definition files
%                               should be written or just referred
%
%   Output:
%   none
%
%   Example
%   xb_write_input(filename, xbSettings)
%
%   See also xb_read_input, xb_write_params

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

if ~xb_check(xbSettings); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'write_paths', true ...
);

OPT = setproperty(OPT, varargin{:});

%% write referred files

if OPT.write_paths
    
    [fdir fname dext] = fileparts(filename);

    for i = 1:length(xbSettings.data)
        if isstruct(xbSettings.data(i).value)
            xb = xbSettings.data(i).value;
            
            switch xbSettings.data(i).name
                case {'bcfile'}
                    % write waves
                    xbSettings.data(i).value = xb_write_waves(xb);
                case {'zs0file'}
                    % write tide
                    xbSettings.data(i).value = xb_write_tide(xb);
                case {'xfile' 'yfile' 'depfile' 'ne_layer'}
                    % write bathymetry
                    xb = xb_set(xb, xbSettings.data(i).name, xb_get(xb, 'data'));
                    xbSettings.data(i).value = xb_write_bathy(xb);
                otherwise
                    % assume file to be a grid and try writing it
                    try
                        xbSettings.data(i).value = fullfile(fdir, [xbSettings.data(i).name '.txt']);
                        data = xb_get(xb, 'data');
                        save(xbSettings.data(i).value, '-ascii', 'data');
                    catch
                        % cannot write file, ignore
                        xbSettings.data(i).value = '';
                    end
            end
        end
    end
end

%% write params.txt file

xb_write_params(filename, xbSettings)
