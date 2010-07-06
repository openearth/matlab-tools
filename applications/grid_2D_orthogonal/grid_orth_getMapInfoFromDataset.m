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
OPT.urls     = opendap_catalog(OPT.dataset);
% introduce hack that removes all urls to old versions of the nc file that are not
% supported
% TODO: Check this properly when reading the file instead of filtering based on filenames
OPT.urls(cellfun(@length,cellfun(@strfind,OPT.urls,repmat({'/jarkus'},size(OPT.urls)),'UniformOutput',false))==1)=[];
OPT.urls(cellfun(@length,cellfun(@strfind,OPT.urls,repmat({'/vaklodingen'},size(OPT.urls)),'UniformOutput',false))==1)=[];

OPT.x_ranges = ones(length(OPT.urls),2)*nan;
OPT.y_ranges = ones(length(OPT.urls),2)*nan;

wbh = waitbar(0,'Please wait ...');
varname_x = nc_varfind(OPT.urls{1}, 'attributename','standard_name','attributevalue','projection_x_coordinate');
varname_y = nc_varfind(OPT.urls{1}, 'attributename','standard_name','attributevalue','projection_y_coordinate');
for i = 1:length(OPT.urls)
    waitbar(i/length(OPT.urls), wbh, 'Extracting map outlines from nc files ...')
    
    x_range = nc_getvarinfo(OPT.urls{i}, varname_x);
    y_range = nc_getvarinfo(OPT.urls{i}, varname_y);
    
    if any(ismember({y_range.Attribute.Name}, 'actual_range')) && ...
            any(ismember({x_range.Attribute.Name}, 'actual_range'))
        OPT.x_ranges(i,:) = str2num(x_range.Attribute(ismember({x_range.Attribute.Name}, 'actual_range')).Value); %#ok<*ST2NM>
        OPT.y_ranges(i,:) = str2num(y_range.Attribute(ismember({y_range.Attribute.Name}, 'actual_range')).Value);
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
