%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

% paths=generate_paths_delft3d_4rijn2017v1;
% paths_grd_in=paths.paths_grd_in;
% paths_wr_in=paths.paths_wr_in;
% paths_tdk_out=paths.paths_tdk_out;

%%

function LINE=D3D_read_ldb(paths_ldb_in)

nd=numel(paths_ldb_in);

aux_t=[];

% weifil = paths_tdk_out;

for kd=1:nd

% filgrd = paths_grd_in{kd,1};
filldb = paths_ldb_in{kd,1};

% Initialize
% ldb  = [];
LINE   = [];

% Open and read the D3D Files
% grid   = delft3d_io_grd('read',filgrd);
% xcoor  = grid.cor.x';
% ycoor  = grid.cor.y';

% Read weirs
% ldb=tekal('read',filldb,'loaddata');
ldb=landboundary('read',filldb);

idx_ldb=cumsum(isnan(ldb(:,1)))+1; %add 1 to start at 1 rather than 0

nldb=idx_ldb(end); 

for kldb=1:nldb
    LINE(kldb).cord=ldb(idx_ldb==kldb,:);
end

% figure
% hold on
% for kldb=1:nldb
%     plot(LINE(kldb).cord(:,1),LINE(kldb).cord(:,2));
% end

end

% write file
% if ~isnan(weifil)
% D3D_io_xydata_adapted('write',weifil,LINE);
% end