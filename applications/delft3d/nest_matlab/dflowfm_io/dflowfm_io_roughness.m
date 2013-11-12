function varargout=dflowfm_io_roughness(cmd,varargin)

% FLOWFM_IO_viscosity  read/write D-Flow FM roughness file
%
% See also: dflowfm_io_mdu dflowfm_io_xydata
%
%% Switch read/write

switch lower(cmd)

case 'read'

   %
   %  to implement yet
   %

case 'write'

   filgrd         = varargin{1};
   filrgh         = varargin{2};
   filrgh_dflowfm = varargin{3};

   %
   % Read the grid information
   %

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

    % write the roughness xyz file
    dflowfm_io_xydata('write',filrgh_dflowfm,LINE);
end
