function Tp = xb_bc_extracttp(xb)
%XB_BC_EXTRACTTP  Extracts wave period from XBeach input structure
%
%   Extracts wave period from XBeach input structure
%
%   Syntax:
%   Tp = xb_bc_extracttp(xb)
%
%   Input:
%   xb          = XBeach input structure
%
%   Output:
%   Tp          = peak wave period
%
%   Example
%   Tp = xb_bc_extracttp(xb)
%
%   See also xb_bc_extractwl, xb_generate_model

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
% Created: 17 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_bc_extracttp.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/applications/xbeach/xb_modelsetup/xb_bc/xb_bc_extracttp.m $
% $Keywords: $

%% read options

Tp = 12;

if xs_exist(xb, 'bcfile')
    bcfile = xs_get(xb, 'bcfile');
    switch xs_get(bcfile, 'type')
        case {'jonswap' 'jonswap_mtx'}
            Tp = max(xs_get(bcfile, 'Tp'));
        case 'vardens'
            [vardens freqs] = xs_get(bcfile, 'vardens', 'freqs');
            
            [m i] = max(sum(vardens,1));
            
            Tp = 1/freqs(i);
    end
elseif xs_exist(xb, 'Tp')
    Tp = xs_get(xb, 'Tp');
end
