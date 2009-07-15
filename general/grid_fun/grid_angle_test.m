function grid_angle_test(varargin)
%GRID_ANGLE_TEST  test for GRID_ANGLE

   OPT.TH = deg2rad(30+90+90+90);

%% 0 degree

  [cor(1).x,cor(1).y] = ndgrid([1:4]   ,[1:4]   );
  [cen(1).x,cen(1).y] = ndgrid([1:3]+.5,[1:3]+.5);
  
%% any degree

   cor(2).x       = cos(OPT.TH)*cor(1).x - sin(OPT.TH)*cor(1).y;
   cor(2).y       = sin(OPT.TH)*cor(1).x + cos(OPT.TH)*cor(1).y;

   cen(2).x       = cos(OPT.TH)*cen(1).x - sin(OPT.TH)*cen(1).y;
   cen(2).y       = sin(OPT.TH)*cen(1).x + cos(OPT.TH)*cen(1).y;

%% block
   
   cor(3).x = [1 1;2 2];
   cor(3).y = [1 2;1 2];
   cen(3).x = mean(cor(3).x(:));
   cen(3).y = mean(cor(3).y(:));

%% deformed block (south -45)
   
   j = 4;
   cor(j).x = [1 1;2 2];
   cor(j).y = [1 2;0 2];
   cen(j).x = mean(cor(j).x(:));
   cen(j).y = mean(cor(j).y(:));

%% deformed block (east -45))
   
   j = 5;
   cor(j).x = [1 1;2 3];
   cor(j).y = [1 2;1 2];
   cen(j).x = mean(cor(j).x(:));
   cen(j).y = mean(cor(j).y(:));

%% deformed block (north -45)
   
   j = 6;
   cor(j).x = [1 1;2 2];
   cor(j).y = [1 3;1 2];
   cen(j).x = mean(cor(j).x(:));
   cen(j).y = mean(cor(j).y(:));

%% deformed block (west -45)
   
   j = 7;
   cor(j).x = [0 1;2 2];
   cor(j).y = [1 2;1 2];
   cen(j).x = mean(cor(j).x(:));
   cen(j).y = mean(cor(j).y(:));

%% titled block (45 deg)
   
   j = 8;
   cor(j).x = [1 0;2 1];
   cor(j).y = [1 2;2 3];
   cen(j).x = mean(cor(j).x(:));
   cen(j).y = mean(cor(j).y(:));

%% rotated block
   
   j = 9;
   cor0.x = [1 1;2 2];
   cor0.y = [1 2;1 2];
   cen0.x = mean(cor0.x(:));
   cen0.y = mean(cor0.y(:));

   cor(j).x       = cos(OPT.TH)*cor0.x - sin(OPT.TH)*cor0.y;
   cor(j).y       = sin(OPT.TH)*cor0.x + cos(OPT.TH)*cor0.y;

   cen(j).x       = cos(OPT.TH)*cen0.x - sin(OPT.TH)*cen0.y;
   cen(j).y       = sin(OPT.TH)*cen0.x + cos(OPT.TH)*cen0.y;

%% loop cases

   for j=4:length(cor)
   
      grid_angle_test_plot(cor(j),cen(j))
      
   end   

%%    
function grid_angle_test_plot(cor,cen)   

   cen.rad      = grid_angle(cor.x,cor.y);
  %cor.rad      = grid_angle(cor.x,cor.y,'location','cor');
   cen.deg      = rad2deg(cen.rad);
  %cor.deg      = rad2deg(cor.rad);
   
   figure
   pcolorcorcen(cor.x,cor.y,mod(cen.deg,360),[.5 .5 .5])
   hold on
   caxis([0 360])
   colorbarwithtitle('\theta [\circ]',[0:90:360])
   text(cen.x(:),cen.y(:),num2str(cen.deg(:) ),'color','w')
  %text(cor.x(:),cor.y(:),num2str(cor.deg(:) ),'color','k')
   axis equal
