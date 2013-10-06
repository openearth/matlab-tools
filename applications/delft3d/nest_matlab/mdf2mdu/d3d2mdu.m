function d3d2mdu (varargin)

%d3d2mdu : converts mdf file into an Unstruc input file ("*.mdu")
%

Gen_inf    = {'This tool converts a Delft3D-Flow mdf file into an Unstruc mdu file'                                ;
              'with belonging attribute files'                                                                     ;
              ' '                                                                                                  ;
              'Credits go to Wim van Baalen for his conversion of boundary conditions'                             ;
              ' '                                                                                                  ;
              'This tool does a basic first conversion'                                                            ;
              'Noe everything is converted so please check carefully'                                              ;
              '(USE AT OWN RISK)'                                                                                  ;
              ' '                                                                                                  ;
              'If you encounter problems, please do not hesitate to contact me'                                    ;                                                                                   ;
              'Theo.vanderkaaij@deltares.nl'                                                                      };

%% set path if necessary

if ~isdeployed && any(which('setproperty'))
   addpath(genpath('..\..\..\..\..\matlab'));
end

%% Check if the general information needs to be displayed
OPT.DispGen = true;
OPT = setproperty(OPT,varargin{3:end});

%% Check if nesthd_path is set

if isempty (getenv('nesthd_path'))
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes ("Release Notes.chm")'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

%% Get filenames (either specify here or get from the argument list); Split into name and path

if isempty(varargin)
    filmdf = 'test.mdf';
    filmdu = 'test.mdu';
else
    filmdf = varargin{1};
    filmdu = varargin{2};
end

[path_mdu,name_mdu,~            ] = fileparts([filmdu]);
name_mdu = [path_mdu filesep name_mdu];

%% Display the general information

logo = imread([getenv('nesthd_path') filesep 'bin' filesep 'dflowfm.jpg']);
if OPT.DispGen
   simona2mdf_message(Gen_inf,'Logo',logo,'n_sec',5,'Window','MDF2MDU Message','Close',true);
end

%% Start with creating empty mdu template

mdu = unstruc_io_mdu('new',[getenv('nesthd_path') filesep 'bin' filesep 'dflowfm-properties.csv']);

%% Read the temporary mdf file, add the path of the d3d files to allow for reading later

tmp            = delft3d_io_mdf('read',filmdf);
mdf            = tmp.keywords;
[path_mdf,~,~] = fileparts(filmdf);
mdf.pathd3d    = path_mdf;

%% Generate the net file from the area information

simona2mdf_message('Generating the Net file'                ,'Logo',logo,'Window','MDF2MDU Message');
mdf2mdu_grd2net([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.fildep],name_mdu);
mdu.geometry.NetFile = [name_mdu '_net.nc'];
mdu.geometry.NetFile = simona2mdf_rmpath(mdu.geometry.NetFile);

%% Generate unstruc additional files and fill the mdu structure
simona2mdf_message('Generating UNSTRUC Area              information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_area   (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC Thin Dam          information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_thd    (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC TIMES             information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_times    (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC PHYSICAL          information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_physical (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC NUMERICAL         information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_numerical(mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC Boundary definition           ','Logo',logo,'Window','MDF2MDU Message');
mdu.Filbnd = mdf2mdu_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],name_mdu);

if mdu.physics.Salinity    ; % Salinity, write _sal pli files
    tmp = mdf2mdu_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],name_mdu,'Salinity',true);
    mdu.Filbnd = [mdu.Filbnd tmp];
end

simona2mdf_message('Generating UNSTRUC Initial Condition information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_initial  (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC Friction          information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_friction (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC Viscosity/diff.   information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_viscosity(mdf,mdu,name_mdu);

simona2mdf_message('Generating External forcing file                ','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_genext   (name_mdu,'mdu',mdu,'Filbnd' ,mdu.Filbnd ,'Filini' ,mdu.Filini ,'Filrgh',mdu.Filrgh  ,  ...
                                              'Filvico',mdu.Filvico,'Fildico',mdu.Fildico                      );
simona2mdf_message('Generating UNSTRUC STATION           information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_obs      (mdf,mdu,name_mdu);

simona2mdf_message('Generating UNSTRUC CROSS-SECTION     information','Logo',logo,'Window','MDF2MDU Message');
mdu = mdf2mdu_crs      (mdf,mdu,name_mdu);

%% Finally,  write the mdu file and close everything

simona2mdf_message('Writing Unstruc *.mdu file','Logo',logo,'Window','MDF2MDU Message','Close',true,'n_sec',1);
unstruc_io_mdu('write',[name_mdu '.mdu'],mdu);



