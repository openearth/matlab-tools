%TRISURFCORCEN_TEST   test for TRISURFCORCE
%
%See also: TRISURFCORCEN

   el = 30;
   nx = 3;
   ny = 2;
   zlims  = [-.4 .4];
   aspect = [1 1 .2];
   
   dx        = 0.5;
   dy        = 0.5;
   [x,y]     = meshgrid(-2:dx:2, -2:dy:2);
   z         = x .* exp(-x.^2 - y.^2);
   
   tri.p     = delaunay(x,y);
   [tri.x,tri.y,tri.z] = tri_corner2center(tri.p,x,y,z);%tri.z    = mean(z(tri.p),2);
   
   %                       zzzzz ccccc
   subplot(ny,nx,1)
   trisurfcorcen(tri.p,x,y,    z,    z);
   ylabel('\rightarrow c at corners (vertices)')
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,z,c)')
   
   subplot(ny,nx,2)
   trisurfcorcen(tri.p,x,y,tri.z,    z);
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,zc,c)')
   
   subplot(ny,nx,3)
   trisurfcorcen(tri.p,x,y,z);
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,c)')
   
   subplot(ny,nx,4)
   trisurfcorcen(tri.p,x,y,    z,tri.z);
   xlabel('\uparrow    z at corners (vertices)')
   ylabel('\rightarrow c at centers (faces)   ')
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,z,cc)')
   
   subplot(ny,nx,5)
   trisurfcorcen(tri.p,x,y,tri.z,tri.z);
   xlabel('\uparrow    z at centers (faces)   ')
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,zc,cc)')
   
   subplot(ny,nx,6)
   trisurfcorcen(tri.p,x,y,tri.z);
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   xlabel('\uparrow    z derived form c')
   title({'trisurfcorcen(tri,x,y,cc)','NOTE: Z NOT DEFINED !!'})
   
%% EOF   