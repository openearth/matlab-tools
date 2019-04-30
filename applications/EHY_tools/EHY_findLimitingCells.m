function EHY_findLimitingCells(varargin)
%% EHY_findLimitingCells(varargin)
%
% Analyse limiting cells from a Delft3D-FM map output file
% Note that the simulation has to be performed on 1 partition only

% Example1: EHY_findLimitingCells
% Example2: EHY_findLimitingCells('D:\model_map.nc')
% Example3: EHY_findLimitingCells('D:\model_002_map.nc') % partitioned run
% Example4: EHY_findLimitingCells('D:\model_002_map.nc','writeMaxVel',0)
% Example5: EHY_findLimitingCells('D:\model_002_map.nc','writeMaxVel',0,'timeseriesDT',1)

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

%% process
outputDir=[fileparts(mapFile) '\..\' OPT.outputDir '\'];
if ~exist(outputDir); mkdir(outputDir); end

% maximum velocities
if OPT.writeMaxVel
    Data = EHY_getMapModelData(mapFile,'varName','uv','mergePartitions',1);
    if ndims(Data.ucy)==2
        mag=sqrt(Data.ucx.^2+Data.ucy.^2);
    else
        mag=max(sqrt(Data.ucx.^2+Data.ucy.^2),[],3); % maximum over depth
    end
    MAXVEL=prctile(mag,OPT.percentile)';
end

% limiting cells
numlimdtFiles=dir([fileparts(mapFile) filesep '*_numlimdt.xyz']);
if ~isempty(numlimdtFiles)
    XYZ=[];
    for iF=1:length(numlimdtFiles)
        XYZ=[XYZ; importdata([fileparts(mapFile) filesep numlimdtFiles(iF).name])];
    end
    Xlim=XYZ(:,1);Ylim=XYZ(:,2);NUMLIMDT=XYZ(:,3);
else
    disp('Reading numlimdt from *_map.nc ...')
    disp('To avoid this, set ''Wrimap_numlimdt = 1'' in the mdu-file')
    time=EHY_getmodeldata_getDatenumsFromOutputfile(mapFile);
    time=time(end);
    Data = EHY_getMapModelData(mapFile,'varName','numlimdt','t0',time,'tend',time,'mergePartitions',1);
    NUMLIMDT=Data.value';
    limInd=find(NUMLIMDT>0);
end

if OPT.writeMaxVel || ~exist('Xlim','var')
    gridInfo=EHY_getGridInfo(mapFile,{'XYcen','no_layers'},'mergePartitions',1);
    Xcen=gridInfo.Xcen;
    Ycen=gridInfo.Ycen;
    if ~exist('Xlim','var')
        Xlim=Xcen(limInd);
        Ylim=Ycen(limInd);
    end
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
    top10ind=1:min([length(Xlim) 10]);
    delft3d_io_xyn('write',strrep(outputFile,'.pol','_top10_obs.xyn'),Xlim(top10ind),Ylim(top10ind),cellstr(num2str(NUMLIMDT(top10ind))))
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
    disp('start reading timestep-info from *his.nc file');
    hisFile=dir([fileparts(mapFile) filesep '*_his.nc']);
    hisFile=[fileparts(mapFile) filesep hisFile(1).name];
    Data = EHY_getmodeldata(hisFile,'','dfm','varName','timestep');
    disp('finished reading timestep-info from *his.nc file');
    
    disp('start reading end part of out.txt')
    runTimeInfo=EHY_runTimeInfo(mapFile);
    meandt=runTimeInfo.aveTimeStep_S;
    disp('finished end part of out.txt')
    
    figure('visible','off');
    hold on; grid on;
    plot(Data.times,Data.val,'b');
    plot([Data.times(1) Data.times(end)],[meandt meandt],'k--');
    xlim([Data.times(1) Data.times(end)]);
    ylim([0 max(Data.val)+0.1*std(Data.val) ]);
    xtick=[get(gca,'xtick')];
    set(gca,'xtick',[xtick(1:2:end)])
    datetick('x','dd-mmm-''yy','keeplimits','keepticks');
    legend({'timestep','mean(timestep)'});
    ylabel('time-varying time step');
    title(['Mean dt (from out.txt): ' num2str(meandt) ' s - Max dt : ' num2str(meandt) ' s'])
    saveas(gcf,[outputDir 'timestep.png']);
    disp(['created figure: ' outputDir 'timestep.png'])
end

end