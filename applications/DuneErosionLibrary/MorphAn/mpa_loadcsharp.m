function mpa_loadcsharp()
%MPA_LOADCSHARP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = mpa_loadcsharp(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   mpa_loadcsharp
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 04 Mar 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% Check version compatibility
assert(~verLessThan('matlab', '7.8'),'The MorphAn wrapper uses the .NET interface introduced in Matlab 2009a. The code cannot be executed whereas this matlab has an earlier version.');
        
%% Find library
if ~isempty(getappdata(0,'MorphAnCSharpLibInitialized'))
    return;
end
    
trdaLocation = which('DeltaShell.Plugins.MorphAn.TRDA.dll');
if isempty(trdaLocation)
    error('MPA:NoLib','Could not find MorphAn library');
end

NET.addAssembly(trdaLocation);
setappdata(0,'MorphAnCSharpLibInitialized',true);

