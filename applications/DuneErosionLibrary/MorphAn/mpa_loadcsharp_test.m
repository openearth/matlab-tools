function mpa_loadcsharp_test()
% MPA_LOADCSHARP_TEST  Unt test for mpa_loadcsharp
%
% More detailed description of the test goes here.
%
%
%   See also mpa_loadcsharp

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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
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

MTestCategory.Unit;

loaded = true;
try
    DeltaShell.Plugins.MorphAn.TRDA.Calculators.TRDAInputParameters;
catch
    loaded = false;
end

if loaded
    warning('MTest:MPA:loadcsharp','Could not perform test, library is already loaded');
end

mpa_loadcsharp;

assert(~isempty(getappdata(0,'MorphAnCSharpLibInitialized')),'application data should not be set');
DeltaShell.Plugins.MorphAn.TRDA.Calculators.TRDAInputParameters;
