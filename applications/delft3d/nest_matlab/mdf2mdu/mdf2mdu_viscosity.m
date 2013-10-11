function mdu = mdf2mdu_viscosity(mdf,mdu,name_mdu)

% mdf2mdu_friction: Writes friction information to unstruc input files

filgrd = [mdf.pathd3d filesep mdf.filcco];
filedy = [mdf.pathd3d filesep mdf.filedy];
[~,nameshort,~] = fileparts(name_mdu);
mdu.Filvico     = '';
mdu.Fildico     = '';

%% Reads viscosity and diffusivity values from file
if ~isempty(filedy)
    mdu.physics.Vicouv       = -999.999;
    mdu.physics.Dicouv       = -999.999;
    mdu.Filvico              = [nameshort '_vico.xyz'];
    grid                     = delft3d_io_grd('read',filgrd);
    mmax                     = grid.mmax;
    nmax                     = grid.nmax;
    xcoor                    = grid.cor.x';
    ycoor                    = grid.cor.y';
    xcoor(mmax,1:nmax)       = NaN;
    ycoor(mmax,1:nmax)       = NaN;
    xcoor(1:mmax,nmax)       = NaN;
    ycoor(1:mmax,nmax)       = NaN;

    % read the roughness values
    edy        = wldep('read',filedy,[mmax nmax],'multiple');

    % Fill LINE struct with viscosity and diffusivity values
    itel   = 0.;
    no_edy = 1 ;
    if mdu.physics.Salinity
        no_edy       = 2;
        mdu.Fildico  = [nameshort '_dico.xyz'];
    end

    for i_edy = 1: no_edy
        tmp(i_edy,:,1) = reshape(xcoor',mmax*nmax,1);
        tmp(i_edy,:,2) = reshape(ycoor',mmax*nmax,1);
        tmp(i_edy,:,3) = reshape(edy(i_edy).Data',mmax*nmax,1);
    end

    nonan = ~isnan(tmp(1,:,1));

    for i_edy = 1: no_edy
        LINE(i_edy).DATA = num2cell(tmp(i_edy,nonan,i_field));
    end

    % write viscosity to file
    unstruc_io_xydata('write',[name_mdu '_vico.xyz'],LINE(1));

    % write diffusivity to file
    if mdu.physics.Salinity unstruc_io_xydata('write',[name_mdu '_dico.xyz'],LINE(2));end
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
