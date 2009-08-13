%GRADIENT2_TEST  test that compares gradient2 to gradient
%
%  Generates 3 cases plots:
%  * gradient()
%  * gradient2(): upwind method
%  * gradient2(): central method
%
% Compare magnitude and direction for the 3 cases
%
%See also: gradient2

disp('TO DO: TEST BY COMPARING TO DEFAULT GRADIENT')
disp('TO DO: ADD ORIGINAL CORNER GRID AS GRAY LINES')

OPT.cd     = fileparts(mfilename('fullpath'));
OPT.export = 1;

OPT.discretisations{1} = 'central';  % gradient2
OPT.discretisations{2} = 'upwind';   % gradient2
OPT.discretisations{3} = 'gradient'; % gradient

for idis=1:length(OPT.discretisations)

   OPT.discretisation = OPT.discretisations{idis};

   [x,y,z] = peaks;
   [xc,yc] = corner2center(x,y);
   
   %% Calculate gradients in all separate triangles.
   %% -----------------------------------
    
   if     strcmp(OPT.discretisation,'gradient')
       [fx  ,fy  ] = gradient(z,x(1,:),y(:,1));
       [fdir,fabs] = cart2pol(fx,fy);
   
   else
   
       [fx  ,fy  ] = gradient2(x,y,z,'discretisation',OPT.discretisation);
       [fdir,fabs] = cart2pol(fx,fy);
   
      map     = triquat(x,y);
      q       = map.quat; % tri     = quat(x,y);
      tri     = map.tri;  % tri     = delaunay(x,y);
   
   end
   
      dz      = max(z(:));
   
   %% Plot mesh
   %-------------------------------------
   
   if ~strcmp(OPT.discretisation,'gradient')
   
      figure('name',['method: ',OPT.discretisation,': mesh']);clf
         [c,h]  = contour2(x,y,z,[-6:2:6]);
         colorbar
         set(gca,'clim',get(gca,'clim'));
         view(0,90)
         hold on
         
         p = trimesh(tri,x,y,z+dz,'FaceColor','none','EdgeColor',[.5 .5 .5]);
         
         [tri.xc,tri.yc,tri.zc] = tri_corner2center(tri,x,y,z);
         
         if strcmp(OPT.discretisation,'central') | ...
            strcmp(OPT.discretisation,'gradient')
         quiver3(x ,y ,zeros(size(y )) + dz,fx,fy,5,'k')
         else
         quiver3(xc,yc,zeros(size(yc)) + dz,fx,fy,5,'k')
         end
         
         axis equal
         title(OPT.discretisation)
         
         if OPT.export
         print2screensize([OPT.cd,filesep,OPT.discretisation,'_mesh']);
         end
         
      end   
   
   %% Plot |grad|
   %-------------------------------------
   
   figure('name',['method: ',OPT.discretisation,': |grad|']);clf
      P = pcolorcorcen(x,y,fabs);
      hold on
      [c,h]  = contour2(x,y,z,[-6:2:6],'k');
   
         if strcmp(OPT.discretisation,'central') | ...
            strcmp(OPT.discretisation,'gradient')
      quiver3(x ,y ,zeros(size(y )) + dz,fx,fy,5,'k')
      else
      quiver3(xc,yc,zeros(size(yc)) + dz,fx,fy,5,'k')
      end
   
      colorbarwithtitle('magnitude')
   
      axis equal
      title(OPT.discretisation)
   
      if OPT.export
      print2screensize([OPT.cd,filesep,OPT.discretisation,'_fabs']);
      end
      
   %% Plot direction(grad)
   %-------------------------------------
   
   figure('name',['method: ',OPT.discretisation,': direction']);clf
      P = pcolorcorcen(x,y,fdir);
      hold on
      [c,h]  = contour2(x,y,z,[-6:2:6],'k');
   
         if strcmp(OPT.discretisation,'central') | ...
            strcmp(OPT.discretisation,'gradient')
      quiver3(x ,y ,zeros(size(y )) + dz,fx,fy,5,'k')
      else
      quiver3(xc,yc,zeros(size(yc)) + dz,fx,fy,5,'k')
      end
   
      caxis([-pi pi])
      colormap(clrmap([1 0 0; 0 1 0; 0 0 1; 1 1 1],4))
      colorbarwithtitle('direction')
   
      axis equal
      title(OPT.discretisation)
      
      if OPT.export
      print2screensize([OPT.cd,filesep,OPT.discretisation,'_fdir']);
      end
      
end % idis=1:length(OPT.discretisations)