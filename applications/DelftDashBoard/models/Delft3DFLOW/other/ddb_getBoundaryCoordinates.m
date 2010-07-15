function [xb,yb,zb,side,orientation]=ddb_getBoundaryCoordinates(handles,id,i)

x=handles.Model(md).Input(id).GridX;
y=handles.Model(md).Input(id).GridY;
mmax=size(x,1);
nmax=size(x,2);
kcs=handles.Model(md).Input(id).kcs;

M1=handles.Model(md).Input(id).OpenBoundaries(i).M1;
N1=handles.Model(md).Input(id).OpenBoundaries(i).N1;
M2=handles.Model(md).Input(id).OpenBoundaries(i).M2;
N2=handles.Model(md).Input(id).OpenBoundaries(i).N2;

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
    zb(1)=handles.Model(md).Input(id).DepthZ(M1,N1-1);
    zb(2)=handles.Model(md).Input(id).DepthZ(M2,N1-1);
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
    zb(1)=handles.Model(md).Input(id).DepthZ(M1,N1+1);
    zb(2)=handles.Model(md).Input(id).DepthZ(M2,N1+1);
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
    zb(1)=handles.Model(md).Input(id).DepthZ(M1-1,N1);
    zb(2)=handles.Model(md).Input(id).DepthZ(M2-1,N2);
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
    zb(1)=handles.Model(md).Input(id).DepthZ(M1+1,N1);
    zb(2)=handles.Model(md).Input(id).DepthZ(M2+1,N2);
    side='left';
end

xb=x(m1:dm:m2,n1:dn:n2);
yb=y(m1:dm:m2,n1:dn:n2);

