function d3d2dflowfm (varargin)

%d3d2dflowfm : converts mdf file into an Unstruc input file ("*.mdu")

Gen_inf    = {'This tool converts a Delft3D-Flow mdf file into an D-Dlow FM mdu file'                              ;
              'with belonging attribute files'                                                                     ;
              ' '                                                                                                  ;
              'Credits go to Wim van Baalen for his conversion of boundary conditions'                             ;
              ' '                                                                                                  ;
              'This tool does a basic first conversion'                                                            ;
              'Not everything is converted:'                                                                       ;
              '- Tracer  information is not converted yet'                                                         ;
              '- 3D is supported as far as DFLOWFM allows (depth-averaged ic and bc)'                              ;
              ' '                                                                                                  ;
              'PLEASE CHECK CAREFULLY( USE AT OWN RISK)'                                                           ;                                                                                        ' '
              ' '                                                                                                  ;
              'If you encounter problems, please do not hesitate to contact me'                                    ;                                                    ; 
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
name_mdu                          = [path_mdu filesep name_mdu];
if ~exist(path_mdu,'dir') mkdir(path_mdu);end

%% Display the general information
if OPT.DispGen
   simona2mdf_message(Gen_inf,'n_sec',5,'Window','D3D2DFLOWFM Message','Close',true);
end

%% Start with creating empty mdu template
[mdu,mdu_Comment] = dflowfm_io_mdu('new',[getenv('nesthd_path') filesep 'bin' filesep 'dflowfm-properties.csv']);
mdu.pathmdu = path_mdu;

%% Read the temporary mdf file, add the path of the d3d files to allow for reading later
tmp                         = delft3d_io_mdf('read',filmdf);
mdf                         = tmp.keywords;
[path_mdf,name_mdf,ext_mdf] = fileparts(filmdf);
mdf.pathd3d                 = path_mdf;
mdf.named3d                 = [name_mdf ext_mdf];

%% Generate the net file from the area information
simona2mdf_message('Generating the Net file'                           ,'Window','D3D2DFLOWFM Message');
d3d2dflowfm_grd2net([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filgrd],[path_mdf filesep mdf.fildep], ...
                    [name_mdu '_net.nc']         ,[name_mdu '.xyz']                                          );
mdu.geometry.NetFile = [name_mdu '_net.nc'];
mdu.geometry.NetFile = simona2mdf_rmpath(mdu.geometry.NetFile);

%% Generate unstruc additional files and fill the mdu structure
simona2mdf_message('Generating D-Flow FM Area              information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_area     (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM Thin Dam          information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_thd      (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM Weir              information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_weirs    (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM TIMES             information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_times    (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM PHYSICAL          information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_physical (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM NUMERICAL         information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_numerical(mdf,mdu,name_mdu);

if simona2mdf_fieldandvalue(mdf,'filbnd')
    simona2mdf_message('Generating D-Flow FM Boundary definition          ','Window','D3D2DFLOWFM Message');
    mdu.Filbnd = d3d2dflowfm_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],name_mdu,...
                                      'enclosure',[path_mdf filesep mdf.filgrd]);
else
    mdu.Filbnd = '';
end

if mdu.physics.Salinity && simona2mdf_fieldandvalue(mdf,'filbnd')        % Salinity, write _sal pli files
    tmp = d3d2dflowfm_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],name_mdu,'Salinity',true);
    mdu.Filbnd = [mdu.Filbnd tmp];
end

if mdu.physics.Temperature > 0 && simona2mdf_fieldandvalue(mdf,'filbnd') % Temperature,
    tmp = d3d2dflowfm_bnd2pli([path_mdf filesep mdf.filcco],[path_mdf filesep mdf.filbnd],name_mdu,'Temperature',true);
    mdu.Filbnd = [mdu.Filbnd tmp];
end

simona2mdf_message('Generating D-Flow FM Initial Condition information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_initial  (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM Friction          information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_friction (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM Viscosity/diff.   information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_viscosity(mdf,mdu,name_mdu);

simona2mdf_message('Generating External forcing file                  ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Filbnd'     ,mdu.Filbnd ,'Comments',true);
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Filini_wl'  ,mdu.Filini_wl );
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Filini_sal' ,mdu.Filini_sal);
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Filini_tem' ,mdu.Filini_tem);
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Filrgh'     ,mdu.Filrgh    );
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Filvico'    ,mdu.Filvico   );
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Fildico'    ,mdu.Fildico   );
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Filwnd'     ,mdu.Filwnd    );
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Filtem'     ,mdu.Filtem    );
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Fileva'     ,mdu.Fileva    );
mdu = d3d2dflowfm_genext   (mdu,name_mdu,'Filwsvp'    ,mdu.Filwsvp   );

simona2mdf_message('Generating D-Flow FM boundary conditions          ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_bndforcing(mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM Wind Forcing                 ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_wndforcing(mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM Temperature Forcing          ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_temperatureforcing(mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM Rain and Evaporation         ','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_evap              (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM STATION           information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_obs      (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM CROSS-SECTION     information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_crs      (mdf,mdu,name_mdu);

simona2mdf_message('Generating D-Flow FM OUTPUT            information','Window','D3D2DFLOWFM Message');
mdu = d3d2dflowfm_output   (mdf,mdu,name_mdu);

%% Finally,  write the mdu file and close everything
simona2mdf_message('Writing    D-Flow FM *.mdu file                   ','Window','D3D2DFLOWFM Message','Close',true,'n_sec',1);
mdu = d3d2dflowfm_cleanup(mdu);
dflowfm_io_mdu('write',[name_mdu '.mdu'],mdu,mdu_Comment);
