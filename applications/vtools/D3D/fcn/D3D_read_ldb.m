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

%For plotting:

% nldb=numel(ldb);
% for kldb=1:nldb
%     plot(ldb(kldb).cord(:,1),ldb(kldb).cord(:,2),'parent',han.sfig(kr,kc),'color','k','linewidth',prop.lw1,'linestyle','-','marker','none')
% end

function LINE=D3D_read_ldb(paths_ldb_in)

messageOut(NaN,'Loading ldb-file.')

nd=numel(paths_ldb_in);

for kd=1:nd

    filldb = paths_ldb_in{kd,1};
    if exist(filldb,'file')~=2
        error('File does not exist: %s',filldb);
    end
    [~,~,ext]=fileparts(filldb);
    switch ext
        case '.ldb'
            LINE=read_ldb(filldb);
        case '.mat'
            LINE=read_mat(filldb);
        otherwise
            error('No method for extension %s',ext)
    end

end %kd

end %function

%%
%% FUNCTIONS
%%

function LINE=read_ldb(filldb)

warning('Use D3D_io_input and change `fig_map_sal_01`')

LINE   = [];
ldb=landboundary('read',filldb);
idx_ldb=cumsum(isnan(ldb(:,1)))+1; %add 1 to start at 1 rather than 0
nldb=idx_ldb(end); 

for kldb=1:nldb
    LINE(kldb).cord=ldb(idx_ldb==kldb,:);
end %kldb

end %function

%%

function LINE=read_mat(filldb)

load(filldb,'ldb')

LINE.cord=ldb;

end %function