function mdu = mdf2mdu_inital(mdf,mdu, name_mdu)

% mdf2mdu_initial : Writes dinitial conditions for waterlevel and salinity to unstruc input files

filgrd = [mdf.pathd3d filesep mdf.filcco];
filic  = [mdf.pathd3d filesep mdf.filic ];
[~,nameshort,~] = fileparts(name_mdu);
mdu.Filini      = '';

%% Reads initial conditions from file
if ~isempty(filic)
    mdu.geometry.WaterLevIni = -999.999;
    grid  = delft3d_io_grd('read',filgrd);
    mmax  = grid.mmax;
    nmax  = grid.nmax;
    xcoor = grid.cend.x';
    ycoor = grid.cend.y';
    ic    = wldep('read',filic,[mmax nmax],'multiple');

    % initial conditions for water level
    itel = 0.;
    for m = 1: mmax
        for n = 1: nmax
            if ~isnan(xcoor(m,n))
                itel = itel + 1;
                LINE.DATA{itel,1} = xcoor(m,n);
                LINE.DATA{itel,2} = ycoor(m,n);
                LINE.DATA{itel,3} = ic(1).Data(m,n);
            end
        end
    end

    unstruc_io_xydata('write',[name_mdu '_ini_wlev.xyz'],LINE);
    mdu.geometry.WaterLevIniFile = [nameshort '_ini_wlev.xyz'];

    % Salinity (if active, assume 2Dh)
    if mdu.physics.Salinity
        itel = 0.;
        for m = 1: mmax
            for n = 1: nmax
                if ~isnan(xcoor(m,n))
                    itel = itel + 1;
                    LINE.DATA{itel,3} = ic(4).Data(m,n);
                end
            end
        end
        unstruc_io_xydata('write',[name_mdu '_ini_sal.xyz'],LINE);
        mdu.Filini = [nameshort 'ini_sal.xyz'];
    end
else

    % Constant values from mdf file

    mdu.geometry.WaterLevIni = mdf.zeta0;
    if mdu.physics.Salinity
        mdu.physics.InitialSalinity = mdf.s0;
    end
end


