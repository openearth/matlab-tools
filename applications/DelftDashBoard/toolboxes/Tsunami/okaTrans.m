function [x z] = okaTrans(depth, dip, wdt, sliprake, slip, xx)
%OKATRANS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [x z] = okaTrans(depth, dip, wdt, sliprake, slip, xx)
%
%   Input:
%   depth    =
%   dip      =
%   wdt      =
%   sliprake =
%   slip     =
%   xx       =
%
%   Output:
%   x        =
%   z        =
%
%   Example
%   okaTrans
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
dx=2;
xl=round(3*wdt/2);
[E,N] = meshgrid(-xl:dx:xl,-xl:dx:xl);
lngth=wdt;
% Focal depth
focdpt = wdt*sin(dip*pi/180) + depth;
[uE,uN,uZ] = okada85(E,N,focdpt,0,dip,lngth,wdt,sliprake,slip,0);


ix0=size(E,1)/2-wdt/2/dx;
ix=ix0+xx/2;
ix=round(ix);
ix=min(ix,ceil(size(E,1)/2));
ix=max(ix,1);

x=E(ix,:);
z=uZ(ix,:);

