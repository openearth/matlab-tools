function netStruc=curv2net(xg,yg,z)

%% Get nodes
nnodes=0;
for ii=1:size(xg,1)
    for jj=1:size(xg,2)
        if ~isnan(xg(ii,jj))
            nnodes=nnodes+1;
            nodeX(nnodes,1)=xg(ii,jj);
            nodeY(nnodes,1)=yg(ii,jj);
            nodeDepth(nnodes,1)=z(ii,jj);
            nodenr(ii,jj)=nnodes;
        else
            nodenr(ii,jj)=NaN;
        end
    end
end

%% netStruc links
nlinks=0;
for ii=1:size(xg,1)
    for jj=1:size(xg,2)
        if jj<size(xg,2)
            if ~isnan(xg(ii,jj)) && ~isnan(xg(ii,jj+1))
                nlinks=nlinks+1;
                linkNodes(nlinks,1)=nodenr(ii,jj);
                linkNodes(nlinks,2)=nodenr(ii,jj+1);
                linkType(nlinks,1)=2;
            end
        end
        if ii<size(xg,1)
            if ~isnan(xg(ii,jj)) && ~isnan(xg(ii+1,jj))
                nlinks=nlinks+1;
                linkNodes(nlinks,1)=nodenr(ii,jj);
                linkNodes(nlinks,2)=nodenr(ii+1,jj);
                linkType(nlinks,1)=2;
            end
        end
    end
end

%% Elements
nelems=0;
for ii=1:size(xg,1)-1
    for jj=1:size(xg,2)-1
        if ~isnan(xg(ii,jj)) && ~isnan(xg(ii,jj+1)) && ~isnan(xg(ii+1,jj+1)) && ~isnan(xg(ii+1,jj))
            nelems=nelems+1;
            elemNodes(nelems,1)=nodenr(ii,jj);
            elemNodes(nelems,2)=nodenr(ii,jj+1);
            elemNodes(nelems,3)=nodenr(ii+1,jj+1);
            elemNodes(nelems,4)=nodenr(ii+1,jj);
        end
    end
end

%% Find boundary links

bnd=findboundarysectionsonregulargrid(xg,yg);
nbnd=length(bnd);
for ibnd=1:nbnd
    ii1=bnd(ibnd).m1;
    jj1=bnd(ibnd).n1;
    ii2=bnd(ibnd).m2;
    jj2=bnd(ibnd).n2;
    bndnode1(ibnd)=nodenr(ii1,jj1);
    bndnode2(ibnd)=nodenr(ii2,jj2);
end
    
% br=0;
% % Find first boundary
% for ii=1:size(xg,1)
%     for jj=1:size(xg,2)
%         if ~isnan(xg(ii,jj))
%             ii1=ii;
%             jj1=jj;
%             br=1;
%             break
%         end
%     end
%     if br
%         break
%     end
% end
% 
% % Now find boundaries going counter clockwise
% dr='right';
% nbnd=0;
% ii=ii1;
% jj=jj1;
% while 1
%     switch dr
%         case 'right'
%             drc{1}='down';
%             drc{2}='right';
%             drc{3}='up';
%         case 'up'
%             drc{1}='right';
%             drc{2}='up';
%             drc{3}='left';
%         case 'left'
%             drc{1}='up';
%             drc{2}='left';
%             drc{3}='down';
%         case 'down'
%             drc{1}='left';
%             drc{2}='down';
%             drc{3}='right';
%     end
%     br=0;
%     for idr=1:3
%         switch drc{idr}
%             case{'right'}
%                 if ii<size(xg,1)
%                     if ~isnan(xg(ii+1,jj))
%                         nbnd=nbnd+1;
%                         ii2=ii+1;
%                         jj2=jj;
%                         dr=drc{idr};
%                         br=1;
%                     end
%                 end
%             case{'up'}
%                 if jj<size(xg,2)
%                     if ~isnan(xg(ii,jj+1))
%                         nbnd=nbnd+1;
%                         ii2=ii;
%                         jj2=jj+1;
%                         dr=drc{idr};
%                         br=1;
%                     end
%                 end
%             case{'left'}
%                 if ii>1
%                     if ~isnan(xg(ii-1,jj))
%                         nbnd=nbnd+1;
%                         ii2=ii-1;
%                         jj2=jj;
%                         dr=drc{idr};
%                         br=1;
%                     end
%                 end
%             case{'down'}
%                 if jj>1
%                     if ~isnan(xg(ii,jj-1))
%                         nbnd=nbnd+1;
%                         ii2=ii;
%                         jj2=jj-1;
%                         dr=drc{idr};
%                         br=1;
%                     end
%                 end
%         end
%         if br
%             break
%         end
%     end
%     switch dr
%         case{'up','right'}
%             bndnode1(nbnd)=nodenr(ii,jj);
%             bndnode2(nbnd)=nodenr(ii2,jj2);
%         case{'down','left'}
%             bndnode1(nbnd)=nodenr(ii2,jj2);
%             bndnode2(nbnd)=nodenr(ii,jj);
%     end
%     ii=ii2;
%     jj=jj2;
%     if ii2==ii1 && jj2==jj1
%         % Went around, so break
%         break
%     end
% end

% All boundaries found, now check with which boundaries they match
for ibnd=1:nbnd
    ilnk=find(squeeze(linkNodes(:,1))==bndnode1(ibnd) & squeeze(linkNodes(:,2))==bndnode2(ibnd));
    bndLink(ibnd,1)=ilnk;
end

netStruc.nodeX=nodeX;
netStruc.nodeY=nodeY;
netStruc.nodeZ=nodeDepth;
netStruc.linkNodes=linkNodes;
netStruc.linkType=linkType;
netStruc.elemNodes=elemNodes;
netStruc.bndLink=bndLink;
