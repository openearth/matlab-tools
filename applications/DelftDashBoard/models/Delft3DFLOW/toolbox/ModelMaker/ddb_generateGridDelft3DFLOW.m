function handles=ddb_generateGridDelft3DFLOW(handles,id,x,y,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

ddb_plotDelft3DFLOW(handles,'delete',id);
handles=ddb_initializeFlowDomain(handles,'griddependentinput',id,handles.Model(md).Input(id).Runid);

set(gcf,'Pointer','arrow');

AttName=handles.Model(md).Input(id).AttName;

enc=ddb_enclosure('extract',x,y);
grd=[AttName '.grd'];

if strcmpi(handles.ScreenParameters.CoordinateSystem.Type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end    

ddb_wlgrid('write','FileName',grd,'X',x,'Y',y,'Enclosure',enc,'CoordinateSystem',coord);

handles.Model(md).Input(id).GrdFile=grd;
handles.Model(md).Input(id).EncFile=[AttName '.enc'];

handles.Model(md).Input(id).GridX=x;
handles.Model(md).Input(id).GridY=y;

[handles.Model(md).Input(id).GridXZ,handles.Model(md).Input(id).GridYZ]=GetXZYZ(x,y);

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.Model(md).Input(id).Depth=nans;
handles.Model(md).Input(id).DepthZ=nans;

handles.Model(md).Input(id).MMax=size(x,1)+1;
handles.Model(md).Input(id).NMax=size(x,2)+1;
handles.Model(md).Input(id).KMax=1;

handles=ddb_determineKCS(handles);

ddb_plotGrid(x,y,id,'FlowGrid','plot');


