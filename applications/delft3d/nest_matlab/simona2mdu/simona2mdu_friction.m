function mdu = simona2mdu_friction(mdf,mdu, name_mdu)

% siminp2mdu_friction: Writes friction information to unstruc input files

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
    xcoor                    = grid.cor.x';
    ycoor                    = grid.cor.y';
    xcoor_u(1:mmax,1:nmax)   = NaN;
    ycoor_u(1:mmax,1:nmax)   = NaN;
    xcoor_v(1:mmax,1:nmax)   = NaN;
    ycoor_v(1:mmax,1:nmax)   = NaN;

    % Determine coordinates velocity points
    % (delft3d_io_grid does not give the right indixes)
    for m = 2 : mmax - 1
        for n = 2: nmax - 1
            xcoor_u(m,n) = 0.5*(xcoor(m  ,n  ) + xcoor(m  ,n-1));
            ycoor_u(m,n) = 0.5*(ycoor(m  ,n  ) + ycoor(m  ,n-1));
            xcoor_v(m,n) = 0.5*(xcoor(m-1,n  ) + xcoor(m  ,n  ));
            ycoor_v(m,n) = 0.5*(ycoor(m-1,n  ) + ycoor(m  ,n  ));
        end
    end

    % read the roughness values
    rgh        = wldep('read',filrgh,[mmax nmax],'multiple');

    % Fill LINE struct with roughness values
    itel = 0.;
    for m = 1: mmax - 1
        for n = 1: nmax - 1
            if ~isnan(xcoor_u(m,n))
                itel = itel + 1;
                LINE.DATA{itel,1} = xcoor_u(m,n);
                LINE.DATA{itel,2} = ycoor_u(m,n);
                LINE.DATA{itel,3} = rgh(1).Data(m,n);
            end
            if ~isnan(xcoor_v(m,n))
                itel = itel + 1;
                LINE.DATA{itel,1} = xcoor_v(m,n);
                LINE.DATA{itel,2} = ycoor_v(m,n);
                LINE.DATA{itel,3} = rgh(2).Data(m,n);
            end
        end
    end

    unstruc_io_xydata('write',[name_mdu '_rgh.xyz'],LINE);
else

    % Constant values from mdf file
    mdu.physics.UnifFrictCoef = 0.5*(mdf.ccofu + mdf.ccofv);
end


