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

function ldbs=D3D_read_ldb(paths_ldb_in)

nd=numel(paths_ldb_in);

for kd=1:nd
    filldb = paths_ldb_in{kd,1};
    
    ldb=landboundary('read',filldb);
    idx_ldb=cumsum(isnan(ldb(:,1)))+1; %add 1 to start at 1 rather than 0
    nldb=idx_ldb(end); 
    
    LINE   = [];
    for kldb=1:nldb
        LINE(kldb).cord=ldb(idx_ldb==kldb,:);
    end %kldb
    
    ldbs(kd) = LINE;
end %kd

end %function
