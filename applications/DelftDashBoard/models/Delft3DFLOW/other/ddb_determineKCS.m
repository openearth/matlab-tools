function handles=ddb_determineKCS(handles)

x=handles.Model(md).Input(ad).GridX;
y=handles.Model(md).Input(ad).GridY;

mmax=size(x,1);
nmax=size(x,2);
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
handles.Model(md).Input(ad).kcs=kcs;
