function [x1,y1,mcut,ncut]=CutNanRows(x0,y0)

% Find number of cells to cut off original grid because entire row or
% column is NaN

nx=size(x0,1);
ny=size(x0,2);

mcut=[0 0];
ncut=[0 0];

% left
for i=1:nx
    if isnan(max(x0(i,:)))
        mcut(1)=i;
    else
        break
    end
end
% right
k=0;
for i=nx:-1:1
    k=k+1;
    if isnan(max(x0(i,:)))
        mcut(2)=k;
    else
        break
    end
end
% bottom
for i=1:ny
    if isnan(max(x0(:,i)))
        ncut(1)=i;
    else
        break
    end
end
% top
k=0;
for i=ny:-1:1
    k=k+1;
    if isnan(max(x0(:,i)))
        ncut(2)=k;
    else
        break
    end
end

m1=1+mcut(1);
m2=nx-mcut(2);
n1=1+ncut(1);
n2=ny-ncut(2);
x1=x0(m1:m2,n1:n2);
y1=y0(m1:m2,n1:n2);

