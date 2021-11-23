%% test script for msk=sfincs_make_mask_advanced(x,y,z,varargin)
% Leijnse nov 21: complete revisit of code

clear all
close all
clc

%% Settings
test_determine_active_grid = 1;
test_determine_boundary_cells = 0;

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

end
