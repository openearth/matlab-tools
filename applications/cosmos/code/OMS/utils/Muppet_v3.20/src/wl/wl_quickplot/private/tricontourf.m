function H=tricontourf(tri,x,y,z,v,varargin),
%TRICONTOURF Filled contour plot for triangulated data.
%
%   TRICONTOURF(TRI,X,Y,Z,Levels) fills the areas between (and above
%   the highest and below the lowest) the contours specified in the
%   Levels array. The contour lines can be plotted using the
%   TRICONTOUR command NaN's in the data leave holes in the filled
%   contour plot.
%
%   TRICONTOURF(TRI,X,Y,Z,V,Levels) contouring done based on V
%   instead of Z. This allows contoured data on 3D surfaces.
%
%   H = TRICONTOURF(...) a vector H of handles to PATCH objects,
%   one handle per contourrange. TRICONTOURF is not compatible with
%   CLABEL. The CData field of the patches contains the number of
%   the contour class (1 for the area below the lowest threshold,
%   ... until ... N+1 for the area above the highest threshold).
%
%   Options
%     Return: [ data | {handles} ]
%     ZPlane: ZVal (contours projected on the plane z=ZVal
%     CLevel: [ min | max | index | {classic} ]
%
%   Example
%      x=rand(20); y=rand(20); z=rand(20); tri=delaunay(x,y);
%      thresholds=.3:.1:.8;
%      subplot(2,2,1)
%      tricontourf(tri,x,y,z,thresholds); title('classic'); colorbar
%      subplot(2,2,2)
%      tricontourf(tri,x,y,z,thresholds,'clevel','min');
%      title('min'); classbar(colorbar,thresholds)
%      subplot(2,2,3)
%      tricontourf(tri,x,y,z,thresholds,'clevel','max');
%      title('max'); classbar(colorbar,thresholds,'max')
%      subplot(2,2,4)
%      tricontourf(tri,x,y,z,thresholds,'clevel','index');
%      title('index'); colorbar
%      classbar(colorbar,1:length(thresholds)+1,'labelcolor','label',thresholds)
%
%   See also CONTOUR, CONTOURF, TRICONTOUR

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
