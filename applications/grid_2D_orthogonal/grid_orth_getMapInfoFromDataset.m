function OPT = grid_orth_getMapInfoFromDataset(dataset)
%GRID_ORTH_GETMAPINFOFROMDATASET
%
%   OPT = grid_orth_getmapinfofromdataset(url)
%
% extract meta info from an OPeNDAP catalog or a local directory.
%
%See also: GRID_2D_ORTHOGONAL
  
OPT.dataset = dataset;

disp('Retrieving map info from dataset ...')

% check for catalog.nc link
if strcmpi(OPT.dataset(end-9:end),'catalog.nc')
    OPT.catalognc = OPT.dataset;
    OPT.urls = cellstr([nc_varget(OPT.dataset,'urlPath')]');
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
    OPT.x_ranges = nc_varget(OPT.catalognc,'projectionCoverage_x')';
    OPT.y_ranges = nc_varget(OPT.catalognc,'projectionCoverage_y')';
else
    %% slow method for if there is no catalog nc
    OPT.x_ranges = nan(length(OPT.urls),2);
    OPT.y_ranges = nan(length(OPT.urls),2);
    wbh = waitbar(0,'Please wait ...');
    varname_x = nc_varfind(OPT.urls{1}, 'attributename','standard_name','attributevalue','projection_x_coordinate');
    varname_y = nc_varfind(OPT.urls{1}, 'attributename','standard_name','attributevalue','projection_y_coordinate');
    for i = 1:length(OPT.urls)
        waitbar(i/length(OPT.urls), wbh, 'Extracting map outlines from nc files ...')

        x_range = nc_getvarinfo(OPT.urls{i}, varname_x);
        y_range = nc_getvarinfo(OPT.urls{i}, varname_y);

        if any(ismember({y_range.Attribute.Name}, 'actual_range')) && ...
           any(ismember({x_range.Attribute.Name}, 'actual_range'))
            xrange = x_range.Attribute(ismember({x_range.Attribute.Name}, 'actual_range')).Value;
            yrange = y_range.Attribute(ismember({y_range.Attribute.Name}, 'actual_range')).Value;
            if isstr(xrange);xrange = str2num(xrange);end;OPT.x_ranges(i,:) = xrange;
            if isstr(yrange);yrange = str2num(yrange);end;OPT.y_ranges(i,:) = yrange;
        else
            info_x            = nc_getvarinfo(OPT.urls{i}, varname_x);
            OPT.x_ranges(i,:) = [...
                nc_varget(OPT.urls{i}, varname_x, 0, 1) ...
                nc_varget(OPT.urls{i}, varname_x, info_x.Size - 1, 1)];

            info_y            = nc_getvarinfo(OPT.urls{i}, varname_y);
            OPT.y_ranges(i,:) = [...
                nc_varget(OPT.urls{i}, varname_y, 0, 1) ...
                nc_varget(OPT.urls{i}, varname_y, info_y.Size - 1, 1)];
        end
    end
    close(wbh)
end
