%ARROW2TEST   test for ARROW2
% This script shows why arrow2 performs better than quiver in distorted axes,
%
% for instance in crosssections through oceans and seas and rivers, where the
% width is generally in the order of (tens of) kilometeres, while the depth
% is only in the order of (tens) of meters: an ratio of order 1000.
% G.J. de Boer, Dec 2004
%
%See also: ARROW2

 figure
 
    [x,y,z] = peaks;
    y       = 100.*y;
    
    [u,v]=gradient(z);
 
    arrowscale = 1;
    pcolor(x,y,z)
    hold on
 
    dm = 5;
    dn = 5;
    quiver(            x(1:dm:end,1:dn:end),...
                       y(1:dm:end,1:dn:end),...
           arrowscale.*u(1:dm:end,1:dn:end),...
           arrowscale.*v(1:dm:end,1:dn:end),0,'w');
 
    struct.scale = arrowscale;
    struct.color = 'k';
    struct.AspectRatioNormalisation = 1; %'min';
    
    arrow2(x(1:dm:end,1:dn:end),...
           y(1:dm:end,1:dn:end),...
           u(1:dm:end,1:dn:end),...
           v(1:dm:end,1:dn:end),struct);
   
figure

   [x,y] = meshgrid(-2:2:2,-2:2:2)
   u     = (x + y)./4;
   v     = (x - y)./4;
   
   plot(x,y,'o')
   hold on
   
   for i=1:length(x(:))
      txt{i} = strvcat([' u= ',num2str(u(i))],[' v= ',num2str(v(i))]);
      text(x(i),y(i),txt{i})
   end
   
   arrow2(x,y,u,v)
   
   grid