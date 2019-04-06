function EHY_findLimitingCells(varargin)
%% EHY_findLimitingCells(varargin)
%
% Analyse limiting cells from a Delft3D-FM map output file
% Note that the simulation has to be performed on 1 partition only

% Example1: EHY_findLimitingCells
% Example2: EHY_findLimitingCells('D:\model_map.nc')
% Example3: EHY_findLimitingCells('D:\model_map.nc','writeMaxVel',0)

% created by Julien Groenenboom, February 2018

%% Settings
% OPT settings
OPT.writeMaxVel = 1; % write max velocities to a .xyz file
OPT.outputDir   = 'EHY_findLimitingCells_OUTPUT'; % output directory
OPT.percentile  = 90; % Percentile of flow velocities shown in max. velocities
OPT.timeseriesDT= 0; % create figure with dt varying over time

% check user input
if length(varargin)==0
    [filename, pathname]=uigetfile('*_map.nc','Open the model output file');
    if isnumeric(filename); disp('EHY_findLimitingCells stopped by user.'); return; end
    
    mapFile=[pathname filename];
    
    % OPT.writeMaxVel
    [writeMaxVel,~]=  listdlg('PromptString','Want to write the maximum velocities to a .xyz file?',...
        'SelectionMode','single',...
        'ListString',{'Yes','No'},...
        'ListSize',[300 40]);
    if isempty(writeMaxVel)
        disp('EHY_findLimitingCells stopped by user.'); return;
    elseif writeMaxVel==2
        OPT.writeMaxVel=0;
    end
    
    % OPT.timeseriesDT
    [timeseriesDT,~]=  listdlg('PromptString','Want to write the time-varying timestep to a figure?',...
        'SelectionMode','single',...
        'ListString',{'Yes','No'},...
        'ListSize',[300 40]);
    if isempty(timeseriesDT)
        disp('EHY_findLimitingCells stopped by user.'); return;
    elseif timeseriesDT==1
        OPT.timeseriesDT=1;
    end
    
elseif length(varargin)>0
    if strcmp(varargin{1}(end-6:end),'_map.nc')
        mapFile=varargin{1};
    else
        error(['Please use the map output file as input argument, like: ' char(10) 'EHY_findLimitingCells(''D:\model_map.nc'')'])
    end
    if length(varargin)> 1 && mod(length(varargin)-1,2)==0
        OPT = setproperty(OPT,varargin{2:end});
    elseif length(varargin)==1
        % that's the map file
    else
        error('Additional input arguments must be given in pairs.')
    end
end

