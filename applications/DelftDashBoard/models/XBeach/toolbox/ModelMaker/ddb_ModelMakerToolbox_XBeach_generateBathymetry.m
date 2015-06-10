function handles=ddb_ModelMakerToolbox_XBeach_generateBathymetry(handles,datasets,varargin)

%% Initial settings
icheck=1;
overwrite=1;
filename=[];
id=1;
modeloffset=0;
handles=getHandles;

%% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'check'}
                icheck=varargin{i+1};
            case{'overwrite'}
                overwrite=varargin{i+1};
            case{'filename'}
                filename=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
            case{'modeloffset'}
                modeloffset=varargin{i+1};
        end
    end
end


%% Grid coordinates and type
xg=handles.model.xbeach.domain(id).GridX;
yg=handles.model.xbeach.domain(id).GridY;
zg=handles.model.xbeach.domain(id).Depth;
gridtype='structured';

%% Generate bathymetry
[xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,'filename',filename,'overwrite',overwrite,'gridtype',gridtype,'modeloffset',modeloffset);
handles.model.xbeach.domain(id).Depth= zg;

%% Update model data
zg = zg'
grdz = 'bed.dep';
save(grdz,'zg', '-ascii')

%% Plot
handles=ddb_XBeach_plotBathymetry(handles,'plot','domain',id);

