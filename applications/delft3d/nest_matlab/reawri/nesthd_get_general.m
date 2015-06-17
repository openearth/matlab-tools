function nfs_inf = get_general(filename)

% get_general: retrieves general information from trih or SDS file

filetype = nesthd_det_filetype(filename);

switch filetype

    case ('Delft3D')
        nfs_inf     = nesthd_ini_nfs        (filename);
    case ('SIMONA')
        nfs_inf     = nesthd_ini_sds        (filename);
    case ('DFLOWFM')
        nfs_inf     = nesthd_ini_dflowfm     (filename);
end
