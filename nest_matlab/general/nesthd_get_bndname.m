function filebnd = get_bndname(filename)

% get_bndname : Get the name of teh file with boundary information (direct, from mdf or from siminp file

[pin,~,~] = fileparts(filename);
filetype = nesthd_det_filetype(filename);

switch filetype
   case 'mdf'
      mdf = ddb_readMDFText(filename);
      filebnd = [pin filesep mdf.filbnd];
    case 'mdu'
        mdu = dflowfm_io_mdu('read',filename);
        filebnd = [pin mdu.external_forcing.ExtForceFile];
    case 'pli'
      filebnd = filename;
    case 'Delft3D'
      filebnd = filename;
    case 'siminp'
       filebnd = filename;
    case 'ext'
        filebnd = filename;
    otherwise
      filebnd = '';
end

