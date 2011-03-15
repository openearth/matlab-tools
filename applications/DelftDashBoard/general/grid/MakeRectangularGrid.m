function [x,y]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,zmax,xb,yb,zb)

% Initial grid

[x0,y0]=meshgrid(0:dx:nx*dx,0:dy:ny*dy);

if rot~=0
    
    r=[cos(rot) -sin(rot) ; sin(rot) cos(rot)];
    
    for i=1:size(x0,1)
        for j=1:size(x0,2)
            v0=[x0(i,j) y0(i,j)]';
            v=r*v0;
            x(i,j)=v(1);
            y(i,j)=v(2);
        end
    end
else
    x=x0;
    y=y0;
end

x=x+xori;
y=y+yori;

x0=x';
y0=y';

x=zeros(size(x0,1)+1,size(x0,2)+1);
y=x;
x(x==0.0)=NaN;
y(y==0.0)=NaN;
x(1:end-1,1:end-1)=x0;
y(1:end-1,1:end-1)=y0;

x=x0;
y=y0;

clear x0 y0

% Generate initial bathymetry

z=interp2(xb,yb,zb,x,y);

clear xb yb zb

nx=size(x,1);
ny=size(x,2);
for i=1:nx
    for j=1:ny
        im1=max(1,i-1);
        ip1=min(nx,i+1);
        jm1=max(1,j-1);
        jp1=min(ny,j+1);
        zzz(1)=z(im1,jp1);
        zzz(2)=z(i  ,jp1);
        zzz(3)=z(ip1,jp1);
        zzz(4)=z(im1,j  );
        zzz(5)=z(i  ,j  );
        zzz(6)=z(ip1,j  );
        zzz(7)=z(im1,jm1);
        zzz(8)=z(i  ,jm1);
        zzz(9)=z(ip1,jm1);
        if min(zzz)>zmax
            x(i,j)=NaN;
            y(i,j)=NaN;
        end
    end
end

clear z

m1=0;
m2=nx+1;
for i=1:nx
    if isnan(max(x(i,:)))
        m1=i;
    else
        break
    end
end

for i=nx:-1:1
    if isnan(max(x(i,:)))
        m2=i;
    else
        break
    end
end

n1=0;
n2=ny+1;
for i=1:ny
    if isnan(max(x(:,i)))
        n1=i;
    else
        break
    end
end

for i=ny:-1:1
    if isnan(max(x(:,i)))
        n2=i;
    else
        break
    end
end

x=x(m1+1:m2-1,n1+1:n2-1);
y=y(m1+1:m2-1,n1+1:n2-1);
%z=z(m1+1:m2-1,n1+1:n2-1);

mmax=size(x,1);
nmax=size(x,2);

iac=zeros(size(x));
iac(~isnan(x))=1;

for i=1:mmax
    for j=1:nmax
        deac=0;
        if iac(i,j)==1
            if i==1 && j==1
                if ~iac(i+1,j) || ~iac(i,j+1)
                    deac=1;
                end
            elseif i==mmax && j==1
                if ~iac(i-1,j) || ~iac(i,j+1)
                    deac=1;
                end
            elseif i==1 && j==nmax
                if ~iac(i+1,j) || ~iac(i,j-1)
                    deac=1;
                end
            elseif i==mmax && j==nmax
                if ~iac(i-1,j) || ~iac(i,j-1)
                    deac=1;
                end
            elseif j==1
                if ~iac(i-1,j) && ~iac(i+1,j)
                    deac=1;
                elseif iac(i-1,j) && iac(i+1,j) && ~iac(i,j+1)
                    deac=1;
                end
            elseif j==nmax
                if ~iac(i-1,j) && ~iac(i+1,j)
                    deac=1;
                elseif iac(i-1,j) && iac(i+1,j) && ~iac(i,j-1)
                    deac=1;
                end
            elseif i==1
                if ~iac(i,j-1) && ~iac(i,j+1)
                    deac=1;
                elseif iac(i,j-1) && iac(i,j+1) && ~iac(i+1,j)
                    deac=1;
                end
            elseif i==mmax
                if ~iac(i,j-1) && ~iac(i,j+1)
                    deac=1;
                elseif iac(i,j-1) && iac(i,j+1) && ~iac(i-1,j)
                    deac=1;
                end
            else
                if iac(i-1,j) && iac(i+1,j) && ~iac(i,j-1) && ~iac(i,j+1)
                    deac=1;
                elseif ~iac(i-1,j) && ~iac(i+1,j) && iac(i,j-1) && iac(i,j+1)
                    deac=1;
                elseif ~iac(i-1,j) && ~iac(i+1,j+1) && iac(i,j+1)
                    deac=1;
                elseif ~iac(i,j+1) && ~iac(i+1,j) && iac(i+1,j)
                    deac=1;
                elseif iac(i-1,j+1) && iac(i+1,j+1) && ~iac(i,j+1)
                    % This shouldn't be necessary!
                    deac=1;
                elseif iac(i+1,j+1) && iac(i+1,j-1) && ~iac(i+1,j)
                    % This shouldn't be necessary!
                    deac=1;
                end
            end
        end
        if deac
            iac(i,j)=0;
            x(i,j)=NaN;
            y(i,j)=NaN;
        end
    end
end

% Get rid of lakes etc.

iac2=zeros(size(x));
firstactivation=0;

%while activated==0,
for k=1:1000
    activated=0;
    for i=2:mmax-1
        for j=2:nmax-1
            if iac(i,j) && firstactivation==0
                iac2(i,j)=1;
                firstactivation=1;
                activated=1;
            end
            if iac2(i,j)
                if iac(i-1,j) && ~iac2(i-1,j)
                    iac2(i-1,j)=1;
                    activated=1;
                end
                if iac(i+1,j) && ~iac2(i+1,j)
                    iac2(i+1,j)=1;
                    activated=1;
                end
                if iac(i,j-1) && ~iac2(i,j-1)
                    iac2(i,j-1)=1;
                    activated=1;
                end
                if iac(i,j+1) && ~iac2(i,j+1)
                    iac2(i,j+1)=1;
                    activated=1;
                end
            end
        end
    end
    for i=mmax-1:-1:2
        for j=nmax-1:-1:2
            if iac2(i,j)
                if iac(i-1,j) && ~iac2(i-1,j)
                    iac2(i-1,j)=1;
                    activated=1;
                end
                if iac(i+1,j) && ~iac2(i+1,j)
                    iac2(i+1,j)=1;
                    activated=1;
                end
                if iac(i,j-1) && ~iac2(i,j-1)
                    iac2(i,j-1)=1;
                    activated=1;
                end
                if iac(i,j+1) && ~iac2(i,j+1)
                    iac2(i,j+1)=1;
                    activated=1;
                end
            end
        end
    end
    if activated==0
        break
    end
end

if iac(1,1)
    iac2(1,1)=1;
end
if iac(mmax,1)
    iac2(mmax,1)=1;
end
if iac(1,nmax)
    iac2(1,nmax)=1;
end
if iac(mmax,nmax)
    iac2(mmax,nmax)=1;
end

x(iac2==0)=NaN;
y(iac2==0)=NaN;

clear iac iac2

[x,y,mcut,ncut]=CutNanRows(x,y);
