function handles=ddb_generateGridDelft3DFLOW(handles,id,x,y,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

ddb_plotDelft3DFLOW('delete','domain',id);
handles=ddb_initializeFlowDomain(handles,'griddependentinput',id,handles.Model(md).Input(id).runid);

set(gcf,'Pointer','arrow');

attName=handles.Model(md).Input(id).attName;

enc=ddb_enclosure('extract',x,y);
grd=[attName '.grd'];

if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end    

ddb_wlgrid('write','FileName',grd,'X',x,'Y',y,'Enclosure',enc,'CoordinateSystem',coord);

handles.Model(md).Input(id).grdFile=grd;
handles.Model(md).Input(id).encFile=[attName '.enc'];

handles.Model(md).Input(id).gridX=x;
handles.Model(md).Input(id).gridY=y;

[handles.Model(md).Input(id).gridXZ,handles.Model(md).Input(id).gridYZ]=GetXZYZ(x,y);

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.Model(md).Input(id).depth=nans;
handles.Model(md).Input(id).depthZ=nans;

handles.Model(md).Input(id).MMax=size(x,1)+1;
handles.Model(md).Input(id).NMax=size(x,2)+1;
handles.Model(md).Input(id).KMax=1;

handles=ddb_determineKCS(handles,id);

handles=ddb_Delft3DFLOW_plotGrid(handles,'plot','domain',id);


