function varargout = sobek_freqexc_join(varargin)
%SOBEK_FREQEXC_JOIN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = sobek_freqexc_join(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   sobek_freqexc_join
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 14 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT.keyword=value;
OPT = setproperty(OPT,varargin{:});

if nargin==0;
    varargout = OPT;
    return;
end
%% code
