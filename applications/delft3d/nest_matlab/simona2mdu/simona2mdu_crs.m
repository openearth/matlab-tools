function mdu = simona2mdu_crs(mdf,mdu, name_mdu)

% siminp2mdu_crs : Writes cross section information to unstruc file

filgrd = [mdf.pathd3d filesep mdf.filcco];
filcrs = [mdf.pathd3d filesep mdf.filcrs];

LINE   = [];

% Open and read the D3D Files

grid = delft3d_io_grd('read',filgrd,'Enclosure',false);
xcoor = grid.cor.x';
ycoor = grid.cor.y';

tmp = delft3d_io_crs('read',filcrs);
crs = tmp.DATA;

%
% Fill LINE struct for writing to unstruc file
%

for icrs = 1: length(crs)
    
    LINE(icrs).Blckname  = crs(icrs).name;
    
    m(1) = crs(icrs).mn(1);
    m(2) = crs(icrs).mn(3);
    n(1) = crs(icrs).mn(2);
    n(2) = crs(icrs).mn(4);
    m = sort(m);
    n = sort(n);
    
    npnt = 0; 
    switch crs(icrs).direction
        case 'u'
            for n = n(1) - 1: n(2)
                if ~isnan(xcoor(m(1),n))
                    npnt = npnt + 1;
                    LINE(icrs).DATA{npnt,1} = xcoor(m(1),n);
                    LINE(icrs).DATA{npnt,2} = ycoor(m(1),n);
                end
            end
        case 'v'
            for m = m(1) - 1:  m(2)
                if ~isnan(xcoor(m,n(1)))
                    npnt = npnt + 1;
                    LINE(icrs).DATA{npnt,1} = xcoor(m,n(1));
                    LINE(icrs).DATA{npnt,2} = ycoor(m,n(1));
                end 
            end
    end
                
end

% finally write to the unstruc thd file and fill in the name of the crs file in the mdu_struct


mdu.output.CrsFile = [name_mdu '_crs.pli'];
unstruc_io_xydata('write',mdu.output.CrsFile,LINE);
mdu.output.CrsFile = simona2mdf_rmpath(mdu.output.CrsFile);
