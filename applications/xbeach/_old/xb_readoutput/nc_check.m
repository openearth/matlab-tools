function nc_check()

msg = '';

if ~exist('nc_dump','file') || ~exist('nc_info','file') || ...
        ~exist('nc_varget','file')
    msg = 'ERROR: SNCTools not found in path. Use OETSETTINGS.';
end

if isempty(cell2mat(strfind(javaclasspath,'toolsUI-4.1.jar'))) && ...
        isempty(cell2mat(strfind(javaclasspath,'netcdfAll-4.1.jar')))
    msg = 'ERROR: NetCDF java library not loaded. Use NETCDF_SETTINGS.';
end

if ~isempty(msg)
    error(msg)
end