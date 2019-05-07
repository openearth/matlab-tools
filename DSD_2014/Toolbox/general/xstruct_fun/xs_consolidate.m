function xs = xs_consolidate(xs, varargin)
%XS_CONSOLIDATE  Consolidates parameters in XStruct in the last dimension of its value
%
%   Checks whether values in a XStruct are constant along the last
%   dimension. If true, it eliminates this dimension. Vectors become
%   scalars 2D matrices become vectors, etc. Cell arrays are not
%   consolidated. Returns the consolidated XStruct.
%
%   Syntax:
%   xs = xs_consolidate(xs, varargin)
%
%   Input:
%   xs          = XStruct array
%   varargin    = none
%
%   Output:
%   xs  = XStruct array
%
%   Example
%   xs = xs_consolidate(xs)
%
%   See also xs_empty, xs_show

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

% $Id: xs_consolidate.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/general/xstruct_fun/xs_consolidate.m $
% $Keywords: $

%% read options

if ~xs_check(xs); error('Invalid XStruct'); end;

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% consolidate structure

for i = 1:length(xs.data)
    A = xs.data(i).value;
    S = ones(size(size(A))); S(end) = size(A,ndims(A));
    
    if iscell(A); continue; end;
    
    % determine if last dimension is constant
    if sum(sum(sum(abs(A-repmat(sum(A,ndims(A))/S(end),S))))) < 1e-10
        if sum(size(A)>1) > 0
            idx = num2cell(repmat(':', 1, sum(size(A)>1))); idx{end} = 1;
            xs.data(i).value = A(idx{:});
        end
    end
end