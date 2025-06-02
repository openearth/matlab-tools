%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17760 $
%$Date: 2022-02-14 10:51:28 +0100 (Mon, 14 Feb 2022) $
%$Author: chavarri $
%$Id: readgeotiff.m 17760 2022-02-14 09:51:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/readgeotiff.m $
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
