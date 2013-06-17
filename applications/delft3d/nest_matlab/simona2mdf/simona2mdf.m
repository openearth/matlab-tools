function simon2mdf (varargin)

%simona2mdf: converts simona siminp file into a D3D-Flow master definition file (first basic version)

Gen_inf    = {'This tool converts a SIMONA siminp file into a Delft3D-Flow mdf file'                               ;
              'with belonging attribute files'                                                                     ;
              ' '                                                                                                  ;
              'Not everything is supported:'                                                                       ;
              '- Transport (salinity, temperature and tracers) is not supported yet'                               ;
              '- Discharge points are not supported yet (coming soon)'                                             ;
              '- Restarting is not supported yet'                                                                  ;
              '- Space varying wind is not supported yet'                                                          ;
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
logo = imread([getenv('nesthd_path') filesep 'bin' filesep 'simona_logo.jpg']);

if isempty(varargin)
    %filwaq = '..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp.fou';
    filwaq = '..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp';
    %filwaq = '..\test\simona\simona-kustzuid-2004-v4\SIMONA\berekeningen\siminp-kzv4';
    %filwaq =  '..\test\simona\A80\siminp.dcsmv6';
    filmdf = 'test.mdf';
else
    filwaq = varargin{1};
    filmdf = varargin{2};
end

[path_waq,name_waq,extension_waq] = fileparts([filwaq]);
[path_mdf,name_mdf,~            ] = fileparts([filmdf]);
name_mdf = [path_mdf filesep name_mdf];

%
% Start with creating empty template (add the simonapath to it to allow for
% copying of the grid file)
%

DATA = delft3d_io_mdf('new','template_gui.mdf');
mdf  = DATA.keywords;
mdf.pathsimona = path_waq;
mdf.pathd3d    = path_mdf;

%
% Read the entire siminp and parse everything into 1 structure
%

S = readsiminp(path_waq,[name_waq extension_waq]);
S = all_in_one(S);

%
% parse the siminp information
%

simona2mdf_message(Gen_inf                                  ,logo,15);

simona2mdf_message('Parsing AREA information'               ,logo,1 );
mdf = simona2mdf_area     (S,mdf,name_mdf);

simona2mdf_message('Parsing BATHYMETRY information'         ,logo,1 );
mdf = simona2mdf_bathy    (S,mdf,name_mdf);

simona2mdf_message('Parsing DRYPOINT information'           ,logo,1 );
mdf = simona2mdf_dryp     (S,mdf,name_mdf);

simona2mdf_message('Parsing THINDAM information'            ,logo,1 );
mdf = simona2mdf_thd      (S,mdf,name_mdf);

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

%
% write the mdf file
%

delft3d_io_mdf('write',filmdf,mdf);

simona2mdf_message();

