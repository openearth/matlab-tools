function ddb_OceanModelsToolbox_nestIni(varargin)

if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotOceanModels('activate'); 
    setUIElements('oceanmodelspanel.initialconditions');
else
    %Options selected
    opt=lower(varargin{1});    
    switch opt
        case{'generateini'}
            generateIni;
    end    
end

%%
function generateIni

handles=getHandles;

% Set Delft3D-FLOW input
flow.itDate=handles.Model(md).Input(ad).itDate;
flow.startTime=handles.Model(md).Input(ad).startTime;
flow.stopTime=handles.Model(md).Input(ad).stopTime;
flow.KMax=handles.Model(md).Input(ad).KMax;
flow.thick=handles.Model(md).Input(ad).thick;
flow.vertCoord=handles.Model(md).Input(ad).layerType;
flow.zTop=handles.Model(md).Input(ad).zTop;
flow.zBot=handles.Model(md).Input(ad).zBot;
flow.gridX=handles.Model(md).Input(ad).gridX;
flow.gridY=handles.Model(md).Input(ad).gridY;
flow.gridXZ=handles.Model(md).Input(ad).gridXZ;
flow.gridYZ=handles.Model(md).Input(ad).gridYZ;
flow.depthZ=handles.Model(md).Input(ad).depthZ;

flow.salinity.include=handles.Model(md).Input(ad).salinity.include;
flow.temperature.include=handles.Model(md).Input(ad).temperature.include;
flow.sediments=handles.Model(md).Input(ad).sediments;
flow.nrSediments=handles.Model(md).Input(ad).nrSediments;
flow.tracers=handles.Model(md).Input(ad).tracers;
flow.nrTracers=handles.Model(md).Input(ad).nrTracers;

% Set options
opt=handles.Toolbox(tb).Input.options;

% % Tide file
% ib=strmatch('ModelMaker',{handles.Toolbox(:).name},'exact');
% ii=handles.Toolbox(ib).Input.activeTideModelBC;
% name=handles.tideModels.model(ii).name;
% if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
%     tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
% else
%     tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
% end

% Coordinate system
cs=handles.screenParameters.coordinateSystem;

% File name bct file
[filename, pathname, filterindex] = uiputfile('*.ini', 'Select Initial Conditions File',handles.Model(md).Input(ad).iniFile);
if pathname~=0
    curdir=[lower(cd) '\'];
    if ~strcmpi(curdir,pathname)
        filename=[pathname filename];
    end
    handles.Model(md).Input(ad).iniFile=filename;
    flow.iniFile=filename;
else
    return
end 

opt=handles.Toolbox(tb).Input.options;
opt.waterLevel.IC.datafolder=handles.Toolbox(tb).Input.folder;
opt.waterLevel.IC.dataname=handles.Toolbox(tb).Input.name;
opt.current.IC.datafolder=handles.Toolbox(tb).Input.folder;
opt.current.IC.dataname=handles.Toolbox(tb).Input.name;
opt.salinity.IC.datafolder=handles.Toolbox(tb).Input.folder;
opt.salinity.IC.dataname=handles.Toolbox(tb).Input.name;
opt.temperature.IC.datafolder=handles.Toolbox(tb).Input.folder;
opt.temperature.IC.dataname=handles.Toolbox(tb).Input.name;
opt.inputDir='.\';

wb = waitbox('Generating initial conditions ...');

% % Water levels
% switch handles.Toolbox(tb).Input.options.waterLevel.IC.source
%     case {2,3}
%         % From file
%         % Make large file water level
%         t0=handles.Model(md).Input(ad).startTime;
%         t1=handles.Model(md).Input(ad).stopTime;
%         outfile='TMPOCEAN_waterlevel.mat';
%         errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'waterlevel',t0,t1);
%         if ~isempty(errmsg)
%             close(wb);
%             giveWarning('text',[errmsg ' Boundary generation aborted']);
%             return
%         end
%         opt.waterLevel.IC.file=outfile;
% end

