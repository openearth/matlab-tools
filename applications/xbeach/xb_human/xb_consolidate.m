function xb = xb_consolidate(xb, varargin)
%XB_CONSOLIDATE  Consolidates parameters in XBeach structure in the last dimension of its value
%
%   Checks whether values in a XBeach structure are constant along the last
%   dimension. If true, it eliminates this dimension. Vectors become
%   scalars 2D matrices become vectors, etc. Cell arrays are not
%   consolidated. Returns the consolidated XBeach structure.
%
%   Syntax:
%   xb = xb_consolidate(xb, varargin)
%
%   Input:
%   xb          = XBeach structure array
%   varargin    = none
%
%   Output:
%   xb  = XBeach structure array
%
%   Example
%   xb = xb_consolidate(xb)
%
%   See also xb_empty, xb_show

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
% Created: 26 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

if ~xb_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% consolidate structure

for i = 1:length(xb.data)
    A = xb.data(i).value;
    S = ones(size(size(A))); S(end) = size(A,ndims(A));
    
    if iscell(A); continue; end;
    
    % determine if last dimension is constant
    if sum(sum(sum(abs(A-repmat(sum(A,ndims(A))/S(end),S))))) < 1e-10
        if sum(size(A)>1) > 0
            idx = num2cell(repmat(':', 1, sum(size(A)>1))); idx{end} = 1;
            xb.data(i).value = A(idx{:});
        end
    end
end