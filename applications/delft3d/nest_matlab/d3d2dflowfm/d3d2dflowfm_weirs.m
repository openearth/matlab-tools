function mdu = d3d2dflowfm_weirs(mdf,mdu, name_mdu)

% d3d2dflowfm_thd : Writes weir information and thin dams to D-Flow FM input file

filgrd = [mdf.pathd3d filesep mdf.filcco];

weirs  = [];
LINE   = [];

% Open and read the D3D Files

grid = delft3d_io_grd('read',filgrd);
xcoor = grid.cor.x';
ycoor = grid.cor.y';

if simona2mdf_fieldandvalue(mdf,'fil2dw')
    fil2dw = [mdf.pathd3d filesep mdf.fil2dw];
    weirs  = delft3d_io_2dw('read',fil2dw);
end

%
% Fill the LINE struct for dry points
%

iline = 0;

for i_2dw = 1 : length(weirs.DATA)
    type   = weirs.DATA(i_2dw).direction;
    height = weirs.DATA(i_2dw).height;
    m(1)   = weirs.DATA(i_2dw).mn(1);
    n(1)   = weirs.DATA(i_2dw).mn(2);
    m(2)   = weirs.DATA(i_2dw).mn(3);
    n(2)   = weirs.DATA(i_2dw).mn(4);
    if strcmpi(type,'u')
        n = sort (n);
        for idam = n(1):n(2)
            if ~isnan(xcoor(m(1),idam - 1)) && ~isnan(xcoor(m(1),idam))
                iline = iline + 1;
                LINE(iline).Blckname  = ['L' num2str(iline,'%5.5i')];
                LINE(iline).DATA{1,1} = xcoor(m(1)       ,idam - 1);
                LINE(iline).DATA{1,2} = ycoor(m(1)       ,idam - 1);
                LINE(iline).DATA{1,3} = height;
                LINE(iline).DATA{2,1} = xcoor(m(1)       ,idam    );
                LINE(iline).DATA{2,2} = ycoor(m(1)       ,idam    );
                LINE(iline).DATA{2,3} = height;
            end
        end
    else
        m = sort(m);
        for idam = m(1):m(2)
            if ~isnan(xcoor(idam - 1,n(1))) && ~isnan(xcoor(idam,n(1)))
                iline = iline + 1;
                LINE(iline).Blckname  = ['L' num2str(iline,'%5.5i')];
                LINE(iline).DATA{1,1} = xcoor(idam - 1   ,n(1)    );
                LINE(iline).DATA{1,2} = ycoor(idam - 1   ,n(1)    );
                LINE(iline).DATA{1,3} = height;
                LINE(iline).DATA{2,1} = xcoor(idam       ,n(1)    );
                LINE(iline).DATA{2,2} = ycoor(idam       ,n(1)    );
                LINE(iline).DATA{2,3} = height;
            end
        end
    end
end

% finally write to the unstruc thd file and fill in the name of the thd filw in the mdu_struct

if ~isempty(LINE)
    mdu.geometry.WeirFile    = [name_mdu '_2dw.pli'];
    dflowfm_io_xydata('write',mdu.geometry.WeirFile,LINE);
    mdu.geometry.WeirFile    = simona2mdf_rmpath(mdu.geometry.WeirFile);
end
