function plot_xyColor(x,y,z,themarkersize)
%   PLOT_XYCOLOR plots three dimensional information into a cartesian plane
%   by drawing the third dimension as a colormap. The results are similar to
%   the ones in SCATTER. Nevertheless this implementation is considerably
%   less computationally demanding, as it only takes into account a 64
%   dimensional colormap. 
%   
%   PLOT_XYCOLOR(X,Y,Z,themarkersize). Vectors X,Y,Z are all of the same
%   size and Z is plotted as color. The markersize determines specifies the
%   size of the marker in the plot(...,'markersize',themarkersize).
%
%   See also: scatter, scatter3, plot, plotmatrix

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   Created by Ivan Garcia
%   email: ivan.garcia@deltares.com

    thelineS = colormap;
    hold on;
    
    minZ = min(z);
    maxZ = max(z);
    
    if minZ == maxZ
        thecolors = ones(length(z),1);
    else
        thecolors = fix((z - minZ)/(maxZ - minZ)*63+1);
    end
    
    for icolor = 1:1:length(thelineS), 
        plot(x(thecolors == icolor),y(thecolors == icolor),'.','color',thelineS(icolor,:),'markersize',themarkersize); 
    end
    
    if minZ ~= maxZ
        clim([minZ maxZ]);
    else
        clim([maxZ maxZ+1]);
    end
    hold off;
end