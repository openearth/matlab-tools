%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17498 $
%$Date: 2021-09-29 08:53:15 +0200 (Wed, 29 Sep 2021) $
%$Author: chavarri $
%$Id: figure_layout.m 17498 2021-09-29 06:53:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/figure_layout.m $
%

%e.g.
% %% sample data
% 
% z_n=160*membrane(1,20);
% 
% [nx,ny]=size(z_n);
% xv=linspace(0,100,nx+1);
% yv=linspace(0,200,ny+1);
% 
% xy_cross=[-102.5,0;198.5,200];
% [x_m,y_m,nodes]=meshgridNodes(xv,yv);
% 
% 
% %% obtain cross
% 
% nodes=nodes';
% xs=x_m(:)';
% ys=y_m(:)';
% zs=z_n(:);
% xc=xy_cross(:,1);
% yc=xy_cross(:,2);
% 
% Data_xy=arbcross_wrap(nodes,xs,ys,zs,xc,yc);
% 
% %% plot
% 
% figure
% subplot(2,1,1)
% hold on
% patch('faces',nodes,'vertices',[xs',ys'],'FaceVertexCData',zs,'FaceColor','flat');
% plot(xc,yc)
% xlabel('x')
% ylabel('y')
% han.c=colorbar('location','northoutside');
% han.c.Label.String='z';
% 
% subplot(2,1,2)
% plot(Data_xy.Scen,Data_xy.val,'-*')
% xlabel('s')
% ylabel('z')

function Data_xy=arbcross_wrap(nodes,xs,ys,zs,xc,yc)

arb=arbcross(nodes,xs,ys,xc,yc);
val=arbcross(arb,{'FACE' zs});

%renaming
Data_xy.Xcor = arb.x;
Data_xy.Ycor = arb.y;
Data_xy.Scor=NaN(size(Data_xy.Xcor));
nonan = ~isnan(Data_xy.Xcor);
Data_xy.Scor(nonan,:) = [0; cumsum(sqrt(diff(Data_xy.Xcor(nonan)).^2+diff(Data_xy.Ycor(nonan)).^2))];

Data_xy.Xcen = (Data_xy.Xcor(1:end-1) + Data_xy.Xcor(2:end)) ./ 2;
Data_xy.Ycen = (Data_xy.Ycor(1:end-1) + Data_xy.Ycor(2:end)) ./ 2;
Data_xy.Scen = (Data_xy.Scor(1:end-1) + Data_xy.Scor(2:end)) ./ 2;
Data_xy.val=val;

end %function