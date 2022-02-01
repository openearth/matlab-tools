%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17374 $
%$Date: 2021-06-30 13:38:00 +0200 (Wed, 30 Jun 2021) $
%$Author: chavarri $
%$Id: D3D_rework.m 17374 2021-06-30 11:38:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_rework.m $
%
%inpolygon in chunks

function in_bol=inpolygon_chunks(nodesX,nodesY,x_pol,y_pol,nc)

np=numel(nodesX);
npc=floor(np/nc);
idx=1:npc:np;
idx(end)=np+1;
in_bol=false(np,1);

tic;
for kc=1:nc
    idx_loc=idx(kc):1:idx(kc+1)-1;
    in_bol(idx_loc)=inpolygon(nodesX(idx_loc),nodesY(idx_loc),x_pol,y_pol);
    fprintf('%4.2f %% in %5.0f s idx_s = %d idx_f = %d \n',kc/nc*100,toc,idx_loc(1),idx_loc(end));
end

end %function