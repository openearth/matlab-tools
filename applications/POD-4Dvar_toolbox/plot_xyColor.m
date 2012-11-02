function [thefig] = plot_xyColor(x,y,z,themarkersize)
    
    thelineS = colormap;
    hold on;
    
    minZ = min(z);
    maxZ = max(z);

    thecolors = fix((z - minZ)/(maxZ - minZ)*63+1);
    
    for icolor = 1:1:length(thelineS)
        plot(x(thecolors == icolor),y(thecolors == icolor),'.','color',thelineS(icolor,:),'markersize',themarkersize);
    end
    
    clim([minZ maxZ]);
    colorbar;
end