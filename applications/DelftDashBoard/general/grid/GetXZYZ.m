function [xz,yz]=GetXZYZ(x,y)

xz=zeros(size(x));
yz=zeros(size(y));
xz(xz==0)=NaN;
yz(yz==0)=NaN;

x1=x(1:end-1,1:end-1);
x2=x(2:end  ,1:end-1);
x3=x(2:end  ,2:end  );
x4=x(1:end-1,2:end  );

y1=y(1:end-1,1:end-1);
y2=y(2:end  ,1:end-1);
y3=y(2:end  ,2:end  );
y4=y(1:end-1,2:end  );

xz1=0.25*(x1+x2+x3+x4);
yz1=0.25*(y1+y2+y3+y4);

xz(2:end,2:end)=xz1;
yz(2:end,2:end)=yz1;
