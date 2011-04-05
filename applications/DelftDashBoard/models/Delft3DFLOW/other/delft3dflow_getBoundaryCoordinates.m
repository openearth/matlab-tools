function [xb,yb,zb,alphau,alphav,side,orientation]=delft3dflow_getBoundaryCoordinates(openBoundary,x,y,depthZ,kcs)

mmax=size(x,1);
nmax=size(x,2);

M1=openBoundary.M1;
N1=openBoundary.N1;
M2=openBoundary.M2;
N2=openBoundary.N2;

if (N1>1 && kcs(M1,N1-1)==1 && kcs(M1,N1)==0) && (N2>1 && kcs(M2,N2-1)==1 && kcs(M2,N2)==0)
    % top
    if M2>=M1
        m1=M1-1;
        m2=M2;
        dm=1;
        orientation='positive';
    else
        m1=M1;
        m2=M2-1;
        dm=-1;
        orientation='negative';
    end
    n1=N1-1;
    n2=n1;
    dn=1;
    zb(1)=depthZ(M1,N1-1);
    zb(2)=depthZ(M2,N1-1);
    side='top';
elseif (N1<nmax && kcs(M1,N1+1)==1 && kcs(M1,N1)==0) && (N2<nmax && kcs(M2,N2+1)==1 && kcs(M2,N2)==0)
    % bottom
    if M2>=M1
        m1=M1-1;
        m2=M2;
        dm=1;
        orientation='positive';
    else
        m1=M1;
        m2=M2-1;
        dm=-1;
        orientation='negative';
    end
    n1=N1;
    n2=n1;
    dn=1;
    zb(1)=depthZ(M1,N1+1);
    zb(2)=depthZ(M2,N1+1);
    side='bottom';
elseif (M1>1 && kcs(M1-1,N1)==1 && kcs(M1,N1)==0) && (M2>1 && kcs(M2-1,N2)==1 && kcs(M2,N2)==0)
    % right
    if N2>=N1
        n1=N1-1;
        n2=N2;
        dn=1;
        orientation='positive';
    else
        n1=N1;
        n2=N2-1;
        dn=-1;
        orientation='negative';
    end
    m1=M1-1;
    m2=m1;
    dm=1;
    zb(1)=depthZ(M1-1,N1);
    zb(2)=depthZ(M2-1,N2);
    side='right';
elseif (M1<mmax && kcs(M1+1,N1)==1 && kcs(M1,N1)==0) && (M2<mmax && kcs(M2+1,N2)==1 && kcs(M2,N2)==0)
    % left
    if N2>=N1
        n1=N1-1;
        n2=N2;
        dn=1;
        orientation='positive';
    else
        n1=N1;
        n2=N2-1;
        dn=-1;
        orientation='negative';
    end
    m1=M1;
    m2=m1;
    dm=1;
    zb(1)=depthZ(M1+1,N1);
    zb(2)=depthZ(M2+1,N2);
    side='left';
end

xb=x(m1:dm:m2,n1:dn:n2);
yb=y(m1:dm:m2,n1:dn:n2);


% Find rotation
% End A

dx=xb(2)-xb(1);
dy=yb(2)-yb(1);
if strcmpi(orientation,'negative')
    dx=dx*-1;
    dy=dy*-1;
end
switch lower(side)
    case{'left','right'}
        % u-point
        alphau(1)=atan2(dy,dx)-0.5*pi;
        alphav(1)=atan2(dy,dx);
    case{'bottom','top'}
        % v-point
        alphau(1)=atan2(dy,dx)+0.5*pi;
        alphav(1)=atan2(dy,dx);
end

% End B

dx=xb(end)-xb(end-1);
dy=yb(end)-yb(end-1);
if strcmpi(orientation,'negative')
    dx=dx*-1;
    dy=dy*-1;
end
switch lower(side)
    case{'left','right'}
        % u-point
        alphau(2)=atan2(dy,dx)-0.5*pi;
        alphav(2)=atan2(dy,dx);
    case{'bottom','top'}
        % v-point
        alphau(2)=atan2(dy,dx)+0.5*pi;
        alphav(2)=atan2(dy,dx);
end


