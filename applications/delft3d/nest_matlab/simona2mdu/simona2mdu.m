function simon2mdu (varargin)

%simona2mdf: converts simona siminp file into a Unstruc input file
%            first the siminp file is converted into a D3D input file (mdf-file)
%            secondly the mdf file is converted into an mdu file and belonging attribute files
%            finally the mdf file is removed

Gen_inf    = {'This tool converts a SIMONA siminp file into an Unstruc mdu file'                                   ;
              'with belonging attribute files'                                                                     ;
              ' '                                                                                                  ;
              'Credits go to Wim van Baalen for his conversion mdf to mdu'                                         ;
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
    %filwaq = '..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp.fou';
    filwaq = '..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp';
    %filwaq = '..\test\simona\simona-kustzuid-2004-v4\SIMONA\berekeningen\siminp-kzv4';
    %filwaq =  '..\test\simona\A80\siminp.dcsmv6';
    filmdu = 'test.mdu';
else
    filwaq = varargin{1};
    filmdu = varargin{2};
end

[path_waq,name_waq,extension_waq] = fileparts([filwaq]);
[path_mdu,name_mdu,~            ] = fileparts([filmdu]);
name_mdu = [path_mdu filesep name_mdu];

% Temporary directory for mdf file and belonging attribute files

path_mdf = [path_mdu filesep 'TMP'];
if ~isdir(path_mdf); mkdir(path_mdf);end
name_mdf = [path_mdf filesep 'tmp'];

%% Display the general information

logo = imread([getenv('nesthd_path') filesep 'bin' filesep 'simona_logo.jpg']);
simona2mdf_message(Gen_inf                                  ,logo,5);

%% Start with creating empty template (add the simonapath to it to allow for
%  copying of the grid file)

DATA = delft3d_io_mdf('new',[getenv('nesthd_path') filesep 'bin' filesep 'template_gui.mdf']);
mdf  = DATA.keywords;
mdf.pathsimona = path_waq;
mdf.pathd3d    = path_mdf;

%% Read the entire siminp and parse everything into 1 structure

S = readsiminp(path_waq,[name_waq extension_waq]);
S = all_in_one(S);


%% parse the siminp information

simona2mdf_message('Parsing AREA information'               ,logo,1 );
mdf = simona2mdf_area     (S,mdf,name_mdf);

simona2mdf_message('Parsing BATHYMETRY information'         ,logo,1 );
mdf = simona2mdf_bathy    (S,mdf,name_mdf);

% Generate the net file from the area information

simona2mdf_message('Generating the Net file'                ,logo,1 );
simona2mdu_grd2net([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.fildep],name_mdu);

simona2mdf_message('Parsing DRYPOINT information'           ,logo,1 );
mdf = simona2mdf_dryp     (S,mdf,name_mdf);

simona2mdf_message('Parsing THINDAM information'            ,logo,1 );
mdf = simona2mdf_thd      (S,mdf,name_mdf);

simona2mdf_message('Genereting Thin Dam information for unstruc',logo,1 );
simona2mdu_thd    (mdf,name_mdu);


simona2mdf_message('Parsing TIMES information'              ,logo,1 );
mdf = simona2mdf_times    (S,mdf,name_mdf);

simona2mdf_message('Parsing PROCES information'             ,logo,1 );
mdf = simona2mdf_processes(S,mdf,name_mdf);

simona2mdf_message('Parsing PHYSICAL information'           ,logo,1 );
mdf = simona2mdf_physical (S,mdf,name_mdf);

simona2mdf_message('Parsing NUMERICAL information'          ,logo,1 );
mdf = simona2mdf_numerical(S,mdf,name_mdf);

simona2mdf_message('Parsing BOUNDARY information'           ,logo,1 );
mdf = simona2mdf_bnd      (S,mdf,name_mdf);

simona2mdf_message('Parsing DISCHARGE POINTS information'   ,logo,1 );
mdf = simona2mdf_dis      (S,mdf,name_mdf);

simona2mdf_message('Parsing WIND information'               ,logo,1 );
mdf = simona2mdf_wind     (S,mdf,name_mdf);

simona2mdf_message('Parsing INITIAL CONDITION information'  ,logo,1 );
mdf = simona2mdf_initial  (S,mdf,name_mdf);

simona2mdf_message('Parsing RESTART information'            ,logo,1 );
mdf = simona2mdf_restart  (S,mdf,name_mdf);

simona2mdf_message('Parsing FRICTION information'           ,logo,1 );
mdf = simona2mdf_friction (S,mdf,name_mdf);

simona2mdf_message('Parsing VISCOSITY information'          ,logo,1 );
mdf = simona2mdf_viscosity(S,mdf,name_mdf);

simona2mdf_message('Parsing OBSERVATION STATION information',logo,1 );
mdf = simona2mdf_obs      (S,mdf,name_mdf);

simona2mdf_message('Parsing CROSS-SECTION information'      ,logo,1 );
mdf = simona2mdf_crs      (S,mdf,name_mdf);

simona2mdf_message('Parsing OUTPUT information'             ,logo,1 );
mdf = simona2mdf_output   (S,mdf);

%% Finally,  write the mdf file and close everything

delft3d_io_mdf('write',filmdf,mdf,'stamp',false);

simona2mdf_message();

