function simona2mdu_thd(mdf,name_mdu)

% siminp2mdu_thd : Writes drypoints and thin dams to unstruc input files

filgrd = [mdf.pathd3d filesep mdf.filcco];
fildry = [mdf.pathd3d filesep mdf.fildry];
filthd = [mdf.pathd3d filesep mdf.filtd ];

% Open and read the files D3D Files

grid = delft3d_io_grd('read',filgrd);
xcoor = grid.cor.x';
ycoor = grid.cor.y';

MNdry = delft3d_io_dry('read',fildry);

MNthd = delft3d_io_thd('read',filthd);

% open and write unstruc file

fid = fopen ([name_mdu '_xytd'],'w+');

% first dry points 

m = MNdry.m;
n = MNdry.n;

for idry = 1: length(m)
    if ~isnan(xcoor(m(idry)  ,n(idry)  )) && ~isnan(xcoor(m(idry)-1,n(idry)  )) && ...
       ~isnan(xcoor(m(idry)  ,n(idry)-1)) && ~isnan(xcoor(m(idry)-1,n(idry)-1))     

        fprintf(fid,'LINE \n');
        fprintf(fid,' 2 2 \n');
        fprintf(fid,'%12.6f %12.6f \n',xcoor(m(idry) - 1,n(idry) - 1),ycoor(m(idry) - 1,n(idry) - 1));
        fprintf(fid,'%12.6f %12.6f \n',xcoor(m(idry) - 1,n(idry)    ),ycoor(m(idry) - 1,n(idry)    ));
        fprintf(fid,'LINE \n');
        fprintf(fid,' 2 2 \n');
        fprintf(fid,'%12.6f %12.6f \n',xcoor(m(idry) - 1,n(idry)    ),ycoor(m(idry) - 1,n(idry)    ));
        fprintf(fid,'%12.6f %12.6f \n',xcoor(m(idry)    ,n(idry)    ),ycoor(m(idry)    ,n(idry)    ));
        fprintf(fid,'LINE \n');
        fprintf(fid,' 2 2 \n');
        fprintf(fid,'%12.6f %12.6f \n',xcoor(m(idry)    ,n(idry)    ),ycoor(m(idry)    ,n(idry)    ));
        fprintf(fid,'%12.6f %12.6f \n',xcoor(m(idry)    ,n(idry) - 1),ycoor(m(idry)    ,n(idry) - 1));
        fprintf(fid,'LINE \n');
        fprintf(fid,' 2 2 \n');
        fprintf(fid,'%12.6f %12.6f \n',xcoor(m(idry)    ,n(idry) - 1),ycoor(m(idry)    ,n(idry) - 1));
        fprintf(fid,'%12.6f %12.6f \n',xcoor(m(idry) - 1,n(idry) - 1),ycoor(m(idry) - 1,n(idry) - 1));
    end
end

% then thin dams

dams = MNthd.Data;

for ipnt = 1 : length(dams)
    m(1) = dams(ipnt).mn(1);
    n(1) = dams(ipnt).mn(2);
    m(2) = dams(ipnt).mn(3);
    n(2) = dams(ipnt).mn(4);
    type = dams(ipnt).direction;
    if strcmpi(type,'u')
        n = sort (n);
        for idam = n(1):n(2)
            if ~isnan(xcoor(m(1),idam - 1)) && ~isnan(xcoor(m(1),idam)) 
                fprintf(fid,'LINE \n');
                fprintf(fid,' 2 2 \n');
                fprintf(fid,'%12.6f %12.6f \n',xcoor(m(1),idam - 1),ycoor(m(1),idam - 1));
                fprintf(fid,'%12.6f %12.6f \n',xcoor(m(1),idam    ),ycoor(m(1),idam    ));
            end
        end
    else
        m = sort(m);
        for idam = m(1):m(2)
            if ~isnan(xcoor(idam - 1,n(1))) && ~isnan(xcoor(idam,n(1))) 
                fprintf(fid,'LINE \n');
                fprintf(fid,' 2 2 \n');
                fprintf(fid,'%12.6f %12.6f \n',xcoor(idam - 1,n(1)),ycoor(idam - 1,n(1)));
                fprintf(fid,'%12.6f %12.6f \n',xcoor(idam    ,n(1)),ycoor(idam    ,n(1)));
            end
        end
    end
end

fclose(fid);





