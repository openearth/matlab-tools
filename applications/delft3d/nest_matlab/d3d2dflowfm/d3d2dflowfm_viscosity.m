function mdu = d3d2dflowfm_viscosity(mdf,mdu,name_mdu)

% d3d2dflowfm_viscosity : Writes viscosity/diffusvity information to D-Flow FM input files

filgrd = [mdf.pathd3d filesep mdf.filcco];
[~,nameshort,~] = fileparts(name_mdu);
mdu.Filvico     = '';
mdu.Fildico     = '';

%% If space varying:
if simona2mdf_fieldandvalue(mdf,'filedy')
    filedy                   = [mdf.pathd3d filesep mdf.filedy];
    mdu.physics.Vicouv       = -999.999;
    mdu.physics.Dicouv       = -999.999;
    mdu.Filvico              = [nameshort '_vico.xyz'];
    grid                     = delft3d_io_grd('read',filgrd);
    mmax                     = grid.mmax;
    nmax                     = grid.nmax;
    xcoor_u                  = grid.u_full.x';
    ycoor_u                  = grid.u_full.y';
    xcoor_v                  = grid.v_full.x';
    ycoor_v                  = grid.v_full.y';

    % read the viscosity/diffusivity values
    edy        = wldep('read',filedy,[mmax nmax],'multiple');

    % Fill LINE struct with viscosity and diffusivity values
    no_edy = 1 ;
    if mdu.physics.Salinity
        no_edy       = 2;
        mdu.Fildico  = [nameshort '_dico.xyz'];
    end

    for i_edy = 1: no_edy
        tmp(i_edy,:,1) = reshape(xcoor_u',mmax*nmax,1);
        tmp(i_edy,:,2) = reshape(ycoor_u',mmax*nmax,1);
        tmp(i_edy,:,3) = reshape(edy(i_edy).Data',mmax*nmax,1);

        tmp(i_edy,mmax*nmax+1:2*mmax*nmax,1) = reshape(xcoor_v',mmax*nmax,1);
        tmp(i_edy,mmax*nmax+1:2*mmax*nmax,2) = reshape(ycoor_v',mmax*nmax,1);
        tmp(i_edy,mmax*nmax+1:2*mmax*nmax,3) = reshape(edy(i_edy).Data',mmax*nmax,1);
    end

    nonan = ~isnan(tmp(1,:,1));

    for i_edy = 1: no_edy
        LINE(i_edy).DATA = num2cell(squeeze(tmp(i_edy,nonan,:)));
    end

    % write viscosity to file
    dflowfm_io_xydata('write',[name_mdu '_vico.xyz'],LINE(1));

    % write diffusivity to file
    if mdu.physics.Salinity dflowfm_io_xydata('write',[name_mdu '_dico.xyz'],LINE(2));end
else

    % Constant values from mdf file
    mdu.physics.Vicouv = mdf.vicouv;
    mdu.physics.Dicouv = mdf.dicouv;
end

%
% Fill additonal paameters releated to viscosity
%
mdu.physics.Smagorinsky = 0.0;
mdu.physics.Elder       = 0;
mdu.physics.irov        = 0;
mdu.physics.wall_ks      = -999.999; % not used so make clear in the input
