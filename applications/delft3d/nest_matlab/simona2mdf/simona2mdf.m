function simon2mdf (varargin)

%simona2mdf: converts simona siminp file into a D3D-Flow master definition file (first basic version)

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

mdf = simona2mdf_area     (S,mdf,name_mdf);
mdf = simona2mdf_bathy    (S,mdf,name_mdf);
mdf = simona2mdf_dryp     (S,mdf,name_mdf);
mdf = simona2mdf_thd      (S,mdf,name_mdf);
mdf = simona2mdf_times    (S,mdf,name_mdf);
mdf = simona2mdf_processes(S,mdf,name_mdf);
mdf = simona2mdf_physical (S,mdf,name_mdf);
mdf = simona2mdf_numerical(S,mdf,name_mdf);
mdf  = simona2mdf_bnd      (S,mdf,name_mdf); 
mdf = simona2mdf_initial  (S,mdf,name_mdf);
mdf = simona2mdf_restart  (S,mdf,name_mdf);
mdf = simona2mdf_friction (S,mdf,name_mdf);
mdf = simona2mdf_viscosity(S,mdf,name_mdf);
mdf = simona2mdf_obs      (S,mdf,name_mdf);
mdf = simona2mdf_crs      (S,mdf,name_mdf);
mdf = simona2mdf_output   (S,mdf);

%
% write the mdf file
%

delft3d_io_mdf('write',filmdf,mdf);
