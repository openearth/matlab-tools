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
%inpolygon in chunks

function in_bol=inpolygon_chunks(nodesX,nodesY,x_pol,y_pol,nc)

np=numel(nodesX);
npc=floor(np/nc);
idx=1:npc:np;
idx(end)=np+1;
in_bol=false(np,1);
nc=numel(idx)-1;

tic;
for kc=1:nc
    idx_loc=idx(kc):1:idx(kc+1)-1;
    in_bol(idx_loc)=inpolygon(nodesX(idx_loc),nodesY(idx_loc),x_pol,y_pol);
    fprintf('%4.2f %% in %5.0f s idx_s = %d idx_f = %d \n',kc/nc*100,toc,idx_loc(1),idx_loc(end));
end

end %function