function outputPng = generateoutputpngname(varargin)
%GENERATEOUTPUTPNGNAME  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = generateoutputpngname(varargin)
%
%   Output:
%   varargout =
%
%   Example
%   generateoutputpngname
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: generateoutputpngname.m 4046 2011-02-16 15:54:20Z boer_we $
% $Date: 2011-02-16 07:54:20 -0800 (Wed, 16 Feb 2011) $
% $Author: boer_we $
% $Revision: 4046 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/python/applications/openearthtest/openearthtest/public/matlab/generateoutputpngname.m $
% $Keywords: $

%% Construct name at correct output location
[outPath name] = fileparts(tempname);
if nargin > 0
    outPath = varargin{1};
end
outputPng = fullfile(outPath,[name '.png']);

%% Delete any existing file with the same temp name
if exist(outputPng,'file')
    delete(outputPng);
end