function mdu = d3d2dflowfm_inital(mdf,mdu, name_mdu)

% d3d2dflowfm_initial : Writes dinitial conditions for waterlevel and salinity to D-Flow FM input files

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

    tmp(:,1) = reshape(xcoor'     ,mmax*nmax,1);
    tmp(:,2) = reshape(ycoor'     ,mmax*nmax,1);
    tmp(:,3) = reshape(ic(1).Data',mmax*nmax,1);

    nonan = ~isnan(tmp(:,1));

    LINE.DATA = num2cell(tmp(nonan,:));

    %% Write inial water level data to unstruc xyz file
    dflowfm_io_xydata('write',[name_mdu '_ini_wlev.xyz'],LINE);
    mdu.geometry.WaterLevIniFile = [nameshort '_ini_wlev.xyz'];

    % Salinity (if active, assume 2Dh)
    if mdu.physics.Salinity

        tmp(:,3) = reshape(ic(4).Data,mmax*nmax,1);
        LINE.DATA = num2cell(tmp(nonan,:));

        %% Write inial salinity data to unstruc xyz file
        dflowfm_io_xydata('write',[name_mdu '_ini_sal.xyz'],LINE);
        mdu.Filini = [nameshort 'ini_sal.xyz'];
    end
else

    % Constant values from mdf file

    mdu.geometry.WaterLevIni = mdf.zeta0;
    if mdu.physics.Salinity
        mdu.physics.InitialSalinity = mdf.s0;
    end
end


