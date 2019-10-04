function handles=ddb_ModelMakerToolbox_sfincs_generateGrid(handles,varargin)

%% Function generates and plots rectangular grid can be called by ddb_ModelMakerToolbox_quickMode_Delft3DFLOW or
% ddb_CSIPSToolbox_initMode

filename=[];
pathname=[];
opt='new';
id=ad;

for ii=1:length(varargin)
    switch lower(varargin{ii})
        case{'filename'}
            filename=varargin{ii+1};
        case{'option'}
            opt=varargin{ii+1};
    end
end

wb = waitbox('Generating grid ...');pause(0.1);

x0=handles.toolbox.modelmaker.xOri;
y0=handles.toolbox.modelmaker.yOri;
dx=handles.toolbox.modelmaker.dX;
dy=handles.toolbox.modelmaker.dY;
mmax=handles.toolbox.modelmaker.nX;
nmax=handles.toolbox.modelmaker.nY;
rot=mod(handles.toolbox.modelmaker.rotation,360)*pi/180;

[xg0,yg0]=meshgrid(0:dx:mmax*dx,0:dy:nmax*dy);
x = x0 + xg0* cos(rot) + yg0*-sin(rot);
y = y0 + xg0* sin(rot) + yg0*cos(rot);

% Cell centres!
[xz,yz]=getXZYZ(x,y);
x=xz(2:end,2:end);
y=yz(2:end,2:end);
close(wb);

%% Now start putting things into the sfincs model
% handles = ddb_initialize_sfincs_domain(handles, 'new', 1, 'tst');

handles.model.sfincs.domain(id).gridx     = x;
handles.model.sfincs.domain(id).gridy     = y;
handles.model.sfincs.domain(id).gridz     = zeros(size(x));
handles.model.sfincs.domain(id).mask      = zeros(size(x));

nans=zeros(size(x));
nans(nans==0)=NaN;
handles.model.sfincs.domain(id).gridz=nans;
handles.model.sfincs.domain(id).input.mmax=size(x,2);
handles.model.sfincs.domain(id).input.nmax=size(x,1);
handles.model.sfincs.domain(id).input.x0=handles.toolbox.modelmaker.xOri;
handles.model.sfincs.domain(id).input.y0=handles.toolbox.modelmaker.yOri;
handles.model.sfincs.domain(id).input.dx=handles.toolbox.modelmaker.dX;
handles.model.sfincs.domain(id).input.dy=handles.toolbox.modelmaker.dY;
handles.model.sfincs.domain(id).input.rotation=handles.toolbox.modelmaker.rotation;

% Plot new domain
handles=ddb_sfincs_plotGrid(handles,'plot','domain',id,'active',1);

% Put info back
setHandles(handles);


