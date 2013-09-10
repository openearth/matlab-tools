function simona2mdu_thd(mdf)

% siminp2mdu_thd : Writes drypoints and thin dams to unstruc input files

filgrd = [mdf.pathd3d filesep mdf.filcco];
fildry = [mdf.pathd3d filesep mdf.fildry];
filthd = [mdf.pathd3d filesep mdf.filthd];

% Open and read the files

grid = delft3d_io_grd('open',filgrd);
xcoor = grid.cor.x;
ycoor = grid.cor.y;

MNdry = delft3d_io_grd('open',fildry);

MNthd = delft3d_io_thd('open',filthd);





