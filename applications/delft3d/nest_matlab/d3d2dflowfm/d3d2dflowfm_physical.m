function mdu = d3d2dflowfm_physical(mdf, mdu, ~)

% d3d2dflowfm_physical : Get physical information out of the mdf structure and set in the mdu structure

mdu.Filwnd          = '';
mdu.Filtem          = '';

%% General
mdu.physics.Ag      = mdf.ag;
mdu.physics.Rhomean = mdf.rhow;

%% Salinity
if strcmpi(mdf.sub1(1),'S') mdu.physics.Salinity = true; end

%% Temperature
if strcmpi(mdf.sub1(2),'T')
    if mdf.ktemp == 0
        % No heat exchange with the atmosphere
        mdu.physics.Temperature = 1;
    elseif mdf.ktemp == 5
        % Ocean Heat Flux model
        mdu.physics.Temperature  = 5;
        mdu.physics.Secchidepth  = mdf.secchi;
        mdu.physics.Stanton      = mdf.stantn;
        mdu.physics.Dalton       = mdf.dalton;
        if simona2mdf_fieldandvalue(mdf,'filtmp')
            [~,name,~] = fileparts(mdf.filtmp);
            mdu.Filtem = [name '_unstruc.tem'];
        else

            % Space varying forcing to implement yet\
        end
    else
        simona2mdf_message('Only Ocean Heat Flux model implemented','Window','D3D2DFLOWFM Warning','Close',true,'n_sec',10);
    end
else
    mdu.physics.Temparture = 0;
end

%% Wind
if strcmpi(mdf.sub1(3),'W')
    if strcmpi(mdf.wnsvwp,'N')
        %
        % Uniform wind
        if simona2mdf_fieldandvalue(mdf,'filwnd')
            [~,name,~] = fileparts(mdf.filwnd);
            mdu.Filwnd = [name '_unstruc.wnd'];
        end
    else
        %
        % Space varying wind (to implement yet)
    end
end

%% Rain and evaporation
if simona2mdf_fieldandvalue(mdf,'fileva')
    [~,name,~] = fileparts(mdf.fileva);
    mdu.Fileva = [name '_unstruc.eva'];
end
