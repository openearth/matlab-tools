function simona2mdf (filwaq,filmdf)

%simona2mdf: converts simona siminp file into a D3D-Flow master definition file (first basic version)

oetsettings('quiet','searchdb',false);

%filwaq = '..\test\simona\simona-scaloost-fijn-exvd-v1\SIMONA\berekeningen\siminp';
%filwaq = '..\test\simona\simona-kustzuid-2004-v4\SIMONA\berekeningen\siminp-kzv4';
filwaq = '..\test\simona\A80\siminp.dcsmv6';
filmdf = 'test.mdf';

[path_waq,name_waq,extension_waq] = fileparts([filwaq]);
[path_mdf,name_mdf,extension_mdf] = fileparts([filmdf]);

%
% Create empty template
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
mdf = simona2mdf_bathy    (S,mdf,name_mdf);
mdf = simona2mdf_dryp     (S,mdf,name_mdf);
mdf = simona2mdf_thd      (S,mdf,name_mdf);
mdf = simona2mdf_times    (S,mdf,name_mdf);
mdf = simona2mdf_processes(S,mdf,name_mdf);
mdf = simona2mdf_restart  (S,mdf,name_mdf);

%
% Boundary definition, slightly different approach to allow for use by
% nesthd functions
%

bnd = simona2mdf_bnddef(S);
if ~isempty(bnd)
    filbnd     = [name_mdf '.bnd'];
    mdf.filbnd = filbnd;
    delft3d_io_bnd('write',filbnd,bnd);
    mdf = simona2mdf_bca(S,mdf,name_mdf);
end




%
% write the mdf file
%

delft3d_io_mdf('write',filmdf,mdf);
