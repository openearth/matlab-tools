function [handles,mcut,ncut]=ddb_makeDDModelOriginalGrid(handles,id1,mdd,ndd)

mmin=mdd(1);
nmin=ndd(1);
mmax=mdd(2);
nmax=ndd(2);

x1=handles.Model(md).Input(id1).gridX;
y1=handles.Model(md).Input(id1).gridY;

x1(mmin+1:mmax-1,nmin+1:nmax-1)=NaN;
y1(mmin+1:mmax-1,nmin+1:nmax-1)=NaN;

sz1=size(x1);
iac1=zeros(sz1);
iac1(isfinite(x1))=1;

% sides
% bottom
for i=mmin+1:mmax-1
    isn=0;
    if nmin==1
        isn=1;
    elseif ~iac1(i,nmin-1)
        isn=1;
    end
    if isn
        x1(i,nmin)=NaN;
        y1(i,nmin)=NaN;
    end
end
% top
for i=mmin+1:mmax-1
    isn=0;
    if nmax==sz1(2)
        isn=1;
    elseif ~iac1(i,nmax+1)
        isn=1;
    end
    if isn
        x1(i,nmax)=NaN;
        y1(i,nmax)=NaN;
    end
end
% left
for j=nmin+1:nmax-1
    isn=0;
    if mmin==1
        isn=1;
    elseif ~iac1(mmin-1,j)
        isn=1;
    end
    if isn
        x1(mmin,j)=NaN;
        y1(mmin,j)=NaN;
    end
end
% right
for j=nmin+1:nmax-1
    isn=0;
    if mmax==sz1(1)
        isn=1;
    elseif ~iac1(mmax+1,j)
        isn=1;
    end
    if isn
        x1(mmax,j)=NaN;
        y1(mmax,j)=NaN;
    end
end

[x1,y1,mcut,ncut]=CutNanRows(x1,y1);

enc1=ddb_enclosure('extract',x1,y1);

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end
ddb_wlgrid('write','FileName',handles.Model(md).Input(ad).grdFile,'X',x1,'Y',y1,'Enclosure',enc1,'CoordinateSystem',coord);

handles.Model(md).Input(id1).gridX=x1;
handles.Model(md).Input(id1).gridY=y1;

