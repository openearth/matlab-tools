function netstruc1=dflowfm_clip_shallow_areas(netstruc,mindep)

x=netstruc.node.x;
y=netstruc.node.y;
z=netstruc.node.z;

nz1=length(z)+1;
z(nz1)=999;

netlink=netstruc.edge.NetLink;
netelemnode=netstruc.face.NetElemNode;
ncol=size(netelemnode,2);

netelemnode(isnan(netelemnode))=nz1;
netelemnode(netelemnode==0)=nz1;

% Compute mean depth in cell centres
zz=z(netelemnode);

zzmin=min(zz,[],2);

imin=find(zzmin<mindep);

netelemnode(netelemnode==nz1)=NaN;

% Now
inp=false(size(x));
for ii=1:length(imin)
    for jj=1:ncol
        if netelemnode(imin(ii),jj)<nz1
            ind=netelemnode(imin(ii),jj);
            inp(ind)=true;
        end
    end
end
inp=~inp;

node1.x=netstruc.node.x(~inp);
node1.y=netstruc.node.y(~inp);
node1.z=netstruc.node.z(~inp);
node1.n=sum(inp);

n=0;
for ii=1:length(x)
    if ~inp(ii)
        n=n+1;
        ind(ii)=n;
    else
        ind(ii)=0;
    end
end

n=0;
for ii=1:size(netlink,1)
    if ~inp(netlink(ii,1)) && ~inp(netlink(ii,2))
        % both points active
        n=n+1;
        netlink1(n,1)=ind(netlink(ii,1));
        netlink1(n,2)=ind(netlink(ii,2));
    end
end

ncol=size(netelemnode,2);
n=0;
for ii=1:size(netelemnode,1)
    netelemtmp=squeeze(netelemnode(ii,:));
    % Remove NaNs
    netelemtmp=netelemtmp(~isnan(netelemtmp));
    inptmp=inp(netelemtmp);
    % Check if all surrounding points are active
    if all(~inptmp)
        %    if ~inp(netelemnode(ii,1)) && ~inp(netelemnode(ii,2)) && ~inp(netelemnode(ii,3)) && ~inp(netelemnode(ii,4)) && ~inp(netelemnode(ii,5)) && ~inp(netelemnode(ii,6))
        % All surrounding points active
        n=n+1;
        for j=1:ncol
            if ~isnan(netelemnode(ii,j))
                netelemnode1(n,j)=ind(netelemnode(ii,j));
            else
                netelemnode1(n,j)=NaN;
            end
        end
    end
end

netstruc1=netstruc;
netstruc1.node=node1;
netstruc1.edge.NetLink=netlink1;
netstruc1.face.NetElemNode=netelemnode1;
