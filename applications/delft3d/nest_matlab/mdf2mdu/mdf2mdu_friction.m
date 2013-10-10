function mdu = mdf2mdu_friction(mdf,mdu, name_mdu)

% mdf2mdu_friction: Writes friction information to unstruc input files

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
    xcoor(end+1,:)           = NaN;
    ycoor(end+1,:)           = NaN; 
    xcoor(:,end+1)           = NaN;
    ycoor(:,end+1)           = NaN;   
    
    % Determine coordinates velocity points
    % (delft3d_io_grid does not give the right indixes)
    xcoor_u(1:mmax-1,2:nmax-1) = 0.5*(xcoor(1:end-1 ,2:end-1) + xcoor(1:end-1  ,1:end-2));
    ycoor_u(1:mmax-1,2:nmax-1) = 0.5*(ycoor(1:end-1 ,2:end-1) + ycoor(1:end-1  ,1:end-2));
    xcoor_v(2:mmax-1,1:nmax-1) = 0.5*(xcoor(2:end-1 ,1:end-1) + xcoor(1:end-2  ,1:end-1));
    ycoor_v(2:mmax-1,1:nmax-1) = 0.5*(ycoor(2:end-1 ,1:end-1) + ycoor(1:end-2  ,1:end-1));
    xcoor_u(mmax,1:nmax) = NaN;
    ycoor_u(mmax,1:nmax) = NaN;
    xcoor_v(1:mmax,nmax) = NaN;
    ycoor_v(1:mmax,nmax) = NaN;

    % read the roughness values
    rgh        = wldep('read',filrgh,[mmax nmax],'multiple');

    % Fill LINE struct with roughness values
    tmp(:,1) = reshape(xcoor_u',mmax*nmax,1);
    tmp(:,2) = reshape(ycoor_u',mmax*nmax,1);
    tmp(:,3) = reshape(rgh(1).Data',mmax*nmax,1);

    tmp(end+1:end+mmax*nmax,1) = reshape(xcoor_v',mmax*nmax,1);
    tmp(end+1:end+mmax*nmax,2) = reshape(ycoor_v',mmax*nmax,1);
    tmp(end+1:end+mmax*nmax,3) = reshape(rgh(2).Data',mmax*nmax,1);

    nonan = ~isnan(tmp(:,1));

    LINE.DATA = num2cell(tmp(nonan,:));

    unstruc_io_xydata('write',[name_mdu '_rgh.xyz'],LINE);
else

    % Constant values from mdf file
    mdu.physics.UnifFrictCoef = 0.5*(mdf.ccofu + mdf.ccofv);
end
