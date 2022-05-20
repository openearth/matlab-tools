function z = x2z(varargin)
%X2Z  Basic x2z function
%
%   Basic x2z function that translates a set of random samples to failure
%   indicators by simply substracting the resistance.
%
%   Syntax:
%   z = x2z(varargin)
%
%   Input:
%   varargin  = S:      Sollicitation
%               R:      Resistance
%
%   Output:
%   z         = List of failure indicators (z<0 = failed)
%
%   Example
%   z = x2z('S', x, 'R', 10)
%
%   See also MC, P2x, x2z_DUROS, x2z_DUROSTA

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 23 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct(                   ...
    'R',   0,                   ...     % resistance value
    'S',   0                    ...     % sollicitation value
);

OPT = setproperty(OPT, varargin{:});

%% compute z-values

z = OPT.R - OPT.S;
