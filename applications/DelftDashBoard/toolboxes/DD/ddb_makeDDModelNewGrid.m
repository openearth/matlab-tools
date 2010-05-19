function [handles,mdd,ndd]=ddb_makeDDModelNewGrid(handles,id1,id2,mdd,ndd,runid)

refm=handles.Toolbox(tb).Input.MRefinement;
refn=handles.Toolbox(tb).Input.NRefinement;

mmin=mdd(1);mmax=mdd(2);
nmin=ndd(1);nmax=ndd(2);

x0=handles.Model(md).Input(id1).GridX;
y0=handles.Model(md).Input(id1).GridY;

x2coarse=x0(mmin:mmax,nmin:nmax);
y2coarse=y0(mmin:mmax,nmin:nmax);

[x2coarse,y2coarse,mcut,ncut]=CutNanRows(x2coarse,y2coarse);
mdd(1)=mdd(1)+mcut(1);
mdd(2)=mdd(2)-mcut(2);
ndd(1)=ndd(1)+ncut(1);
ndd(2)=ndd(2)-ncut(2);
[x2,y2]=ddb_refineD3DGrid(x2coarse,y2coarse,refm,refn);

enc2=ddb_enclosure('extract',x2,y2);
grd2=[runid '.grd'];

%ddb_wlgrid('write',grd2,x2,y2,enc2,handles.ScreenParameters.CoordinateSystem.Type);
if strcmpi(handles.ScreenParameters.CoordinateSystem.Type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end    
ddb_wlgrid('write','FileName',grd2,'X',x2,'Y',y2,'Enclosure',enc2,'CoordinateSystem',coord);

handles.Model(md).Input(id2).GrdFile=[runid '.grd'];
handles.Model(md).Input(id2).EncFile=[runid '.enc'];
handles.Model(md).Input(id2).GridX=x2;
handles.Model(md).Input(id2).GridY=y2;
[handles.Model(md).Input(id2).GridXZ,handles.Model(md).Input(id2).GridYZ]=GetXZYZ(x2,y2);
handles.Model(md).Input(id2).MMax=size(x2,1)+1;
handles.Model(md).Input(id2).NMax=size(x2,2)+1;
handles.ActiveDomain=id2;
handles=ddb_determineKCS(handles);

handles.ActiveDomain=id1;
