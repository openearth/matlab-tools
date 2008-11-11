function [x,y, mappingVarinfo] = netcdfraster2xy(filename)
    % TODO: comment
    fileinfo = nc_info(filename);
    % Look for all 2 dimensional variables because that's the only ones
    % we're merging right now.. TODO: generalize....
    twoDimensionalIndex = cellfun(@length, {fileinfo.Dataset.Dimension})==2;
    variables = fileinfo.Dataset(twoDimensionalIndex);
    if length(variables) ~= 1
        error('not exactly 1 variable found with 2 dimensions');
    end
    varinfo = variables(1);
    
    
    % search through all attributes of the variable for a cf compatible
    % georeferencing
    keys = {varinfo.Attribute.Name};
    values = {varinfo.Attribute.Value};

    % look for a grid mapping
    mappingVariableNames = values(ismember(keys, 'grid_mapping'));
    if length(mappingVariableNames) ~= 1
        error('not exactly 1 mapping variable found');
    end
    mappingVariableName = mappingVariableNames{1};
    mappingVarinfo = nc_getvarinfo(filename, mappingVariableName);
    
 
    % search through the mapping variable for georeference
    % georeferencing
    keys = {mappingVarinfo.Attribute.Name};
    values = {mappingVarinfo.Attribute.Value};
    
    % look for a gdal compatible geotransform attribute. If there is
    % such an attribute we can calculate X variables.
    %     
    % The coefficients for transforming between pixel/line (X,Y) raster space, and projection coordinates (Xp,Yp) space.
    % Xp = T[0] + T[1]*X + T[2]*Y
    % Yp = T[3] + T[4]*X + T[5]*Y
    % In a north up image, T[1] is the pixel width, and T[5] is the pixel height. The upper left corner of the upper left pixel is at position (T[0],T[3]).
    geoTransformStrings = values(ismember(keys, 'GeoTransform'));
    if length(geoTransformStrings) ~= 1
        error('not exactly 1 geoTransform variable found');
    end
    geoTransform = str2num(geoTransformStrings{1});
    % use short names here
    T = geoTransform;
    % Matlab maptoolbox compatible way;
    % Xp = R(3,1) + R(1,1)*X + R(2,1)*Y
    % Yp = R(3,2) + R(1,2)*X + R(2,2)*Y
    
    R = [T(2:3) T(1); T(5:6) T(4)]';
    
%     assume y,x
    ny = varinfo.Size(1);
    nx = varinfo.Size(2);

    %% Calculate X and Y Coordinates
    if R(2,1) == 0 && R(1,2) == 0
        % we have a grid which is not rotated (north up). We can store x and y  as a
        % vector
        x = 0:nx-1;
        y = 0:ny-1;

        xp = R(3,1) + R(1,1)*x;
        yp = R(3,2) + R(2,2)*y;
    else
        % We have a rotated grid and we need to store values for each x and
        % TODO: store information for rotated grid......
        % someting like....
        for x = 0:nx-1
            y = 0:ny-1;
            xp = R(3,1) + R(1,1)*x + R(2,1)*y;
            yp = R(3,2) + R(1,2)*x + R(2,2)*y;
        end
        % But I dont have enough memory in this pc to test it.....
        % TODO: expand to rotated grid
        error('rotated grid found, doesnt work....');
    end
    x = xp;
    y = yp;
end