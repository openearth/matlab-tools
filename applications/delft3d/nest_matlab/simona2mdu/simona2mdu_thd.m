function simona2mdu_thd(mdf,mdu,name_mdu)

% siminp2mdu_thd : Writes drypoints and thin dams to unstruc input files

filgrd = [mdf.pathd3d filesep mdf.filcco];
fildry = [mdf.pathd3d filesep mdf.fildry];
filthd = [mdf.pathd3d filesep mdf.filtd ];

% Open and read the files

grid = delft3d_io_grd('read',filgrd);
xcoor = grid.cor.x';
ycoor = grid.cor.y';

MNdry = delft3d_io_dry('read',fildry);

MNthd = delft3d_io_thd('read',filthd);





