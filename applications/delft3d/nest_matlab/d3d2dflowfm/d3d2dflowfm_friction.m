function mdu = d3d2dflowfm_friction(mdf,mdu, name_mdu)

% d3d2dflwfm_friction: Writes friction information to D-Flow FM input files

filgrd = [mdf.pathd3d filesep mdf.filcco];
filrgh = [mdf.pathd3d filesep mdf.filrgh];
[~,nameshort,~] = fileparts(name_mdu);
mdu.Filrgh      = '';

%% Determine friction type
if strcmpi(mdf.roumet,'c') mdu.physics.UnifFrictType = 0;end
if strcmpi(mdf.roumet,'m') mdu.physics.UnifFrictType = 1;end
if strcmpi(mdf.roumet,'w') mdu.physics.UnifFrictType = 2;end
if strcmpi(mdf.roumet,'z') mdu.physics.UnifFrictType = 3;end

%% Reads roughness values from file
if ~isempty(filrgh)
    mdu.physics.UnifFrictCoef = -999.999;
    mdu.Filrgh               = [nameshort '_rgh.xyz'];
    grid                     = delft3d_io_grd('read',filgrd);
    mmax                     = grid.mmax;
    nmax                     = grid.nmax;
    xcoor_u                  = grid.u_full.x';
    ycoor_u                  = grid.u_full.y';
    xcoor_v                  = grid.v_full.x';
    ycoor_v                  = grid.v_full.y';

    % read the roughness values
    rgh        = wldep('read',filrgh,[mmax nmax],'multiple');

    % Fill LINE struct with roughness values
    tmp(:,1) = reshape(xcoor_u',mmax*nmax,1);
    tmp(:,2) = reshape(ycoor_u',mmax*nmax,1);
    tmp(:,3) = reshape(rgh(1).Data',mmax*nmax,1);

    no_val = size(tmp,1);

    tmp(no_val+1:no_val+mmax*nmax,1) = reshape(xcoor_v',mmax*nmax,1);
    tmp(no_val+1:no_val+mmax*nmax,2) = reshape(ycoor_v',mmax*nmax,1);
    tmp(no_val+1:no_val+mmax*nmax,3) = reshape(rgh(2).Data',mmax*nmax,1);

    nonan = ~isnan(tmp(:,1));

    LINE.DATA = num2cell(tmp(nonan,:));

    dflowfm_io_xydata('write',[name_mdu '_rgh.xyz'],LINE);
else

    % Constant values from mdf file
    mdu.physics.UnifFrictCoef = 0.5*(mdf.ccofu + mdf.ccofv);
end
