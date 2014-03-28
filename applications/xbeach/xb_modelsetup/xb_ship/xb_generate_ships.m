function xb_sg = xb_generate_ships(varargin)
%XB_GENERATE_SHIPS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   xb = xb_generate_ships(varargin)
%
%   Input: For <keyword,value> pairs call xb_generate_ships() without arguments.
%   varargin =
%
%   Output:
%   xb       =
%
%   Example
%   xb_generate_ships
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 DELTARES
%       rooijen
%
%       Arnold.vanRooijen@deltares.nl
%
%       Deltares
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
% Created: 25 Mar 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
OPT = struct( 'noships',1,...
    'shipgeom', {{}}, ...
    'shiptrack', {{}}, ...
    'path', '');
OPT = setproperty(OPT, varargin{:});
%% code
xb_st = xs_empty();
xb_sg = xs_empty();

for i = 1%:length(OPT.noships) % TODO: Only works for one ship for now
    xb_st  = xb_compute_shiptrack(i,OPT.shiptrack{:});
    xb_sg  = xb_shipgeom(i,OPT.shipgeom{:});
    xb_sg  = xs_set(xb_sg, 'shiptrack', xb_st); 
end

xb_sg = xs_meta(xb_sg, mfilename, 'ships');

% Input
% geometry: lxbxd
% track: xy, t/speed


