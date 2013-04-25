function filegrd = get_gridname(filename)

% get_gridname: gets the gridname either direct, from siminp file or mdf file

filegrd = filename;

[pin,~,~] = fileparts(filename);
pin = [pin filesep];

filetype = nesthd_det_filetype(filename);

switch filetype
   case 'mdf'
      mdf = ddb_readMDFText(filename);
      filegrd = [pin mdf.filcco];
    case 'grd'
       filegrd = filename;
    case 'siminp'

       %
       % Read the siminp file
       %

       [P,N,E] = fileparts(filename);
       filename = [N E];
       exclude  = {true;true};
       S = readsiminp(P,filename,exclude);
       S = all_in_one(S);

       %
       % Parse Mesh/grid part
       %

       nesthd_dir = getenv('nesthd_path');
       siminp_struc = siminp(S,[nesthd_dir filesep 'bin' filesep 'waquaref.tab'],{'MESH' 'GRID'});
       filegrd = siminp_struc.ParsedTree.MESH.GRID.CURVILINEAR.RGFFILE;
       filegrd = [pin filegrd];
    otherwise
        filegrd = '';
end
