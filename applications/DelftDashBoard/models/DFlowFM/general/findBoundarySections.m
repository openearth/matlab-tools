function boundaries=findBoundarySections(netStruc,maxdist,minlev,cstype)

bndLink=netStruc.bndLink;
linkNodes=netStruc.linkNodes;
nodeX=netStruc.nodeX;
nodeY=netStruc.nodeY;
nodeDepth=netStruc.nodeZ;

% Finds boundary points

% Start with first boundary link
node2=linkNodes(bndLink(1),2);

bndNodes(1)=linkNodes(bndLink(1),1);
bndNodes(2)=node2;
nn=2;

iAcBnd=1;
% bndLinkLeft(1)=0;

ph=plot(0,0,'y');
set(ph,'LineWidth',2);
while 1
    % Find links connected to node2
    [ilinks,dummy]=find(linkNodes==node2);
    % And now find the next link that is also a boundary link and that contains
    % node2
    ibr=0;
    %
    for k=1:length(ilinks)
        
        ilnk=ilinks(k);
        
        % Find boundary links that match this link
        ibnd=find(bndLink==ilnk);
        if ~isempty(ibnd)
            % Check if this is not the present link
            if ibnd~=iAcBnd
                nn=nn+1;
                % Next boundary section found
                if node2==linkNodes(ilnk,1)
                    node2=linkNodes(ilnk,2);
                else
                    node2=linkNodes(ilnk,1);
                end
                iAcBnd=ibnd;
                ibr=1;
                bndNodes(nn)=node2;
            end
        end
        if ibr
            break
        end
    end
    if node2==linkNodes(bndLink(1),2)
        break
    end
end

for ii=1:length(bndNodes)
    iNode=bndNodes(ii);
    xx(ii)=nodeX(iNode);
    yy(ii)=nodeY(iNode);
    dd(ii)=nodeDepth(iNode);
end

% And now determine boundary sections
npol=0;
iac=0;
% First find separate polylines that are below minlev and also don't make
% sharp angles
for ii=1:length(xx)
    if ~iac && dd(ii)<=minlev
        % New section started
        npol=npol+1;
        iac=1;
        iPol1(npol)=ii;
    end
    if iac==1
        if ii==length(xx)
            % End of section found
            iac=0;
            iPol2(npol)=ii;
        elseif dd(ii+1)>minlev
            % End of section found
            iac=0;
            iPol2(npol)=ii;
        end
    end
end

% Now find sections shorter than maxdist

for ipol=1:npol
    ifirst=iPol1(ipol);
    ilast=iPol2(ipol);
    pathdist=pathdistance(xx,yy,cstype);
    pathang=pathangle(xx,yy,cstype);
    i1=ifirst;
    np=1;
    polln(ipol).ip(np)=ifirst;
    for j=ifirst:ilast
        if j==ilast
            % Last point found
            np=np+1;
            i1=j;
            polln(ipol).ip(np)=j;
        elseif abs(pathang(j)-pathang(max(1,j-1)))>pi/20
            % Next angle exceeds 10 degrees
            np=np+1;
            i1=j;
            polln(ipol).ip(np)=j;
        elseif pathdist(j)-pathdist(i1)>maxdist
            % Max distance reached at next point 
            np=np+1;
            i1=j;
            polln(ipol).ip(np)=j;
        end
    end
end

% Put everything in structure boundaries
for ipol=1:length(polln)
    for ip=1:length(polln(ipol).ip)
        boundaries(ipol).x(ip)=xx(polln(ipol).ip(ip));
        boundaries(ipol).y(ip)=yy(polln(ipol).ip(ip));
    end
%     boundaries(ipol).filename=['bnd' num2str(ipol,'%0.3i') '.pli'];
%     boundaries(ipol).name=['bnd' num2str(ipol,'%0.3i')];
%     boundaries(ipol).type='waterlevelbnd';
%     for ip=1:length(polln(ipol).ip)
%         boundaries(ipol).x(ip)=xx(polln(ipol).ip(ip));
%         boundaries(ipol).y(ip)=yy(polln(ipol).ip(ip));
%         boundaries(ipol).nodes(ip).componentsfile=[boundaries(ipol).name '_' num2str(ip,'%0.4i') '.cmp'];
%         boundaries(ipol).componentsFile{ip}=[boundaries(ipol).name '_' num2str(ip,'%0.4i') '.cmp'];
%     end
end

