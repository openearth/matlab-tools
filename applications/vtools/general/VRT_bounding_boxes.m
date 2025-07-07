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


function vrt_bounds=VRT_bounding_boxes(fpath_vrt)

% Read the VRT XML
xDoc = xmlread(fpath_vrt);

% Get the global GeoTransform element and parse it
gtNodeList = xDoc.getElementsByTagName('GeoTransform');
if gtNodeList.getLength == 0
    error('No GeoTransform element found in VRT file.');
end
gtText = char(gtNodeList.item(0).getTextContent);
gt = sscanf(gtText, '%f, %f, %f, %f, %f, %f');

% Find all ComplexSource elements
complexSources = xDoc.getElementsByTagName('ComplexSource');
nSources = complexSources.getLength;

vrt_bounds = struct('Filename', {}, 'MinX', {}, 'MaxX', {}, 'MinY', {}, 'MaxY', {});

for k = 0:nSources-1
    source = complexSources.item(k);
    
    % Get SourceFilename
    filenameNode = source.getElementsByTagName('SourceFilename').item(0);
    if isempty(filenameNode)
        warning('ComplexSource #%d missing SourceFilename; skipping.', k+1);
        continue;
    end
    filename = char(filenameNode.getTextContent);
    
    % Get DstRect
    dstRectNode = source.getElementsByTagName('DstRect').item(0);
    if isempty(dstRectNode)
        warning('ComplexSource #%d missing DstRect; skipping.', k+1);
        continue;
    end
    xOff_dst = str2double(dstRectNode.getAttribute('xOff'));
    yOff_dst = str2double(dstRectNode.getAttribute('yOff'));
    xSize_dst = str2double(dstRectNode.getAttribute('xSize'));
    ySize_dst = str2double(dstRectNode.getAttribute('ySize'));
    
    % Calculate pixel corners in destination (VRT) space
    cornersDstPx = [
        xOff_dst,           yOff_dst;
        xOff_dst + xSize_dst, yOff_dst;
        xOff_dst,           yOff_dst + ySize_dst;
        xOff_dst + xSize_dst, yOff_dst + ySize_dst];
    
    % Convert these pixel coords to geospatial coordinates using GeoTransform
    coords = zeros(4,2);
    for i = 1:4
        px = cornersDstPx(i,1);
        ln = cornersDstPx(i,2);
        X = gt(1) + px*gt(2) + ln*gt(3);
        Y = gt(4) + px*gt(5) + ln*gt(6);
        coords(i,:) = [X, Y];
    end
    
    % Compute bounding box from corner coordinates
    minX = min(coords(:,1));
    maxX = max(coords(:,1));
    minY = min(coords(:,2));
    maxY = max(coords(:,2));
    
    % Save results in output struct
    vrt_bounds(k+1).Filename = filename;
    vrt_bounds(k+1).MinX = minX;
    vrt_bounds(k+1).MaxX = maxX;
    vrt_bounds(k+1).MinY = minY;
    vrt_bounds(k+1).MaxY = maxY;
end

end %function