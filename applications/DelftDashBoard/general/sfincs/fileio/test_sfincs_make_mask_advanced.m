%% test script for msk=sfincs_make_mask_advanced(x,y,z,varargin)
% Leijnse nov 21: complete revisit of code

clear all
close all
clc

%% Settings
test_determine_active_grid = 0;
test_determine_boundary_cells = 1;

%% Domain

x = 0:100:1000;
y = 0:100:500;
zz = linspace(-5,20,length(x));

z = repmat(zz, length(y),1);

[x,y] = meshgrid(x,y);

%% tests for determining active_grid

if test_determine_active_grid == 1
        
    %% test not specifying anything
    msk=sfincs_make_mask_advanced(x,y,z);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    title(['Mask using no criteria'])


    %% test only zlev
    zlev = [0,15];
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), ']'])

    %% test only include polygon
    clear xy_poly
    xy_poly(1).x = [x(1,1), x(1,end), x(end,end), x(end,1)];
    xy_poly(1).y = [y(1,1), y(1,end), y(end,end), y(end,1)];

    msk=sfincs_make_mask_advanced(x,y,z,'includepolygon',xy_poly);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    title(['Mask using include polygon full grid'])

    %% test only 2 include polygons
    clear xy_poly
    xy_poly(1).x = [x(1,1), x(1,3), x(end,3), x(end,1)];
    xy_poly(1).y = [y(1,1), y(1,3), y(end,3), y(end,1)];

    xy_poly(2).x = [x(2,5), x(2,7), x(5,7), x(5,5)];
    xy_poly(2).y = [y(2,5), y(2,7), y(5,7), y(5,5)];

    msk=sfincs_make_mask_advanced(x,y,z,'includepolygon',xy_poly);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly(2).x,xy_poly(2).y,'r')
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly(2).x,xy_poly(2).y,'r')
    title(['Mask using 2 include polygons'])

    %% test only include > then exclude polygon
    clear xy_poly xy_poly_ex
    xy_poly(1).x = [x(1,1), x(1,3), x(end,3), x(end,1)];
    xy_poly(1).y = [y(1,1), y(1,3), y(end,3), y(end,1)];

    xy_poly_ex(1).x = [x(2,3), x(2,7), x(5,7), x(5,3)];
    xy_poly_ex(1).y = [y(2,3), y(2,7), y(5,7), y(5,3)];

    msk=sfincs_make_mask_advanced(x,y,z,'includepolygon',xy_poly,'excludepolygon',xy_poly_ex);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly_ex(1).x,xy_poly_ex(1).y,'r')
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly_ex(1).x,xy_poly_ex(1).y,'r')
    title(['Mask using include then overlapping exclude'])

    %% test only exclude > then include polygon

    msk=sfincs_make_mask_advanced(x,y,z,'excludepolygon',xy_poly_ex,'includepolygon',xy_poly);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly_ex(1).x,xy_poly_ex(1).y,'r')
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly_ex(1).x,xy_poly_ex(1).y,'r')
    title(['Mask using exclude then overlapping include'])

    %% test zlev then include then exclude

    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'excludepolygon',xy_poly_ex,'includepolygon',xy_poly);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly_ex(1).x,xy_poly_ex(1).y,'r')
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly_ex(1).x,xy_poly_ex(1).y,'r')
    title(['Mask using elevation then exclude then overlapping include'])

    %% test include then zlev
    msk=sfincs_make_mask_advanced(x,y,z,'excludepolygon',xy_poly_ex,'includepolygon',xy_poly,'zlev',zlev);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz)));
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly_ex(1).x,xy_poly_ex(1).y,'r')
    
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_poly(1).x,xy_poly(1).y,'k')
    plot(xy_poly_ex(1).x,xy_poly_ex(1).y,'r')
    title(['Mask using exclude then overlapping include then elevation'])

