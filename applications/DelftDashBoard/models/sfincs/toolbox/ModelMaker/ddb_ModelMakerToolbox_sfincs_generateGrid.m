function handles=ddb_ModelMakerToolbox_sfincs_generateGrid(handles,varargin)

%% Function generates and plots rectangular grid can be called by ddb_ModelMakerToolbox_quickMode_Delft3DFLOW or
% ddb_CSIPSToolbox_initMode

filename=[];
pathname=[];
opt='new';
id=1;

for ii=1:length(varargin)
    switch lower(varargin{ii})
        case{'filename'}
            filename=varargin{ii+1};
        case{'option'}
            opt=varargin{ii+1};
    end
end

wb = waitbox('Generating grid ...');pause(0.1);

[x,y,z]=ddb_ModelMakerToolbox_makeRectangularGrid(handles);
close(wb);

%% Now start putting things into the sfincs model
handles = ddb_initialize_sfincs_domain(handles, 'new', 1, 'tst');

handles.model.sfincs.domain.gridx     = x;
handles.model.sfincs.domain.gridy     = y;

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.model.sfincs.domain(id).gridz=nans;
handles.model.sfincs.domain(id).input.mmax=size(x,1);
handles.model.sfincs.domain(id).input.nmax=size(x,2);
handles.model.sfincs.domain(id).input.x0=handles.toolbox.modelmaker.xOri;
handles.model.sfincs.domain(id).input.y0=handles.toolbox.modelmaker.yOri;
handles.model.sfincs.domain(id).input.dx=handles.toolbox.modelmaker.dX;
handles.model.sfincs.domain(id).input.dy=handles.toolbox.modelmaker.dY;
handles.model.sfincs.domain(id).input.rotation=handles.toolbox.modelmaker.rotation;

% Put info back
setHandles(handles);

% Plot new domain
handles=ddb_sfincs_plotGrid(handles,'plot','active',1);
