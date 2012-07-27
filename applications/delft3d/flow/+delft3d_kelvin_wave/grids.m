function G = grids(grdlayout,varargin)
%delft3d_kelvin_wave.grids   collection of orthogonal kelvin wave grids
%
%  G = delft3d_kelvin_wave_grids(grdlayout,<G>)
%
% where grdlayout is a specific size and lay-out of a coastal
% (Kelvin wave) rectangular non-equidistant grid
%
% G has fields
%
% * xcor: / grid cell (control volume) corners, without
% * ycor: \ Delft3D-specific dummy rows
% * dep:   depth at corners
%
%See also: delft3d_kelvin_wave

   if nargin>1
      G = varargin{1};
   end

   U.grdlayout = grdlayout;
   U.save      = '';
   U.D0        = 10;
   
   U = setproperty(U,varargin{:});
   
   switch U.grdlayout
   
   case 1 % rectangular
      
      G.x0            = -100e3;
      G.dx            = 2e3;
      G.x1            = 0e3;
      
      G.y0            = 0e3;
      G.dy            = 2e3;
      G.y1            = 200e3;
      
      G.ix            = G.x0:G.dx:G.x1;
      G.iy            = G.y0:G.dy:G.y1;
   
      G.dep           = U.D0.*ones(length(G.ix),length(G.iy));

      [G.xcor,G.ycor]         = meshgrid(G.ix, G.iy);

   case 2 % 3x 3 test
   
      G.x0            = -500;
      G.dx            = 1000;
      G.x1            = 3000;
      
      G.y0            = -500;
      G.dy            = 1000;
      G.y1            = 3000;
      
      G.ix            = G.x0:G.dx:G.x1;
      G.iy            = G.y0:G.dy:G.y1;
      
      G.dep           = U.D0.*ones(length(G.ix),length(G.iy));
      
      [G.xcor,G.ycor]         = meshgrid(G.ix, G.iy);

   case 5 % plume basin stretched at west and north
          % origin in lower left in ocean
      
      G.dx            = 500;
      G.dy            = 500;
   
      G.ix0           = [1:130 ];
      G.iy0           = [1:210 ];
   
      G.ix            = [cumsum(1.25.^[25:-1:1]) max(cumsum(1.25.^[25:-1:1])) + G.ix0].*G.dx;
      %G.ix            = 0 - [G.ix0 max(G.ix0) + cumsum(1.25.^[1:25])].*G.dx;
      %G.ix            = fliplr(G.ix);
      G.iy            = [G.iy0 max(G.iy0) + cumsum(1.25.^[1:25])].*G.dy;
      %G.ix            = [G.ix0 max(G.ix0)].*G.dx;
      %G.iy            = [G.iy0 max(G.iy0)].*G.dy;
      
      disp(['Increase # cells: ',num2str((size(G.ix).*size(G.iy))/(size(G.ix0).*size(G.iy0)))])
      
      [G.xcor,G.ycor]         = meshgrid(G.ix, G.iy);
      
   case 30 

          % plume basin NOT stretched
          % origin in lower right at coast, x has negative values
          % one row removed in south to allow for nesting with 3 surrounding overall points.
          %
          %          ####
          %          ####
          %          ####
          %          ###+ Origin
          
          % This grid is made to test Neumann by nesting it in
          % the grtid descrbied below in case 3.
          
      
      G.dx            = 500;
      G.dy            = 500;
   
      G.ix0           = [1:130 ];
      G.iy0           = [2:210 ];
   
      G.ix            = 0 - [G.ix0].*G.dx;
      G.ix            = fliplr(G.ix);
      G.iy            = [G.iy0].*G.dy;
      
      disp(['Increase # cells: ',num2str((size(G.ix).*size(G.iy))/(size(G.ix0).*size(G.iy0)))])
   
      [G.cor.x,G.cor.y]         = meshgrid(G.ix, G.iy);
      
      case 33 
          
          % plume basin stretched at west and north
          % origin in lower right at coast, x has negative values
          %
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::####
          %  ::::::::####
          %  ::::::::####
          %  ::::::::###+ Origin
      
      G.dx            = 500;
      G.dy            = 500;
   
      G.ix0           = [1:130 ];
      G.iy0           = [1:210 ];
   
      G.ix            = 0 - [G.ix0 max(G.ix0) + cumsum(1.25.^[1:25])].*G.dx;
      G.ix            = fliplr(G.ix);

      G.iy            = [G.iy0 max(G.iy0) + cumsum(1.25.^[1:25])].*G.dy;
      
      disp(['Increase # cells: ',num2str((size(G.ix).*size(G.iy))/(size(G.ix0).*size(G.iy0)))])
   
      [G.cor.x,G.cor.y]         = meshgrid(G.ix, G.iy);

      case 330
          
          % plume basin stretched a little at west and north
          % at the south the model is padded, but not stretched
          % origin in lower right at coast, x has negative values
          %
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::####
          %  ::::::::####
          %  ::::::::####
          %  ::::::::###+ Origin
          %  ::::::::#### to prevent erronous eccentricities on and above
          %  ::::::::#### the horizontal line through origin, and to prevent
          %               easterly winds from pushing the bulge against and 
          %               through the southern boundary. Note that this will
          %               generate some (additional) M4 at the origin.
      
      G.dx            = 500;
      G.dy            = 500;
   
      G.ix0           = [1:130 ];
      G.iy0           = [-120:210];
   
      G.ix            = 0 - [G.ix0 max(G.ix0) + cumsum(1.25.^[1:25])].*G.dx;
      G.ix            = fliplr(G.ix);

      G.iy            = [G.iy0 max(G.iy0) + cumsum(1.25.^[1:25])].*G.dy;
      
      disp(['Increase # cells: ',num2str((size(G.ix).*size(G.iy))/(size(G.ix0).*size(G.iy0)))])
   
      [G.cor.x,G.cor.y]         = meshgrid(G.ix, G.iy);

      case 331
          
          % plume basin a little at west and north
          % at the south the model is strethed just a little
          %
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::####
          %  ::::::::####
          %  ::::::::####
          %  ::::::::###+ Origin
          %  ::::::::####
          %  :::::::::::: to prevent erronous eccentricities on and above
          %  ::::::::#### the horizontal line through origin
      
      G.dx            = 500;
      G.dy            = 500;
   
      G.ix0           = [1:130 ];
      G.iy0           = [0:210];
   
      G.ix            = 0 - [G.ix0 max(G.ix0) + cumsum(1.25.^[1:25])].*G.dx;
      G.ix            = fliplr(G.ix);

     %stretch('nf2s',26,1.1300,'base',1)
     %G.iy            = [-fliplr(cumsum(1.25.^[1:25])) G.iy0 max(G.iy0) + cumsum(1.25.^[1:25])].*G.dy;
      G.iy            = [-fliplr(cumsum(1.13.^[1:25])) G.iy0 max(G.iy0) + cumsum(1.25.^[1:25])].*G.dy;
      
   
      disp(['Increase # cells: ',num2str((size(G.ix).*size(G.iy))/(size(G.ix0).*size(G.iy0)))])
   
      [G.xcor,G.ycor]         = meshgrid(G.ix, G.iy);


   case 333 % plume basin stretched at west and north
   
          % AND SOUTH
          % origin lower right at coast, x has negative values
          %
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::####
          %  ::::::::####
          %  ::::::::####
          %  ::::::::###+ Origin
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
          %  ::::::::::::
      
      G.dx            = 500;
      G.dy            = 500;
   
      G.ix0           = [1:130 ];
      G.iy0           = [1:210 ];
   
      G.ix            = 0 - [G.ix0 max(G.ix0) + cumsum(1.25.^[1:25])].*G.dx;
      G.ix            = fliplr(G.ix);

      G.iy            = [-fliplr(cumsum(1.25.^[1:25])) G.iy0 max(G.iy0) + cumsum(1.25.^[1:25])].*G.dy;
      
      disp(['Increase # cells: ',num2str((size(G.ix).*size(G.iy))/(size(G.ix0).*size(G.iy0)))])
   
      [G.xcor,G.ycor]         = meshgrid(G.ix, G.iy);

   case 4
      
      G.dx            =  500;
      G.dy            = 1000;
   
      G.ix           = [1:100].*G.dx;
      G.iy           = [1:100].*G.dy;
      
      [G.xcor,G.ycor]         = meshgrid(G.ix, G.iy);
      
   case 300
   
      % Deform grid to test validity of curvilinearity
      
      G.dx            = 500;
      G.dy            = 500;
   
      G.ix0           = [1:130 ];
      G.iy0           = [1:210 ];
      
      [G.iX,G.iY]     = meshgrid((G.ix0-1)./(max(G.ix0)-1),...
                                 (G.iy0-1)./(max(G.iy0)-1)); % ranging form [0,1] so including 0 and 1!
      
      G.dXmax = G.dx.*10;
      G.dYmax = G.dy.*10;
      
      G.dX = G.dXmax.*sin(pi.*G.iX).^2.*sin(   pi.*G.iY).^2;
      G.dY = G.dYmax.*sin(pi.*G.iX).^2.*sin(2.*pi.*G.iY).^2;
   
     %G.ix            = [cumsum(1.25.^[25:-1:1]) max(cumsum(1.25.^[25:-1:1])) + G.ix0].*G.dx;
      G.ix            = 0 - [G.ix0 max(G.ix0) + cumsum(1.25.^[1:25])].*G.dx;
      G.ix            = fliplr(G.ix);
      G.iy            = [G.iy0 max(G.iy0) + cumsum(1.25.^[1:25])].*G.dy;
     %G.ix            = [G.ix0 max(G.ix0)].*G.dx;
     %G.iy            = [G.iy0 max(G.iy0)].*G.dy;
      
      disp(['Increase # cells: ',num2str((size(G.ix).*size(G.iy))/(size(G.ix0).*size(G.iy0)))])      
   
      [G.X,G.Y]         = meshgrid(G.ix, G.iy);
      
      G.X(1:end-25,26:end) = G.X(1:end-25,26:end) - G.dX;
      G.Y(1:end-25,26:end) = G.Y(1:end-25,26:end) - G.dY;
      pcolor(G.xcor,G.ycor,G.xcor)
      axis equal
      axis([-70e3 0 0 100e3]);
      

   case 6
   
   % Walters bakkie
   
      G.x0            = -250;
      G.dx            = 500;
      G.x1            = 138.*G.dx;
      
      G.y0            = -250;
      G.dy            = 500;
      G.y1            = 198.*G.dy;
      
      G.ix            = G.x0:G.dx:G.x1;
      G.iy            = G.y0:G.dy:G.y1;
   
      [G.xcor,G.ycor]         = meshgrid(G.ix, G.iy);
      
   case 7
   
   % Walters bakkie met dikke rand
   
      G.x0            = -250;
      G.dx            = 500;
      G.x1            = 138.*G.dx;
      
      G.y0            = -250;
      G.dy            = 500;
      G.y1            = 198.*G.dy;
      
      G.ix0           = G.x0:G.dx:G.x1;
      G.iy0           = G.y0:G.dy:G.y1;
   
      G.ix            = [         fliplr(-cumsum(1.25.^[1:1:25])).*G.dx G.ix0];
      G.iy            = [G.iy0 max(G.iy0)+cumsum(1.25.^[1:1:25]).*G.dy];

      [G.xcor,G.ycor]         = meshgrid(G.ix, G.iy);
      
   otherwise
      
         error([num2str(U.grdlayout),' is no valid layout'])
      
   end
   
   %% Make sure 1st index is mmax
   
   G.cor.x            = G.cor.x';
   G.cor.y            = G.cor.y';
   
   %% Get size
   
   G.mmax            = length(G.ix) + 1; % FLOW expects 1 dummy row and column
   G.nmax            = length(G.iy) + 1; % FLOW expects 1 dummy row and column

   %% Get centers
   
   if ~isfield(G,'cen')
      G.cen.x = corner2center(G.cor.x);
      G.cen.y = corner2center(G.cor.y);
   end  
   
   if ~isempty(U.save)
      delft3d_io_grd('write',U.save,G.cor.x,G.cor.y);
   end

%% EOF