function z1=derefine3(z0)

nx=size(z0,2);
ny=size(z0,1);

iind=[1 1 1 2 2 2 3 3 3];
jind=[1 2 3 1 2 3 1 2 3];
wgt=[1 2 1 2 4 2 1 2 1];

for k=1:9
%    zz(:,:,k)=z0(iind(k):iind(k)+ny-3,jind(k):jind(k)+nx-3);    
    zz(:,:,k)=z0(iind(k):iind(k)+ny-3,jind(k):jind(k)+nx-3);    
    isn(:,:,k)=~isnan(zz(:,:,k));
    w(:,:,k)=isn(:,:,k)*wgt(k);
end

sumw=sum(w,3);
zz(isnan(zz))=0;

for k=1:9
    zz(:,:,k)=zz(:,:,k).*w(:,:,k);
end

zz=sum(zz,3)./sumw;

if isempty(find(~isnan(z0(2:end-1,2:end-1)), 1))
    % Only NaNs in inner domain
    zz=nan(size(zz));
end

%z1=zz(1:2:end,1:2:end);
z1=zz(1:2:end,1:2:end);

