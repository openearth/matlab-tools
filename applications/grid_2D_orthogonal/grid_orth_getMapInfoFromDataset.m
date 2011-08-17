function OPT = grid_orth_getMapInfoFromDataset(dataset)
%GRID_ORTH_GETMAPINFOFROMDATASET  Extracts meta info from an OPeNDAP catalog or a local directory.
%
%   OPT = grid_orth_getmapinfofromdataset(url)
%
% extract meta info from an OPeNDAP catalog or a local directory.
%
%See also: GRID_2D_ORTHOGONAL

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $
  
OPT.dataset = dataset;

disp('Retrieving map info from dataset ...')

% check for catalog.nc link
if strcmpi(OPT.dataset(end-9:end),'catalog.nc')
    
    OPT.catalognc = OPT.dataset;
    OPT.urls = cellstr([nc_varget(OPT.dataset,'urlPath')]);
    
    % temporary fix of very weird bug!!! Occasionally the char matrix or urlPaths in
    % the catalog nc gets flipped!!!! If this happens flip it back.
    if ~strcmp(OPT.urls{1}(end-2:end),'.nc')
        OPT.urls = cellstr(char(OPT.urls)');
    end    
else
    OPT.urls     = opendap_catalog(OPT.dataset,'ignoreCatalogNc',0);
    isCatalogNc = false(length(OPT.urls),1);
    for ii = 1:length(OPT.urls)
        isCatalogNc(ii) = strcmpi(OPT.urls{ii}(end-9:end),'catalog.nc');
    end
    if any(isCatalogNc)
        OPT.catalognc = OPT.urls{isCatalogNc};
        OPT.urls(isCatalogNc) = [];
    end
end

if isfield(OPT,'catalognc')
    try 
        nc_varget(OPT.catalognc,'projectionCoverage_x');
    catch
        disp('there is a catalog nc, but it doens''t have the new projectionCoverage_x variable, so it cannot be used to speed up the tedious process of getting all the boundaries of the nc files')
        OPT = rmfield(OPT,'catalognc');
    end
end

if isfield(OPT,'catalognc')
    x_ranges = nc_varget(OPT.catalognc,'projectionCoverage_x'); % should be [n x 2], same as slow method.
    y_ranges = nc_varget(OPT.catalognc,'projectionCoverage_y');
    for i=1:size(x_ranges,1)
    OPT.x_ranges{i} = x_ranges(i,:);
    OPT.y_ranges{i} = y_ranges(i,:);
    end
else
    %% slow method for if there is no catalog nc
    wbh = waitbar(0,'Please wait ...');
    varname_x = nc_varfind(OPT.urls{1}, 'attributename','standard_name','attributevalue','projection_x_coordinate');
    varname_y = nc_varfind(OPT.urls{1}, 'attributename','standard_name','attributevalue','projection_y_coordinate');
    for i = 1:length(OPT.urls)
        waitbar(i/length(OPT.urls), wbh, 'Extracting map outlines from nc files ...')

        OPT.x_ranges{i} = sort(nc_actual_range(OPT.urls{i}, varname_x));
        OPT.y_ranges{i} = sort(nc_actual_range(OPT.urls{i}, varname_y));
        
    end
    close(wbh)
end