%%
outputDir=[fileparts(mapFile) '\..\' OPT.outputDir '\'];
if ~exist(outputDir); mkdir(outputDir); end

if ~isempty(str2num(mapFile(end-10:end-7))) && strcmp(mapFile(end-11),'_')
    disp(['  You are probably processing a simulation that used multiple partitions.' char(10),...
        '  Please note that the administration of limiting cells in parallel simulations was not 100% correct in previous versions of DFM.' char(10),...
        '  This has been fixed for DFM versions >= 1.2.0.8405. More info? > Contact Julien' char(10) ,...
        '  Work-around for older versions: Use a simulation on one partition.' char(10) ,...
        '  This script will now get the info from the different domains and merge the limiting cells.']);
    
    mapFiles=dir([fileparts(mapFile) filesep '*_map.nc']);
else
    [pathstr, name, ext]=fileparts(mapFile);
    mapFiles(1).name=[name ext];
end

% initialise ALL (merge the partitions)
Xcen=[];
Ycen=[];
MAXVEL=[];
Xlim=[];
Ylim=[];
NUMLIMDT=[];

for iF=1:length(mapFiles)
    mapFile=[fileparts(mapFile) filesep mapFiles(iF).name];
    
    if length(mapFiles)>1
        disp(['working on mapFile: ' num2str(iF) '/' num2str(length(mapFiles)) ])
    end
    
    gridInfo=EHY_getGridInfo(mapFile,{'XYcen','no_layers'});
    x_part=gridInfo.Xcen; % xCen of partition
    y_part=gridInfo.Ycen; % yCen of partition
    
    % ALL
    Xcen=[Xcen;x_part];
    Ycen=[Ycen;y_part];
    
    % maximum velocities
    if OPT.writeMaxVel
        Data = EHY_getMapModelData(mapFile,'varName','uv');
        if ndims(Data.ucy)==2
            mag=sqrt(Data.ucx.^2+Data.ucy.^2);
        else
            mag=max(sqrt(Data.ucx.^2+Data.ucy.^2),[],3); % maximum over depth
        end
        if size(mag,1)==1
            MAXVEL=[MAXVEL; mag'];
        else
            MAXVEL=[MAXVEL; prctile(mag,OPT.percentile)'];
        end
    end
    
    % limiting cells
    time=EHY_getmodeldata_getDatenumsFromOutputfile(mapFile);
    time=time(end);
    Data = EHY_getMapModelData(mapFile,'varName','numlimdt','t0',time,'tend',time);
    numlimdt_part=Data.value';
    
    limInd=find(numlimdt_part>0);
    NUMLIMDT=[NUMLIMDT; numlimdt_part(limInd)];
    Xlim=[Xlim; x_part(limInd)];
    Ylim=[Ylim; y_part(limInd)];
end

% sort descending
[~,I]=sort(NUMLIMDT);
I=flipud(I);
Xlim=Xlim(I);
Ylim=Ylim(I);
NUMLIMDT=NUMLIMDT(I);

% export
disp(['You can find the created files in the directory:' char(10) outputDir]),...
    
if ~isempty(Xlim)
    outputFile=[outputDir 'restricting_nodes.pol'];
    tekal('write',outputFile,[Xlim Ylim]);
    copyfile(outputFile,strrep(outputFile,'.pol','.ldb'))
    delft3d_io_xyn('write',strrep(outputFile,'.pol','_obs.xyn'),Xlim,Ylim,cellstr(num2str(NUMLIMDT)))
    dlmwrite(strrep(outputFile,'.pol','.xyz'),[Xlim Ylim NUMLIMDT],'delimiter',' ','precision','%20.7f')
    try % copy network to outputDir
        mdFile=EHY_getMdFile(fileparts(fileparts(mapFile)));
        mdu=dflowfm_io_mdu('read',mdFile);
        fullWinPathNetwork=EHY_getFullWinPath(mdu.geometry.NetFile,fileparts(mdFile));
        copyfile(fullWinPathNetwork,outputDir)
    end
else
    disp('No limiting cells found')
end

if OPT.writeMaxVel
    outputFile=[outputDir 'maximumVelocities.xyz'];
    disp('start writing maximum velocities')
    dlmwrite([tempdir 'maxvel.xyz'],[Xcen Ycen MAXVEL],'delimiter',' ','precision','%20.7f')
    copyfile([tempdir 'maxvel.xyz'],outputFile);
    disp('finished writing maximum velocities')
end
fclose all;

%% timeseries of time step
if OPT.timeseriesDT
    disp('start reading timestep-info from *_his.nc file');
    hisFile=dir([fileparts(mapFile) filesep '*_his.nc']);
    hisFile=[fileparts(mapFile) filesep hisFile(1).name];
    Data = EHY_getmodeldata(hisFile,'','dfm','varName','timestep');
    disp('finished reading timestep-info from _his.nc file');
    figure('visible','off');
    hold on; grid on;
    plot(Data.times,Data.val,'b');
    plot([Data.times(1) Data.times(end)],[mean(Data.val) mean(Data.val)],'k--');
    xlim([Data.times(1) Data.times(end)]);
    ylim([0 max(Data.val)+0.1*std(Data.val) ]);
    xtick=[get(gca,'xtick')];
    set(gca,'xtick',[xtick(1:2:end)])
    datetick('x','dd-mmm-''yy','keeplimits','keepticks');
    legend({'timestep','mean(timestep)'});
    ylabel('time-varying time step');
    saveas(gcf,[outputDir 'timestep.png']);
    disp(['created figure: ' outputDir 'timestep.png'])
end

end