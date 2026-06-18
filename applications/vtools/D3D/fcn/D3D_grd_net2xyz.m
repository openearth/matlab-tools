
%$Revision: 688 $ 
%$Date: 2026-06-17 11:23:05 +0200 (wo, 17 jun 2026) $ 
%$Author: ottevan $ 
%$Id: D3D_grd_net2xyz.m 688 2026-06-17 09:23:05Z ottevan $ 
%$HeadURL: file:///P:/11211565-002-maas-mor-2026/E_Software_Scripts/svn/96_make_bedlevel_files_Lixhe_Roernond/D3D_grd_net2xyz.m $ 

%D3D_grd_net2xyz converts net file information to xyz for use in inifieldfile bed 
%usage: D3D_grd_net2xyz(netfile)

% netfile

% option_str = 'centre'
%          'corner'
%          'corner2centre'
%          'corner2centre_fm'

% outdir = path to store output (default pwd)

% add_metadata (true/false) - write metadata to file

function D3D_grd_net2xyz(netfile, varargin)

parin=inputParser;

addOptional(parin,'outdir',pwd);
addOptional(parin,'add_metadata',true);
addOptional(parin,'option_str','centre');

parse(parin,varargin{:});

outdir=parin.Results.outdir;
add_metadata=parin.Results.add_metadata;
option_str=parin.Results.option_str;

CENTRE = 1;
CORNER = 3;
CORNER2CENTRE = 31;
CORNER2CENTRE_FM = 310;

switch lower(option_str)
    case "centre" %UK
        option_par = CENTRE;
    case "center"
        option_par = CENTRE;
    case "corner"
        option_par = CORNER;
    case "corner2centre"
        option_par = CORNER2CENTRE;
    case "corner2center"
        option_par = CORNER2CENTRE;
    case "corner2centre_fm"
        option_par = CORNER2CENTRE_FM;
    case "corner2center_fm"
        option_par = CORNER2CENTRE_FM;
end

switch option_par 
    case CENTRE
        xi = ncread(netfile, 'mesh2d_face_x');
        yi = ncread(netfile, 'mesh2d_face_y');
        zi = ncread(netfile, 'mesh2d_face_z');
    case {CORNER,CORNER2CENTRE}
        xi = ncread(netfile, 'mesh2d_node_x');
        yi = ncread(netfile, 'mesh2d_node_y');
        zi = ncread(netfile, 'mesh2d_node_z');
    case {CORNER2CENTRE_FM}
        D3D_grd2map(netfile, 'fpath_map', 'tmp_map.nc', 'fpath_exe','P:\d-hydro\dimrset\2026\2026.02\x64\bin\run_dimr.bat') % or higher.
        xi = ncread('tmp_map.nc', 'mesh2d_face_x');
        yi = ncread('tmp_map.nc', 'mesh2d_face_y');
        zi = ncread('tmp_map.nc', 'mesh2d_flowelem_bl');
end

if option_par == CORNER2CENTRE
    xo = ncread(netfile, 'mesh2d_face_x');
    yo = ncread(netfile, 'mesh2d_face_y');
    face_nodes = ncread(netfile, 'mesh2d_face_nodes');
    z_temp = NaN*zeros(size(face_nodes));
    z_temp(~isnan(face_nodes)) = zi(face_nodes(~isnan(face_nodes)));
    zo = mean(z_temp,"omitnan").';
else 
    xo = xi;
    yo = yi;
    zo = zi;
end

if option_par == CORNER2CENTRE_FM
    deletefile('tmp_map.nc')
end

[directory, file_base,file_ext] = fileparts(netfile); 
outfile = fullfile(outdir, [file_base, '_', option_str, '.xyz']);

if add_metadata
    fid = fopen_add_header(outfile, 'w');
else
    % open new file
    fid = fopen(outfile,'w'); 
    fclose(fid);
end

writematrix([xo,yo,zo],outfile,'WriteMode','append', 'FileType','text', 'Delimiter', ' ');

end
