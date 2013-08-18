function standard_names = nc_standardname(varargin)
%NC_STANDARDNAME  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nc_standardname(varargin)
%
%   Input: For <keyword,value> pairs call nc_standardname() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nc_standardname
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 18 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

standard_names = json.load(urlread('http://127.0.0.1:65433/standardnames'));

idx = cellfun(@isempty,{standard_names.description});
[standard_names(idx).description] = deal('');

if ~isempty(varargin)
    idx1 = find(~cellfun(@isempty,regexp({standard_names.standard_name},varargin{1})));
    idx2 = find(~cellfun(@isempty,regexp({standard_names.description},varargin{1})));
    
    idx2 = setdiff(idx2,idx1);
    
    standard_names = standard_names([idx1 idx2]);
end