function delft3d_3d_visualisation_example(varargin)
%DELFT3D_3D_VISUALISATION_EXAMPLE   example to make 3D graphics from delft3d trim file
%
%See also: VS_MESHGRID3DCORCEN, VS_TIME, VS_LET_SCALAR, VS_LET_VECTOR_CEN

%% settings

   OPT.fname   = 'F:\DELFT3D\PECS\tide_neap_wind\trim-p77.def';
   OPT.export  = 1;
   OPT.pause   = 0;
   OPT.uvscale = 1e4; % 1 m/s becomes x m
   OPT.wscale  = 2e3; % 1 m/s becomes x m
   OPT.axis    = [-50e3 0 0 100e3 -20 2];
   OPT.clim    = [30 35];
   OPT.dm      =  5; % cross shore
   OPT.dn      = 25; % along shore
   OPT.dk      = 3;  % sigma layers
   % plot not all point as matlab is too slow for that,
   % and the human mind too limited
 
%% settings

   H = vs_use (OPT.fname);
   T = vs_time(H);
   G = vs_meshgrid2dcorcen(H);
   
   G.cen.dep =-20 + 0.*G.cen.x; % error: No sensible depth data on trim file.
   
   for it=2:T.nt_storage % NOTE: vertical velocity is ALWAYS 0 1st timestep, so we start with step 2
   
   %% load 3D data, incl time-varying grid

      % grid, incl waterlevel which determines z grid spacing
      G                = vs_meshgrid3dcorcen     (H, it, G);
   
      % dissolves substances
      I                = vs_get_constituent_index(H, 'salinity');
      D.cen.salinity   = vs_let_scalar           (H,'map-series',{it}, 'R1'      , {0,0,0,I.index});
   
      % horizontal velocities
     [D.cen.u,D.cen.v] = vs_let_vector_cen       (H,'map-series',{it},{'U1','V1'}, {0,0,0});
      
      % vertical velocity
      D.cen.w          = vs_let_scalar           (H,'map-series',{it}, 'WPHY'    , {0,0,0,});
     
      hold off 
      
      dn = OPT.dn;
      dm = OPT.dm;
      dk = OPT.dk;

   %% 3D velocity field

      h.q = quiver3(G.cen.cent.x(  1:dn:end,1:dm:end,:),...
                    G.cen.cent.y(  1:dn:end,1:dm:end,:),...
                    G.cen.cent.z(  1:dn:end,1:dm:end,:),...
                 permute(D.cen.u(1,1:dn:end,1:dm:end,:),[2 3 4 1]).*OPT.uvscale,...
                 permute(D.cen.v(1,1:dn:end,1:dm:end,:),[2 3 4 1]).*OPT.uvscale,...
                         D.cen.w(  1:dn:end,1:dm:end,:)           .*OPT.wscale,0,'k');
      hold on
      
   %% horizontal scalar slices

      for k=1:dk:G.kmax
      h.s = surf(permute(G.cen.cent.x  (:,:,k),[1 2 3]),...
                 permute(G.cen.cent.y  (:,:,k),[1 2 3]),...
                 permute(G.cen.cent.z  (:,:,k),[1 2 3]),...
                 permute(D.cen.salinity(:,:,k),[1 2 3]));
                 
      end
   
   %% vertical scalar slices

      for n=1:dn:G.nmax
      
      h.s = surf(permute(G.cen.cent.x  (n,:,:),[2 3 1]),...
                 permute(G.cen.cent.y  (n,:,:),[2 3 1]),...
                 permute(G.cen.cent.z  (n,:,:),[2 3 1]),...
                 permute(D.cen.salinity(n,:,:),[2 3 1]));
      
      end
      
   %% lay-out

      axis   (OPT.axis)
      grid    on
      title  (datestr(T.datenum(it)))
      set    (gca,'dataAspectRatio',[1 1 5e-4])
      view   (40,30)
      set    (h.q,'clipping','on')
      set    (h.s,'clipping','on')
      caxis  (OPT.clim)
      alpha  (0.5)
      tickmap('xy')
      shading interp
      colorbarwithtitle('salinity')
      
      if OPT.export
      print2screensize([fileparts(H.DatExt),filesep,'salinity_',num2str(it,'%0.2d')])
      end
   
      if OPT.pause
      pausedisp
      end
      
   end
   
%% EOF