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
% Start with creating empty template
%

DATA = delft3d_io_mdf('new','template_gui.mdf');
mdf  = DATA.keywords;

%
% Read the entire siminp and parse everything into 1 structure
%

S = readsiminp(path_waq,[name_waq extension_waq]);
S = all_in_one(S);

%
% parse the siminp information
%

mdf = simona2mdf_area     (S,mdf,name_mdf);
%mdf = simona2mdf_bathy    (S,mdf,name_mdf);
%mdf = simona2mdf_dryp     (S,mdf,name_mdf);
%mdf = simona2mdf_thd      (S,mdf,name_mdf);
%mdf = simona2mdf_times    (S,mdf,name_mdf);
%mdf = simona2mdf_processes(S,mdf,name_mdf);
%mdf = simona2mdf_physical (S,mdf,name_mdf);
%mdf = simona2mdf_numerical(S,mdf,name_mdf);

%
% Boundaries, slightly different approach to allow for use by
% nesthd functions
%

bnd = simona2mdf_bnddef(S);
if ~isempty(bnd)
    mdf.filbnd = [name_mdf '.bnd'];
    delft3d_io_bnd('write',mdf.filbnd,bnd);
    mdf.filbnd = simona2mdf_rmpath(mdf.filbnd);

    bch = simona2mdf_bch(S,bnd);
    if ~isempty(bch)
        mdf.filbch = [name_mdf '.bch'];
        delft3d_io_bch('write',mdf.filbch,bch);
        mdf.filbch = simona2mdf_rmpath(mdf.filbch);
    end

    bct = simona2mdf_bct(S,bnd,mdf);
    if ~isempty(bct)
        mdf.filbct = [name_mdf '.bct'];
        ddb_bct_io('write',mdf.filbct,bct);
        mdf.filbct = simona2mdf_rmpath(mdf.filbct);
    end

    bcq = simona2mdf_bcq(S,bnd);
    if ~isempty(bcq)
        mdf.filbcq = [name_mdf '.bcq'];
        ddb_io_bct('write',mdf.filbcq,bcq);
        mdf.filbcq = simona2mdf_rmpath(mdf.filbcq);
    end

    bca = simona2mdf_bca(S,bnd);
    if ~isempty(bca)
        mdf.filana = [name_mdf '.bca'];
        delft3d_io_bca('write',mdf.filana,bca);
        mdf.filana = simona2mdf_rmpath(mdf.filana);
    end
end

%
% Continue with initial conditions (back to original program structure)
%

mdf = simona2mdf_initial  (S,mdf,name_mdf);
mdf = simona2mdf_restart  (S,mdf,name_mdf);
mdf = simona2mdf_friction (S,mdf,name_mdf);
mdf = simona2mdf_viscosity(S,mdf,name_mdf);

%
% write the mdf file
%

delft3d_io_mdf('write',filmdf,mdf);
