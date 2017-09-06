function handles=ddb_ModelMakerToolbox_sfincs_generateBathymetry(handles,id,datasets,varargin)

icheck=1;
overwrite=1;
filename=[];
modeloffset=0;

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

%% Check should NOT be performed when called by CSIPS toolbox
if icheck
    % Check if there is already a grid
    if isempty(handles.model.sfincs.domain(id).gridx)
        ddb_giveWarning('Warning','First generate or load a grid');
        return
    end
    % File name
    if isempty(handles.model.sfincs.domain(id).input.depfile)
        handles.model.sfincs.domain(id).input.depfile=[handles.model.sfincs.domain.attName '.dep'];
    end
    [filename,ok]=gui_uiputfile('*.dep', 'Depth File Name',handles.model.sfincs.domain(id).input.depfile);
    if ~ok
        return
    end
    % Check if there is already data in depth matrix
    dmax=max(max(handles.model.sfincs.domain(id).gridz));
    if isnan(dmax)
        overwrite=1;
    else
        ButtonName = questdlg('Overwrite existing bathymetry?', ...
            'Delete existing bathymetry', ...
            'Cancel', 'No', 'Yes', 'Yes');
        switch ButtonName,
            case 'Cancel',
                return;
            case 'No',
                overwrite=0;
            case 'Yes',
                overwrite=1;
        end
    end
end

%% Grid coordinates and type
xg=handles.model.sfincs.domain(id).gridx;
yg=handles.model.sfincs.domain(id).gridy;
zg=handles.model.sfincs.domain(id).gridz;
gridtype='structured';

%% Generate bathymetry
[xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets,'filename',filename,'overwrite',overwrite,'gridtype',gridtype,'modeloffset',modeloffset);

inp=handles.model.sfincs.domain(id).input;

%% Update model data
handles.model.sfincs.domain(id).gridz=zg;
% Depth file
handles.model.sfincs.domain(id).input.depfile=filename;
%handles.model.sfincs.domain(id).depthsource='file';
gridz=handles.model.sfincs.domain(id).gridz';
%gridz(isnan(gridz))=-99;
%gridz=min(gridz,20);

%xy=landboundary('read','texas_land.pli');
xy=landboundary('read','southflorida.pli');
msk=sfincs_make_mask(xg',yg',gridz,[-2 100],'includepolygon',xy);
% msk=sfincs_make_mask(xg',yg',gridz,[-2 100],'includepolygon',xy);
msk(isnan(gridz))=0;
gridz(msk==0)=NaN;

%% Create domain

% Binary input

% Index file
indices=find(msk>0);
mskv=msk(msk>0);
fid=fopen(inp.indexfile,'w');
fwrite(fid,length(indices),'integer*4');
fwrite(fid,indices,'integer*4');
fclose(fid);

% Depth file
zv=gridz(~isnan(gridz));

% zv=zeros(size(zv))+5;

fid=fopen(inp.depfile,'w');
fwrite(fid,zv,'real*4');
fclose(fid);

% Mask file
fid=fopen(inp.mskfile,'w');
fwrite(fid,mskv,'integer*1');
fclose(fid);

%     % ASCII input
%
%     % Depth file
%     z(isnan(z))=-999;
%     save([name filesep depfile],'-ascii','z');
%
%     % Mask file
%     dlmwrite([name filesep mskfile],msk,'delimiter',' ');

%     % Create geomask file
%     dlon=0.01;
%     ddb_cfm_make_geomask(name,[name '.xml'],inp.indexfile,inp.mskfile,inp.geomskfile,inp.mmax,inp.nmax,dlon)
dlon=0.00100;

handles.model.sfincs.domain(id).input.geomskfile='sfincs.geomsk';

inp=handles.model.sfincs.domain(id).input;
cs=handles.screenParameters.coordinateSystem;
sfincs_make_geomask_file(inp.geomskfile,inp.x0,inp.y0,inp.dx,inp.dy,inp.mmax,inp.nmax,inp.rotation,inp.indexfile,inp.mskfile,dlon,cs);
%sfincs_make_geomask_file(geomaskfile,x0,y0,dx,dy,mmax,nmax,rotation,indexfile,maskfile,dlon,cs)

%gridz(gridz<0)=NaN;
%gridz(isnan(gridz))=-99;
% save(filename,'-ascii','gridz');




%ddb_wldep('write',filename,handles.model.sfincs.domain(id).gridz);
% Workaround
%handles.model.sfincs.domain(id).bedlevel=filename;
%handles.model.sfincs.domain(id).depthsource='file';
% Plot
% handles=ddb_sfincs_plotBathy(handles,'plot',id);
