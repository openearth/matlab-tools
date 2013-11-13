function mdu = d3d2dflowfm_inital(mdf,mdu, name_mdu)

% d3d2dflowfm_initial : Writes initial conditions for waterlevel and salinity to D-Flow FM input files

filgrd          = [mdf.pathd3d filesep mdf.filcco];
[~,nameshort,~] = fileparts(name_mdu);
mdu.Filini      = '';

%% Reads initial conditions from file (space varying)
if simona2mdf_fieldandvalue(mdf,'filic')
    mdu.geometry.WaterLevIni      = -999.999;
    mdu.geometry.WaterLevIniFile  = [nameshort '_ini_wlev.xyz'];
    filic                         = [mdf.pathd3d filesep mdf.filic ];
    if ~mdu.physics.Salinity
        d3d2dflowfm_initial_xyz(filgrd,filic,[name_mdu  '_ini_wlev.xyz']);
    else
        mdu.Filini                         = [nameshort '_ini_sal.xyz'];
        d3d2dflowfm_initial_xyz(filgrd,filic,[name_mdu  '_ini_wlev.xyz'],[name_mdu '_ini_sal.xyz']);
    end
else

    %% Constant values from mdf file; no initial condition for salinity

    if ~simona2mdf_fieldandvalue(mdf,'zeta0')
        %% Resatart file, not implemented yet
        simona2mdf_message({'Conversion of restart file not supported yet';'Uniform water level of 0.0 m assumed'}, ...
                            'Window','D3D2DFLOWFM Warning','Close',true,'n_sec',10);
        mdf.zeta0 = 0.;
    end
    mdu.geometry.WaterLevIni = mdf.zeta0;
    if mdu.physics.Salinity
        mdu.physics.InitialSalinity = mdf.s0;
    end
end
