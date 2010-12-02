function [xb instat swtable] = xb_generate_waves(varargin)
%XB_GENERATE_WAVES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_generate_waves(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_generate_waves
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
% Created: 01 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% read options

type = 'jonswap';

idx = strcmpi('type', varargin(1:2:end));
if any(idx)
    type = varargin{find(idx)+1};
end

switch type
    case 'jonswap'
        OPT = struct( ...
            'type', type, ...
            'Hm0', 7.6, ...
            'Tp', 12, ...
            'dir', 270, ...
            'gamma', 3.3, ...
            's', 20, ...
            'fnyq', 1 ...
        );
    
        instat = 4;
    case 'vardens'
        OPT = struct( ...
            'type', type, ...
            'freqs', [], ...
            'dirs', [], ...
            'vardens', [] ...
        );
    
        instat = 41;
end

OPT.type = type;
OPT.duration = 3600;
OPT.timestep = 1;

OPT = setproperty(OPT, varargin{:});

%% generate waves

xb = xb_empty();

f = fieldnames(OPT);
for i = 1:length(f)
    xb = xb_set(xb, f{i}, OPT.(f{i}));
end

% include swtable, if necessary
swtable = xb_empty();
swtable = xb_meta(swtable, mfilename, 'swtable');
if instat == 4
    fpath = fullfile(fileparts(which(mfilename)), 'RF_table.txt');
    if exist(fpath, 'file')
        swtable = xb_set(swtable, 'data', load(fpath));
        swtable = xb_meta(swtable, mfilename, 'swtable', fpath);
    end
end

xb = xb_meta(xb, mfilename, 'waves');
