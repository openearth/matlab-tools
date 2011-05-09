function [faces,vertices,fvc]=trisurface(x,y,z,c,xAct,yAct);
xAct(:,end)=0;
yAct(end,:)=0;
xAct2=[xAct(2:end,1:end); zeros(1,size(xAct,2))];
yAct2=[yAct(1:end,2:end), zeros(size(xAct,1),1)];
vertices=[x(:),y(:),z(:)];
N=size(x,1);

faces=[];
i=find(xAct & yAct);
%length(i)
faces=[i i+1 i+N];
i=find(xAct2 & yAct2);
%length(i)
faces=[faces; i+1 i+N+1 i+N];
i=find(xAct2 & yAct & ~(xAct & yAct2));
%length(i)
faces=[faces; i i+1 i+N+1];
i=find(xAct & yAct2 & ~(xAct2 & yAct));
%length(i)
faces=[faces; i i+N+1 i+N];

i=find(xAct & ~(yAct | yAct2 | [zeros(1,size(xAct,2)); yAct(1:end-1,1:end)] | [zeros(1,size(xAct,2)); yAct2(1:end-1,1:end)]));
%length(i)
faces=[faces; i i i+N];
i=find(yAct & ~(xAct | xAct2 | [zeros(size(yAct,1),1) xAct(1:end,1:end-1)] | [zeros(size(yAct,1),1) xAct2(1:end,1:end-1)]));
%length(i)
faces=[faces; i i i+1];

i=find(xAct|yAct|[zeros(1,size(xAct,2)); yAct(1:end-1,1:end)]|[zeros(size(yAct,1),1) xAct(1:end,1:end-1)]);
fvc=NaN*zeros(size(z(:)));
fvc(i)=c(i);

%i=faces(:,1);
%j=faces(:,2);
%k=faces(:,3);
%dx1=faces(k,1)-faces(j,1);
%dx2=faces(i,1)-faces(j,1);
%dy1=faces(k,2)-faces(j,2);
%dy2=faces(i,2)-faces(j,2);
%dz1=faces(k,3)-faces(j,3);
%dz2=faces(i,3)-faces(j,3);

%facenorm(:,3)=dx1.*dy2-dx2.*dy1;
%facenorm(:,2)=-dx1.*dz2+dx2.*dz1;
%facenorm(:,1)=dy1.*dz2-dy2.*dz1;

