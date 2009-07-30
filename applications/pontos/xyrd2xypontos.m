function [xpontos, ypontos] = xyrd2xypontos(xrd, yrd)
%XYRD2XYPONTOS converts Dutch RD coordinates to PonTos coordinates for
% the Dutch coast
%
%   ALPHA RELEASE, UNDER CONSTRUCTION, only supports the Holland coast!
%
%   Syntax:
%   [xpontos, ypontos] = xyrd2xypontos(xrd, yrd)
%
%   Input:
%   xrd    = x coordinate in Dutch RD system [m]
%   yrd    = y coordinate in Dutch RD system [m]
%
%   Output:
%   xpontos = alongshore position [m]
%   ypontos = cross-shore position [m]
%
%   Example
%   xyrd2xypontos
%
%   See also xRSP2xyRD

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
%       The Netherlands
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
% Created: 30 Jul 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id: oettemplate.m 688 2009-07-15 11:46:33Z damsma $
% $Date: 2009-07-15 13:46:33 +0200 (Wed, 15 Jul 2009) $
% $Author: damsma $
% $Revision: 688 $
% $HeadURL: https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/general/oet_template/oettemplate.m $
% $Keywords: $

%%

Y0_H = 545000;
R_H = 150000;
X0_H = 110000 - R_H;

xpontos = 211241.18 - atan((Y0_H-yrd)./(xrd-X0_H)) .* R_H;
R_RSP = sqrt((xrd-X0_H).^2+(yrd-Y0_H).^2);
ypontos = R_H - R_RSP;





