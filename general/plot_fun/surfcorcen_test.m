function surfcorcen_test()
% SURFCORCEN_TEST  test for SURFCORCEN
%  
% This function tests surfcorcen.
%
%
%   See also surfcorcen pcolorcorcen

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Unit;

   [xcor,ycor] = meshgrid(1:3,5:8);
   zcor        = xcor + ycor; %rand(size(xcor));
   
   [xcen,ycen,zcen] = corner2center(xcor,ycor,zcor);
   
   ccen        = zcen;
   ccor        = zcor;
   
   clims = [min(ccor(:)) max(ccor(:))];
   
   ny = 3;
   
   subplot(ny,5,1)
   surfcorcen(zcor)
   caxis(clims)
   title('surfcorcen(zcor)')
   
   subplot(ny,5,2)
   surfcorcen(zcor,'r')
   caxis(clims)
   title('surfcorcen(zcor,''r'')')
   
   subplot(ny,5,3)
   surfcorcen(zcor,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(zcor,[.5 .5 .5])')
   
   subplot(ny,5,4)
   surfcorcen(zcor,ccor)
   caxis(clims)
   title('surfcorcen(zcor,ccor)')
   
   subplot(ny,5,5)
   surfcorcen(zcor,ccen)
   caxis(clims)
   title('surfcorcen(zcor,ccen)')
   
   %% not possible
   %surfcorcen(zcen,ccor);
   %pausedisp
   
   %%-------------
   
   subplot(ny,5,6)
   surfcorcen(zcor,ccor,'r')
   caxis(clims)
   title('surfcorcen(zcor,ccor,''r'')')
   
   subplot(ny,5,7)
   surfcorcen(zcor,ccor,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(zcor,ccor,[.5 .5 .5])')
   
   subplot(ny,5,8)
   surfcorcen(zcor,ccen,'r')
   caxis(clims)
   title('surfcorcen(zcor,ccen,''r'')')
   
   subplot(ny,5,9)
   surfcorcen(zcor,ccen,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(zcor,ccen,[.5 .5 .5])')
   
   %%-------------
   
   subplot(ny,5,11)
   surfcorcen(xcor,ycor,zcor,ccor,'r')
   caxis(clims)
   title('surfcorcen(xcor,ycor,zcor,ccor,''r'')')
   
   subplot(ny,5,12)
   surfcorcen(xcor,ycor,zcor,ccor,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(xcor,ycor,zcor,ccor,[.5 .5 .5])')
   
   subplot(ny,5,13)
   surfcorcen(xcor,ycor,zcor,ccen,'r')
   caxis(clims)
   title('surfcorcen(xcor,ycor,zcor,ccen,''r'')')
   
   subplot(ny,5,14)
   surfcorcen(xcor,ycor,zcor,ccen,[.5 .5 .5])
   caxis(clims)
   title('surfcorcen(xcor,ycor,zcor,ccen,[.5 .5 .5])')

%% EOF