end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% tests for determining boundary_cells (msk=1/2/3)
if test_determine_boundary_cells == 1

    
    %% test only zlev > no msk=2 should be made
    zlev = [0,15];
    zlev_polygon = 5; %(default)
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > no msk=2 should be made'])    
    
    %% test only zlev with backwards compatible 
    zlev = [0,15];
    zlev_polygon = 5; %(default)
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'backwards_compatible',1);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > msk=2 should be made at zlev values'])    
            
    %% test only zlev with waterlevelboundarypolygon 
    zlev = [0,15];
    zlev_polygon = 5; %(default)
    
    clear xy_bnd_outflow xy_bnd_waterlevel
    xy_bnd_waterlevel(1).x = [x(1,1), x(1,3), x(end,3), x(end,1)];
    xy_bnd_waterlevel(1).y = [y(1,1), y(1,3), y(end,3), y(end,1)];
    
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'waterlevelboundarypolygon',xy_bnd_waterlevel);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'k')    
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'k')
    
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > msk=2 should be made only at offshore boundary'])    
    
    %% test only zlev with waterlevelboundarypolygon and zlev_polygon = -1 > no msk=2 should happen
    zlev = [0,15];
    zlev_polygon = -1; %(default)
    
    clear xy_bnd_outflow xy_bnd_waterlevel
    xy_bnd_waterlevel(1).x = [x(1,1), x(1,3), x(end,3), x(end,1)];
    xy_bnd_waterlevel(1).y = [y(1,1), y(1,3), y(end,3), y(end,1)];
    
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'waterlevelboundarypolygon',xy_bnd_waterlevel);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'k')    
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'k')
    
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > msk=2 should be made nowhere'])    
        
    %% test only zlev with outflowboundarypolygon and low polygon > msk=3 should occur at z=15m
    zlev = [0,15];
    zlev_polygon = 5; %(default)
        
    clear xy_bnd_outflow xy_bnd_waterlevel
    xy_bnd_outflow(1).x = [x(1,1), x(1,end), x(end,end), x(end,1)];
    xy_bnd_outflow(1).y = [y(1,1), y(1,end), y(end,end), y(end,1)];
    
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'outflowboundarypolygon',xy_bnd_outflow);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')    
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')
    
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > msk=3 should be made at z=15m'])    
   
    %% test only zlev with outflowboundarypolygon and low polygon > msk=3 should occur nowhere
    zlev = [0,15];
    zlev_polygon = 20; %(default)
        
    clear xy_bnd_outflow xy_bnd_waterlevel
    xy_bnd_outflow(1).x = [x(1,1), x(1,end), x(end,end), x(end,1)];
    xy_bnd_outflow(1).y = [y(1,1), y(1,end), y(end,end), y(end,1)];
    
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'outflowboundarypolygon',xy_bnd_outflow);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')    
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')
    
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > msk=3 should be made nowhere'])  
    
    %% test only zlev with outflowboundarypolygon zlev_polygon = -1 > msk=3 should occur at z=0&15m
    zlev = [0,15];
    zlev_polygon = -1; %(default)
        
    clear xy_bnd_outflow xy_bnd_waterlevel
    xy_bnd_outflow(1).x = [x(1,1), x(1,end), x(end,end), x(end,1)];
    xy_bnd_outflow(1).y = [y(1,1), y(1,end), y(end,end), y(end,1)];
    
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'outflowboundarypolygon',xy_bnd_outflow);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')    
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')
    
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > msk=3 should be made at z=0&15m'])  
    
    %% test only zlev with outflowboundarypolygon and low polygon > no msk=3 should occur
    zlev = [0,15];
    zlev_polygon = 5; %(default)
        
    clear xy_bnd_outflow xy_bnd_waterlevel
    xy_bnd_outflow(1).x = [x(1,1), x(1,3), x(end,3), x(end,1)];
    xy_bnd_outflow(1).y = [y(1,1), y(1,3), y(end,3), y(end,1)];
    
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'outflowboundarypolygon',xy_bnd_outflow);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')    
    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')
    
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > msk=3 should be made nowhere'])    
    
    %% test only zlev with outflowboundarypolygon and zlev_polygon = 5 PLUS waterlevelboundarypolygon > msk=2 should occur at z=0m and msk=3 should occur at z=15m
    zlev = [0,15];
    zlev_polygon = 5; %(default)
        
    clear xy_bnd_outflow xy_bnd_waterlevel
    xy_bnd_outflow(1).x = [x(1,1), x(1,end), x(end,end), x(end,1)];
    xy_bnd_outflow(1).y = [y(1,1), y(1,end), y(end,end), y(end,1)];
    
    xy_bnd_waterlevel(1).x = [x(1,1), x(1,3), x(end,3), x(end,1)];
    xy_bnd_waterlevel(1).y = [y(1,1), y(1,3), y(end,3), y(end,1)];
    
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'waterlevelboundarypolygon',xy_bnd_waterlevel,'outflowboundarypolygon',xy_bnd_outflow);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')    
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'r')    

    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'r')    
    
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > msk=2 should be made at z=0m plus  msk=3 should be made at z=15m'])  
    
    %% test only zlev with outflowboundarypolygon and zlev_polygon = 5 PLUS waterlevelboundarypolygon PLUS overruling closeboundary > msk=2 should occur at z=0m and msk=3 should occur at z=15m and msk=1 at lowest cells
    zlev = [0,15];
    zlev_polygon = 5; %(default)
        
    clear xy_bnd_outflow xy_bnd_waterlevel xy_bnd_closed
    xy_bnd_outflow(1).x = [x(1,1), x(1,end), x(end,end), x(end,1)];
    xy_bnd_outflow(1).y = [y(1,1), y(1,end), y(end,end), y(end,1)];
    
    xy_bnd_waterlevel(1).x = [x(1,1), x(1,3), x(end,3), x(end,1)];
    xy_bnd_waterlevel(1).y = [y(1,1), y(1,3), y(end,3), y(end,1)];
    
    xy_bnd_closed(1).x = [x(1,1), x(1,end), x(3,end), x(3,1)];
    xy_bnd_closed(1).y = [y(1,1), y(1,end), y(3,end), y(3,1)];
    
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'waterlevelboundarypolygon',xy_bnd_waterlevel,'outflowboundarypolygon',xy_bnd_outflow,'closedboundarypolygon',xy_bnd_closed);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')    
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'r')    
    plot(xy_bnd_closed(1).x,xy_bnd_closed(1).y,'c')    

    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'r')    
    plot(xy_bnd_closed(1).x,xy_bnd_closed(1).y,'c')    
    
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > msk=2 should be made at z=0m plus  msk=3 should be made at z=15m PLUS overruling closeboundary in lowest cells'])  
      
    %% test only zlev with outflowboundarypolygon and zlev_polygon = 5 PLUS waterlevelboundarypolygon PLUS overruling closeboundary > msk=2 should occur at z=0m and msk=3 should occur at z=15m and msk=1 at lowest cells
    zlev = [0,15];
    zlev_polygon = 5; %(default)
        
    clear xy_bnd_outflow xy_bnd_waterlevel xy_bnd_closed
    xy_bnd_outflow(1).x = [x(1,1), x(1,end), x(end,end), x(end,1)];
    xy_bnd_outflow(1).y = [y(1,1), y(1,end), y(end,end), y(end,1)];
    
    xy_bnd_waterlevel(1).x = [x(1,1), x(1,3), x(end,3), x(end,1)];
    xy_bnd_waterlevel(1).y = [y(1,1), y(1,3), y(end,3), y(end,1)];
    
    xy_bnd_closed(1).x = [x(1,1), x(1,end), x(3,end), x(3,1)];
    xy_bnd_closed(1).y = [y(1,1), y(1,end), y(3,end), y(3,1)];
    
    msk=sfincs_make_mask_advanced(x,y,z,'zlev',zlev,'zlev_polygon',zlev_polygon,'closedboundarypolygon',xy_bnd_closed,'waterlevelboundarypolygon',xy_bnd_waterlevel,'outflowboundarypolygon',xy_bnd_outflow);

    figure; 
    subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')    
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'r')    
    plot(xy_bnd_closed(1).x,xy_bnd_closed(1).y,'c')    

    subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
    plot(xy_bnd_outflow(1).x,xy_bnd_outflow(1).y,'k')
    plot(xy_bnd_waterlevel(1).x,xy_bnd_waterlevel(1).y,'r')    
    plot(xy_bnd_closed(1).x,xy_bnd_closed(1).y,'c')    
    
    title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), '] > closeboundary in lowest cells should be overruled by msk=2 should be made at z=0m plus  msk=3 should be made at z=15m'])  
    
    %%
end

% test of how function will be called in DDB with 1 single cell:

varargin{1} = 'zlev';
varargin{2} = zlev;

xy_bnd_closed = [];

msk=sfincs_make_mask_advanced(x,y,z,varargin);

figure; 
subplot(2,1,1); hold on; axis equal; scatter(x(:),y(:),[],z(:),'filled'); shading flat; colorbar('Ticks',zz); colormap(parula(length(zz))) %();
subplot(2,1,2); hold on; axis equal; scatter(x(:),y(:),[],msk(:),'filled'); shading flat; colorbar('Ticks',0:3); clim([0 3])
title(['Mask using zlev= [',num2str(zlev(1)), ',',num2str(zlev(2)), ']'])