% switch handles.Toolbox(tb).Input.options.waterLevel.IC.source
%     case {1,3}
%         % Astronomic
%         if handles.Toolbox(tb).Input.autoWL
%             % Water levels
%             tempOpenBoundaries=openBoundaries;
%             for i=1:length(tempOpenBoundaries)
%                 tempOpenBoundaries(i).forcing='A';
%                 tempOpenBoundaries(i).type='Z';
%             end
%             [tempOpenBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(tempOpenBoundaries,tidefile,cs);
%             bndFile='TMPOCEAN_wl.bnd';
%             bcaFile='TMPOCEAN_wl.bca';
%             delft3dflow_saveBndFile(tempOpenBoundaries,bndFile);
%             delft3dflow_saveBcaFile(astronomicComponentSets,bcaFile);
%             opt.waterLevel.IC.bndAstroFile=bndFile;
%             opt.waterLevel.IC.astroFile=bcaFile;
%         end
% end

% opt.waterLevel.IC.source='constant';
% 
% % Currents
% switch handles.Toolbox(tb).Input.options.current.IC.source
%     case 1
%         opt.current.IC.source='constant';
%     case 2
%         % From file
%         % Make large file for currents
%         t0=handles.Model(md).Input(ad).startTime;
%         t1=handles.Model(md).Input(ad).stopTime;
%         outfile='TMPOCEAN_current_u.mat';
%         errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'current_u',t0,t1);
%         if ~isempty(errmsg)
%             close(wb);
%             giveWarning('text',[errmsg ' Initial conditions generation aborted']);
%             return
%         end
%         opt.current.IC.file_u=outfile;
%         outfile='TMPOCEAN_current_v.mat';
%         errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'current_v',t0,t1);
%         if ~isempty(errmsg)
%             close(wb);
%             giveWarning('text',[errmsg ' Initial conditions generation aborted']);
%             return
%         end
%         opt.current.IC.file_v=outfile;
%         opt.current.IC.source='file';
% end
% switch handles.Toolbox(tb).Input.options.current.IC.source
%     case {1,3}
%         % Astronomic
%         if handles.Toolbox(tb).Input.autoCur
%             tempOpenBoundaries=openBoundaries;
%             for i=1:length(tempOpenBoundaries)
%                 tempOpenBoundaries(i).forcing='A';
%                 tempOpenBoundaries(i).type='C';
%             end
%             [tempOpenBoundaries,astronomicComponentSets]=ddb_generateTemporaryBoundaryConditions(tempOpenBoundaries,tidefile,cs);
%             bndFile='TMPOCEAN_current.bnd';
%             bcaFile='TMPOCEAN_current.bca';
%             delft3dflow_saveBndFile(tempOpenBoundaries,bndFile);
%             delft3dflow_saveBcaFile(astronomicComponentSets,bcaFile);
%             opt.current.IC.bndAstroFile=bndFile;
%             opt.current.IC.astroFile=bcaFile;
%         end
% end

% Salinity
% switch handles.Toolbox(tb).Input.options.salinity.IC.source
%     case 1
%         opt.salinity.IC.source='constant';
%     case 2
%         opt.salinity.IC.source='file';
%         % Make large file salinity
%         t0=handles.Model(md).Input(ad).startTime;
%         t1=handles.Model(md).Input(ad).stopTime;
%         outfile='TMPOCEAN_salinity.mat';
%         errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'salinity',t0,t1);
%         if ~isempty(errmsg)
%             close(wb);
%             giveWarning('text',[errmsg ' Initial conditions generation aborted']);
%             return
%         end
%         opt.salinity.IC.file=outfile;
%     case 3
%         opt.salinity.IC.source='profile';
%         try
%             opt.salinity.IC.profile=load(handles.Toolbox(tb).Input.options.salinity.IC.profileFile);
%         catch
%             close(wb);
%             giveWarning('text','An error occured while loading salinity profile');
%             return
%         end
% end

% % Temperature
% switch handles.Toolbox(tb).Input.options.temperature.IC.source
%     case 1
%         opt.temperature.IC.source='constant';
%     case 2
%         opt.temperature.IC.source='file';
%         % Make large file temperature
%         t0=handles.Model(md).Input(ad).startTime;
%         t1=handles.Model(md).Input(ad).stopTime;
%         outfile='TMPOCEAN_temperature.mat';
%         errmsg=mergeOceanModelFiles(handles.Toolbox(tb).Input.folder,handles.Toolbox(tb).Input.name,outfile,'temperature',t0,t1);
%         if ~isempty(errmsg)
%             close(wb);
%             giveWarning('text',[errmsg ' Boundary generation aborted']);
%             return
%         end
%         opt.temperature.IC.file=outfile;
%     case 3
%         opt.temperature.IC.source='profile';
%         try
%             opt.temperature.IC.profile=load(handles.Toolbox(tb).Input.options.temperature.IC.profileFile);
%         catch
%             close(wb);
%             giveWarning('text','An error occured while loading temperature profile');
%             return
%         end
% end

try
    makeBctBccIni('ini','flow',flow,'opt',opt,'cs',cs);
%    generateIniFile(flow,opt,handles.Model(md).Input(ad).iniFile);
    handles.Model(md).Input(ad).initialConditions='ini';
    flist=dir('TMPOCEAN*');
    for i=1:length(flist)
        try
            delete(flist(i).name);
        end
    end
    close(wb);
    setHandles(handles);
catch
    close(wb);
    giveWarning('text','An error occured while generating initial conditions!');
end
