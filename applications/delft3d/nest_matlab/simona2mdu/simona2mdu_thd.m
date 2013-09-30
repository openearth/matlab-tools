function mdu = simona2mdu_thd(mdf,mdu, name_mdu)

% siminp2mdu_thd : Writes drypoints and thin dams to unstruc input files

filgrd = [mdf.pathd3d filesep mdf.filcco];
fildry = [mdf.pathd3d filesep mdf.fildry];
filthd = [mdf.pathd3d filesep mdf.filtd ];

LINE   = [];

% Open and read the D3D Files

grid = delft3d_io_grd('read',filgrd);
xcoor = grid.cor.x';
ycoor = grid.cor.y';

MNdry = delft3d_io_dry('read',fildry);
MNthd = delft3d_io_thd('read',filthd);

% first dry points

m     = MNdry.m;
n     = MNdry.n;

%
% Fill the LINE struct for dry points
%

iline = 0;

for idry = 1: length(m)
    if ~isnan(xcoor(m(idry)  ,n(idry)  )) && ~isnan(xcoor(m(idry)-1,n(idry)  )) && ...
       ~isnan(xcoor(m(idry)  ,n(idry)-1)) && ~isnan(xcoor(m(idry)-1,n(idry)-1))


        iline = iline + 1;
        LINE(iline).Blckname  = 'Line';
        LINE(iline).DATA{1,1} = xcoor(m(idry) - 1,n(idry) - 1);
        LINE(iline).DATA{1,2} = ycoor(m(idry) - 1,n(idry) - 1);
        LINE(iline).DATA{2,1} = xcoor(m(idry) - 1,n(idry)    );
        LINE(iline).DATA{2,2} = ycoor(m(idry) - 1,n(idry)    );

        iline = iline + 1;
        LINE(iline).Blckname  = 'Line';
        LINE(iline).DATA{1,1} = xcoor(m(idry) - 1,n(idry)    );
        LINE(iline).DATA{1,2} = ycoor(m(idry) - 1,n(idry)    );
        LINE(iline).DATA{2,1} = xcoor(m(idry)    ,n(idry)    );
        LINE(iline).DATA{2,2} = ycoor(m(idry)    ,n(idry)    );

        iline = iline + 1;
        LINE(iline).Blckname  = 'Line';
        LINE(iline).DATA{1,1} = xcoor(m(idry)    ,n(idry)    );
        LINE(iline).DATA{1,2} = ycoor(m(idry)    ,n(idry)    );
        LINE(iline).DATA{2,1} = xcoor(m(idry)    ,n(idry) - 1);
        LINE(iline).DATA{2,2} = ycoor(m(idry)    ,n(idry) - 1);

        iline = iline + 1;
        LINE(iline).Blckname  = 'Line';
        LINE(iline).DATA{1,1} = xcoor(m(idry)    ,n(idry) - 1);
        LINE(iline).DATA{1,2} = ycoor(m(idry)    ,n(idry) - 1);
        LINE(iline).DATA{2,1} = xcoor(m(idry) - 1,n(idry) - 1);
        LINE(iline).DATA{2,2} = ycoor(m(idry) - 1,n(idry) - 1);
    end
end

clear m n
% Fill the line struct for thin dams

dams = MNthd.DATA;

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
                iline = iline + 1;
                LINE(iline).Blckname  = 'Line';
                LINE(iline).DATA{1,1} = xcoor(m(1)       ,idam - 1);
                LINE(iline).DATA{1,2} = ycoor(m(1)       ,idam - 1);
                LINE(iline).DATA{2,1} = xcoor(m(1)       ,idam    );
                LINE(iline).DATA{2,2} = ycoor(m(1)       ,idam    );
            end
        end
    else
        m = sort(m);
        for idam = m(1):m(2)
            if ~isnan(xcoor(idam - 1,n(1))) && ~isnan(xcoor(idam,n(1)))
                iline = iline + 1;
                LINE(iline).Blckname  = 'Line';
                LINE(iline).DATA{1,1} = xcoor(idam - 1   ,n(1)    );
                LINE(iline).DATA{1,2} = ycoor(idam - 1   ,n(1)    );
                LINE(iline).DATA{2,1} = xcoor(idam       ,n(1)    );
                LINE(iline).DATA{2,2} = ycoor(idam       ,n(1)    );
            end
        end
    end
end

% finally write to the unstruc thd file and fill in the name of the thd filw in the mdu_struct

mdu.geometry.ThinDamFile = [name_mdu '_thd.pli']; 
unstruc_io_xydata('write',mdu.geometry.ThinDamFile,LINE);
mdu.geometry.ThinDamFile = simona2mdf_rmpath(mdu.geometry.ThinDamFile);
