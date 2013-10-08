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
    mdu.Fildico              = [nameshort '_dico.xyz'];
    grid                     = delft3d_io_grd('read',filgrd);
    mmax                     = grid.mmax;
    nmax                     = grid.nmax;
    xcoor                    = grid.cor.x';
    ycoor                    = grid.cor.y';

    % read the roughness values
    edy        = wldep('read',filedy,[mmax nmax],'multiple');

    % Fill LINE struct with viscosity and diffusivity values
    itel   = 0.;
    no_edy = 1 ;
    if mdu.physics.Salinity no_edy = 2; end

    for m = 1: mmax - 1
        for n = 1: nmax - 1
            if ~isnan(xcoor(m,n))
                for i_edy = 1: no_edy
                    itel = itel + 1;
                    LINE(i_edy).DATA{itel,1} = xcoor(m,n);
                    LINE(i_edy).DATA{itel,2} = ycoor(m,n);
                    LINE(i_edy).DATA{itel,3} = edy(i_edy).Data(m,n);
                end
            end
        end
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

