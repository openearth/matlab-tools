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
%Extract bounding boxes of TIF files
%
%INPUT
%   - fpath_tif = path to tif-file
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


function tif_bounds=TIF_bounding_boxes(fpath_tif)

[~,~,x_vector,y_vector]=TIF_info(fpath_tif);

%structure format must be the same as required in `gdm_ini_2D_mea`
tif_bounds.Filename=fpath_tif;
tif_bounds.MinX=min(x_vector);
tif_bounds.MaxX=max(x_vector);
tif_bounds.MinY=min(y_vector);
tif_bounds.MaxY=max(y_vector);

end %function