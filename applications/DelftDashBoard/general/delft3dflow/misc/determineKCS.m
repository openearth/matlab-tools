function kcs=determineKCS(x,y)

kcs=zeros(size(x,1)+1,size(x,2)+1);
kcs(kcs==0)=NaN;
kcs1(:,:,1)=x(1:end-1,1:end-1);
kcs1(:,:,2)=x(2:end  ,1:end-1);
kcs1(:,:,3)=x(2:end  ,2:end  );
kcs1(:,:,4)=x(1:end-1,2:end  );
kcs1=sum(kcs1,3);
kcs(2:end-1,2:end-1)=kcs1;
kcs(~isnan(kcs))=1;
kcs(isnan(kcs))=0;
