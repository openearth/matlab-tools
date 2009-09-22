function testresult = grid_angle_test(varargin)
%GRID_ANGLE_TEST  test for GRID_ANGLE
%
% Checks correct rotation matrix:
% for all quadrants
% for centers and corners
% for otrhogonal and deformed meshes
%
%See also: 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

   OPT.TH  = 30;
   OPT.THs = deg2rad(OPT.TH+[0 90 180 270 360]);

%% $Description (Name = grid_angle)
% This test has two testcases.
%
% * The first testcase is a rotation test
% * The second testcase is a deformation test.
%

%% $RunCode
tr(1) = rotationtest();
tr(2) = deformationtest();
testresult = all(tr);

end

function testresult = rotationtest()
%% $Description (Name = rotation)
   OPT.TH  = 30;
   OPT.THs = deg2rad(OPT.TH+[0 90 180 270 360]);

%% $RunCode
clear cen cor

   %% 0 degree

   j = 1;
  [cor(j).x,cor(j).y] = ndgrid(1:4   ,1:4   );
  [cen(j).x,cen(j).y] = ndgrid((1:3)+.5,(1:3)+.5);
  
   %% any degree

   for ii=1:length(OPT.THs)
       
       OPT.TH = OPT.THs(ii);
       
       j = j+1;
       cor(j).x       = cos(OPT.TH)*cor(1).x - sin(OPT.TH)*cor(1).y;
       cor(j).y       = sin(OPT.TH)*cor(1).x + cos(OPT.TH)*cor(1).y;
       
       cen(j).x       = cos(OPT.TH)*cen(1).x - sin(OPT.TH)*cen(1).y;
       cen(j).y       = sin(OPT.TH)*cen(1).x + cos(OPT.TH)*cen(1).y;
   end
   testresult = nan;
   
   %% $PublishResult
   corr = cor;
   cenn = cen;
   for j=1:length(corr)
       
       cor = corr(j);
       cen = cenn(j);
       figure('name',['ROTATION #',num2str(j,'%0.3d')])
       cen.rad      = grid_angle(cor.x,cor.y);
       cor.rad      = grid_angle(cor.x,cor.y,'location','cor');
       cen.deg      = rad2deg(cen.rad);
       cor.deg      = rad2deg(cor.rad);
       
       pcolorcorcen(cor.x,cor.y,mod(cen.deg,360),[.5 .5 .5])
       hold on
       caxis([0 360])
       colorbarwithtitle('\theta [\circ]',[0:90:360])
       text(cen.x(:),cen.y(:),num2str(cen.deg(:) ),'color','w')
       text(cor.x(:),cor.y(:),num2str(cor.deg(:) ),'color','k')
       axis equal

   end   
end

function testresult = deformationtest()
%% $Description (Name = deformation)

%% $RunCode
   %% deformed block (south -45)
   
   j = 1;
   cor(j).x = [0 0 0;1 1 1; 2 2 2];
   cor(j).y = [1 2 2;0 1 2;-1 0 2];
   cen(j).x = corner2center(cor(j).x);
   cen(j).y = corner2center(cor(j).y);

   %% deformed block (east -45))
   
   j = j+1;
   cor(j).x = [1 1 1;1 2 3;2 3 4];
   cor(j).y = [1 2 3;1 2 3;1 2 3];
   cen(j).x = corner2center(cor(j).x);
   cen(j).y = corner2center(cor(j).y);

   %% deformed block (north -45)
   
   j = j+1;
   cor(j).x = [1 1 1;2 2 2;3 3 3];
   cor(j).y = [1 3 4;1 2 3;1 1 2];
   cen(j).x = corner2center(cor(j).x);
   cen(j).y = corner2center(cor(j).y);

   %% deformed block (west -45)
   
   j = j+1;
   cor(j).x = [-1 0 1;0 1 2;2 2 2];
   cor(j).y = [ 1 2 3;1 2 3;1 2 3];
   cen(j).x = corner2center(cor(j).x);
   cen(j).y = corner2center(cor(j).y);

   testresult = nan;
%% $PublishResult
   %% loop cases
   corr = cor;
   cenn = cen;
   for j=1:length(corr)
   
      cor = corr(j);
      cen = cenn(j);

      figure('name',['DEFORMATION #',num2str(j,'%0.3d')])
      cen.rad      = grid_angle(cor.x,cor.y);
      cor.rad      = grid_angle(cor.x,cor.y,'location','cor');
      cen.deg      = rad2deg(cen.rad);
      cor.deg      = rad2deg(cor.rad);
      
      pcolorcorcen(cor.x,cor.y,mod(cen.deg,360),[.5 .5 .5])
      hold on
      caxis([0 360])
      colorbarwithtitle('\theta [\circ]',[0:90:360])
      text(cen.x(:),cen.y(:),num2str(cen.deg(:) ),'color','w')
      text(cor.x(:),cor.y(:),num2str(cor.deg(:) ),'color','k')
      axis equal
      
   end   

end