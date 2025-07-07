%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%Extract bounding boxes of TIFF files referenced by <ComplexSource> 
% elements in a VRT file.
%
%INPUT
%   - fpath_vrt = string path to the VRT XML file
%
%OUTPUT
%   - vrtBounds = struct array with fields:
%       Filename = string TIFF filename as referenced in VRT
%       MinX, MaxX, MinY, MaxY = bounding box in spatial coordinates

%
%TODO:
%   -
%
%E.G.


function shp_bounds=SHP_bounding_boxes(fpath_shp)

shp=D3D_io_input('read',fpath_shp);

if isempty(shp.xy.XY)
    error('The shapefile is empty: %s',fpath_shp)
end

MinX=cellfun(@(X)min(X(:,1)),shp.xy.XY);
MinY=cellfun(@(X)min(X(:,2)),shp.xy.XY);
MaxX=cellfun(@(X)max(X(:,1)),shp.xy.XY);
MaxY=cellfun(@(X)max(X(:,2)),shp.xy.XY);

shp_bounds.Filename=fpath_shp;
shp_bounds.MinX=min(MinX);
shp_bounds.MaxX=max(MaxX);
shp_bounds.MinY=min(MinY);
shp_bounds.MaxY=max(MaxY);

end %function
