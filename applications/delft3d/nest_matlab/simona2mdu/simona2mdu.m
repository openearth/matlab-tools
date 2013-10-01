function simon2mdu (varargin)

%simona2mdf: converts simona siminp file into a Unstruc input file
%            first the siminp file is converted into a D3D input file (mdf-file)
%            secondly the mdf file is converted into an mdu file and belonging attribute files
%            finally the mdf file is removed

Gen_inf    = {'This tool converts a SIMONA siminp file into an Unstruc mdu file'                                   ;
              'with belonging attribute files'                                                                     ;
              ' '                                                                                                  ;
              'Credits go to Wim van Baalen for his conversion of boundary conditions'                             ;
              ' '                                                                                                  ;
              'This tool does a basic first conversion but please check carefully'                                 ;
              '(USE AT OWN RISK)'                                                                                  ;
              ' '                                                                                                  ;
              'If you encounter problems, please do not hesitate to contact me'                                    ;                                                                                   ;
              'Theo.vanderkaaij@deltares.nl'                                                                      };

%% set path if necessary

if ~isdeployed && any(which('setproperty'))
   addpath(genpath('..\..\..\..\..\matlab'));
end

%% Check if nesthd_path is set

if isempty (getenv('nesthd_path'))
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes ("Release Notes.chm")'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

%% Get filenames (either specify here or get from the argument list); Split into name and path

if isempty(varargin)
    filwaq = '..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp';
    filmdu = 'test.mdu';
else
    filwaq = varargin{1};
    filmdu = varargin{2};
end

[path_mdu,name_mdu,~            ] = fileparts([filmdu]);
name_mdu = [path_mdu filesep name_mdu];

% Temporary directory for mdf file and belonging attribute files

path_mdf = [path_mdu filesep 'TMP'];
if ~isdir(path_mdf); mkdir(path_mdf);end
name_mdf = [path_mdf filesep 'tmp'];

%% Display the general information

logo = imread([getenv('nesthd_path') filesep 'bin' filesep 'dflowfm.jpg']);
simona2mdf_message(Gen_inf,'Logo',logo,'n_sec',5,'Window','SIMONA2MDU Message','Close',true);

%% Convert the Simona siminp file to a temporary mdf file

%simona2mdf (filwaq,[name_mdf '.mdf']);

%% Start with creating empty mdu template

mdu = unstruc_io_mdu('new',[getenv('nesthd_path') filesep 'bin' filesep 'dflowfm-properties.csv']);

%% Read the temporary mdf file, add the path of the d3d files to allow for reading later

tmp            = delft3d_io_mdf('read',[name_mdf '.mdf']);
mdf            = tmp.keywords;
mdf.pathd3d    = path_mdf;

%% Generate the net file from the area information

simona2mdf_message('Generating the Net file'                ,'Logo',logo,'Window','SIMONA2MDU Message');
simona2mdu_grd2net([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.fildep],name_mdu);
mdu.geometry.NetFile = [name_mdu '_net.nc'];
mdu.geometry.NetFile = simona2mdf_rmpath(mdu.geometry.NetFile);

%% Generate unstruc additional files and fill the mdu structure
simona2mdf_message('Generating UNSTRUC Area              information','Logo',logo,'Window','SIMONA2MDU Message');
mdu = simona2mdu_area   (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC Thin Dam          information','Logo',logo,'Window','SIMONA2MDU Message');
mdu = simona2mdu_thd    (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC PROCES            information','Logo',logo,'Window','SIMONA2MDU Message');
mdu = simona2mdu_proces (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC TIMES             information','Logo',logo,'Window','SIMONA2MDU Message');
mdu = simona2mdu_times    (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC Boundary definition           ','Logo',logo,'Window','SIMONA2MDU Message');
mdu.Filbnd = simona2mdu_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],name_mdu);

if mdu.physics.Salinity    ; % Salinity, write _sal pli files
    tmp = simona2mdu_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],name_mdu,'Salinity',true);
    mdu.Filbnd = [mdu.Filbnd tmp];
end

simona2mdf_message('Generating UNSTRUC Initial Condition information','Logo',logo,'Window','SIMONA2MDU Message');
mdu = simona2mdu_initial  (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC Friction          information','Logo',logo,'Window','SIMONA2MDU Message');
mdu = simona2mdu_friction (mdf,mdu,name_mdu);

simona2mdf_message('Generating External forcing file                ','Logo',logo,'Window','SIMONA2MDU Message');
mdu = simona2mdu_genext   (name_mdu,'mdu',mdu,'Filbnd',mdu.Filbnd,'Filini',mdu.Filini,'Filrgh',mdu.Filrgh);

simona2mdf_message('Generating UNSTRUC STATION           information','Logo',logo,'Window','SIMONA2MDU Message');
mdu = simona2mdu_obs      (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC CROSS-SECTION     information','Logo',logo,'Window','SIMONA2MDU Message');
mdu = simona2mdu_crs      (mdf,mdu,name_mdu);

%% Finally,  write the mdu file and close everything

unstruc_io_mdu('write',[name_mdu '.mdu'],mdu);

simona2mdf_message('','Window','SIMONA2MDU Message','Close',true,'n_sec',0);

