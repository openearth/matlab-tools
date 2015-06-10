function handles=ddb_generateGridXBeach(handles,id,x,y,varargin)

if ~isempty(varargin)
    % Check if routine exists
    if strcmpi(varargin{1},'ddb_test')
        return
    end
end

ddb_plotXBeach(handles,'delete',id);
handles=ddb_initializeXBeach(handles,'griddependentinput',id,handles.Model(handles.ActiveModel.Nr).Input(id).Runid);

set(gcf,'Pointer','arrow');

grdx='x.grd';
grdy='y.grd';

if strcmpi(handles.ScreenParameters.CoordinateSystem.Type,'geographic')
    coord='Spherical';
else
    coord='Cartesian';
end    

fid=fopen(grdx,'wt');
nrows=size(x,1);
fprintf(fid,[repmat('%15.7e ',1,nrows) '\n'],x);
fclose(fid);

fid=fopen(grdy,'wt');
nrows=size(x,1);
fprintf(fid,[repmat('%15.7e ',1,nrows) '\n'],y);
fclose(fid);

handles.GUIHandles.XBeachInput(id).xfile=grdx;
handles.GUIHandles.XBeachInput(id).yfile=grdy;

handles.GUIHandles.XBeachInput(id).GridX=x;
handles.GUIHandles.XBeachInput(id).GridY=y;

[handles.GUIHandles.XBeachInput(id).GridXZ,handles.GUIHandles.XBeachInput(id).GridYZ]=GetXZYZ(x,y);

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.GUIHandles.XBeachInput(id).Depth=nans;
handles.GUIHandles.XBeachInput(id).DepthZ=nans;

handles.GUIHandles.XBeachInput(id).MMax=size(x,1)+1;
handles.GUIHandles.XBeachInput(id).NMax=size(x,2)+1;
handles.GUIHandles.XBeachInput(id).KMax=1;



