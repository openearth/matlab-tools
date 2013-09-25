function mdu = simona2mdu_crs(mdf,mdu, name_mdu)

% siminp2mdu_crs : Writes cross section information to unstruc file

filgrd = [mdf.pathd3d filesep mdf.filcco];
filcrs = [mdf.pathd3d filesep mdf.filcrs];

LINE   = [];

% Open and read the D3D Files

grid = delft3d_io_grd('read',filgrd);
xcoor = grid.cend.x';
ycoor = grid.cend.y';

crs   = delft3d_io_obs('read',filcrs);

%
% Fill LINE struct for writing to unstruc file
%

for ista = 1: sta.NTables
    LINE.DATA{ista,1} = xcoor(sta.m(ista),sta.n(ista));
    LINE.DATA{ista,2} = ycoor(sta.m(ista),sta.n(ista));
    LINE.DATA{ista,3} = strtrim(sta.namst(ista,:));
end

% finally write to the unstruc thd file and fill in the name of the thd filw in the mdu_struct


mdu.output.ObsFile = [name_mdu '.xyn'];
unstruc_io_xydata('write',mdu.output.ObsFile,LINE);
mdu.output.ObsFile = simona2mdf_rmpath(mdu.output.ObsFile);
