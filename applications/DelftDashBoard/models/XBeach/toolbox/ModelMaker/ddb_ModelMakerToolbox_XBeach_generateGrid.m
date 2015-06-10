function handles=ddb_ModelMakerToolbox_XBeach_generateGrid(handles,id,varargin)
% Function generates and plots rectangular grid can be called by
% ddb_ModelMakerToolbox_quickMode_XBeach

filename=[];
pathname=[];
for ii=1:length(varargin)
    switch lower(varargin{ii})
        case{'filename'}
            filename=varargin{ii+1};
    end
end

if isempty(filename)
    [filename, pathname, filterindex] = uiputfile('*.grd', 'Grid File Name','x and y.grd');
end


wb = waitbox('Generating grid ...');pause(0.1);
handles.toolbox.modelmaker.zMax = 100000;                  % since XBeach doesnt takes this into account
[x,y,z]=ddb_ModelMakerToolbox_makeRectangularGrid(handles);

grdy='y.grd';
grdx='x.grd';
xm = x'*10000;
ym = y'*10000;
save(grdx,'xm', '-ascii')
save(grdy,'ym', '-ascii')

close(wb);

%% Changing XBeach environment
handles.model.xbeach.domain(id).xfile=grdx;
handles.model.xbeach.domain(id).yfile=grdy;
handles.model.xbeach.domain(id).GridX=x;
handles.model.xbeach.domain(id).GridY=y;

[nx ny] = size(y);
handles.model.xbeach.domain(id).Depth=z;
handles.model.xbeach.domain(id).nx=size(x,1)-1;
handles.model.xbeach.domain(id).ny=size(x,2)-1;

%ddb_plotXBeachGrid(handles,id);
handles=ddb_XBeach_plotGrid(handles,'plot','domain',ad);
setHandles(handles);

