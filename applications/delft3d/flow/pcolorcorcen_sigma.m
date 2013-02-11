function varargout = pcolorcorcen_sigma(x, sigma, eta, depth, c)
%PCOLORCORCEN_SIGMA  pcolor for x-sigma plane (cross section, thalweg)
%
% PCOLORCORCEN_SIGMA(x, sigma, eta, depth, c)
% plots pcolor(x,, c) where z is calculated on-the-fly
% according to the CF <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/apd.html">ocean_sigma_coordinate</a> formulation:
% z = eta + sigma*(eta + depth) with sigma 0 at
% the water level and -1 at the bed/bottom,
% and depth positive DOWN.
%
% Shading interp when length of x,eta & depth
% is size(c,2), shading flat when lenghth of x, eta & depth
% is one longer AND length(sigma) is size(c,1)+1
%
% Example: thalweg slice through an estuary
%
%   x     = linspace(0,10e3,10);
%   sigma = linspace(-1,0,5);
%   [~,c] = meshgrid(x,-100*sigma);
%   eta   = sin(2*pi*x/10e3);
%   depth = 10 - 5e-4*x;
%   pcolorcorcen_sigma(x, sigma, eta, depth, c)
%   colorbarwithvtext('sediment [mg/l]')
%   tickmap('x')
%   ylabel('depth [m]')
%   grid on
%   text(xlim1(1),ylim1(1),' \uparrow sea             ','rotation',90,'verticalalignment','top')
%   text(2e3     ,ylim1(1),' port of Z'                ,'rotation',90)
%   text(7e3     ,ylim1(1),' city of A'                ,'rotation',90)
%   text(xlim1(2),ylim1(1),' \downarrow upstream river','rotation',90,'verticalalignment','bottom')
%
%See also: pcolorcorcen, interp_z2sigma, d3d_sigma

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id$
%  $Date$
%  $Author$
%  $Revision$
%  $HeadURL$
%  $Keywords: $

[x,z]=meshgrid(x(:),sigma(:));

for i=1:size(x,2)
    z(:,i) = eta(i) + sigma.*(eta(i) + depth(i));
end

if nargout==0
   pcolorcorcen(x,z,c)
else
   varargout = {pcolorcorcen(x,z,c)};
end