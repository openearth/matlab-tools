function EHY_findLimitingCells(varargin)
%% EHY_findLimitingCells(varargin)
%
% Analyse limiting cells from a Delft3D-FM map output file
% Note that the simulation has to be performed on 1 partition only

% Example1: EHY_findLimitingCells
% Example2: EHY_findLimitingCells('D:\model_map.nc')
% Example3: EHY_findLimitingCells('D:\model_map.nc','writeMaxVel',0)

% created by Julien Groenenboom, February 2018

%%
OPT.writeMaxVel=1; % write max velocities to a .xyz file
OPT.outputDir='EHY_findLimitingCells_OUTPUT'; % output directory
%
if length(varargin)==0
    [filename, pathname]=uigetfile('*_map.nc','Open the model output file');
    if isnumeric(filename); disp('EHY_findLimitingCells stopped by user.'); return; end
        
    mapFile=[pathname filename];
    
    [writeXyz,~]=  listdlg('PromptString','Want to write the maximum velocities to a .xyz file?',...
        'SelectionMode','single',...
        'ListString',{'Yes','No'},...
        'ListSize',[300 40]);
    if isempty(writeXyz)
        disp('EHY_findLimitingCells stopped by user.'); return;
    elseif writeXyz==2
        OPT.writeMaxVel=0;
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
% old and new definitions
vars={'mesh2d_face_x','FlowElem_xzw';...
    'mesh2d_face_y','FlowElem_yzw';...
    'mesh2d_ucy','ucy';...
    'mesh2d_ucx','ucx';...
    'mesh2d_ucy','ucy';...
    'mesh2d_Numlimdt','numlimdt'};

outputDir=[fileparts(mapFile) '\..\' OPT.outputDir '\'];
if ~exist(outputDir); mkdir(outputDir); end

info=ncinfo(mapFile);
if any(ismember({info.Variables.Name},'mesh2d_face_x'))
    col=1;
elseif any(ismember({info.Variables.Name},'FlowElem_xcc'))
    col=2;
end

if ~isempty(str2num(mapFile(end-10:end-7))) && strcmp(mapFile(end-11),'_')
    msgbox(['You are probably processing a simulation that was using multiple partitions.' char(10),...
        'Please note that the administration of limiting cells in parallel simulations was not 100% correct in previous versions of DFM.' char(10),...
        'This has been fixed for DFM versions >= 1.2.0.8405. More info? > Contact Julien' char(10) char(10),...
        'Work-around for older versions: Use a simulation on one partition.' char(10) char(10),...
        'This script will now get the info from the different domains and merge the limiting cells.']);
    
    mapFiles=dir([fileparts(mapFile) filesep '*_map.nc']);
else
    [pathstr, name, ext]=fileparts(mapFile);
    mapFiles(1).name=[name ext];
end
  
X=[];
Y=[];
XX=[];
YY=[];
NUMLIMDT=[];
MAXVEL=[];

for iF=1:length(mapFiles)
    % iF==1 ; 1 partion run > good
    % iF>1  ; parallel run > not 100% correct at the moment
    mapFile=[fileparts(mapFile) filesep mapFiles(iF).name];

    if length(mapFiles)>1
        disp(['working on mapFile: ' num2str(iF) '/' num2str(length(mapFiles)) ])
        info=ncinfo(mapFile);
    end
        
x=nc_varget(mapFile,vars{1,col});
y=nc_varget(mapFile,vars{2,col});
   X=[X;x];
   Y=[Y;y];
   
ind=find(~cellfun(@isempty,strfind({info.Variables.Name},vars{3,col})));
sizeucy=info.Variables(ind).Size;

% maximum velocities
if OPT.writeMaxVel
    maximum=[];
    step0=1000;
    range=1:step0:sizeucy(2);
    for ii=range
        if ii==range(end)
            step=sizeucy(2)-ii+1;
        else
            step=step0;
        end
        u=nc_varget(mapFile,vars{4,col},[ii-1 0],[step sizeucy(1)]);
        v=nc_varget(mapFile,vars{5,col},[ii-1 0],[step sizeucy(1)]);
        mag=sqrt(u.^2+v.^2);
        if size(mag,2)==1; mag=mag'; end
        maximum=max([maximum; max(mag,[],1)],[],1);
    end
    MAXVEL=[MAXVEL maximum];
end

% numlimdt
ind=find(~cellfun(@isempty,strfind({info.Variables.Name},vars{6,col})));
sizeNumlimdt=info.Variables(ind).Size;
limit=nc_varget(mapFile,vars{6,col},[sizeNumlimdt(2)-1 0],[1 sizeNumlimdt(1)]);

elemIDs=find(limit>0);

xx=[];
yy=[];
nrOfLimiting=[];
for iE=1:length(elemIDs)
    nrOfLimiting=[nrOfLimiting; limit(elemIDs(iE))];
    xx=[xx; x(elemIDs(iE))];
    yy=[yy; y(elemIDs(iE))];
end

[~,I]=sort(nrOfLimiting);
I=flipud(I);
xx=xx(I);
yy=yy(I);
nrOfLimiting=nrOfLimiting(I);

XX=[XX;xx];
YY=[YY;yy];
NUMLIMDT=[NUMLIMDT;nrOfLimiting];
end
% sort
[NUMLIMDT,I]=sort(NUMLIMDT,'descend');
XX=XX(I);
YY=YY(I);

% export
if ~isempty(XX)
    outputFile=[outputDir 'restricting_nodes.pol'];
    io_polygon('write',outputFile,[XX YY])
    copyfile(outputFile,strrep(outputFile,'.pol','.ldb'))
    delft3d_io_xyn('write',strrep(outputFile,'.pol','_obs.xyn'),XX,YY,cellstr(num2str(NUMLIMDT)))
    disp(['You can find the created files in the directory:' char(10) ,...
    fileparts(fileparts(mapFile)) filesep OPT.outputDir filesep])
else
    disp('No limiting cells found')
end
if OPT.writeMaxVel
    outputFile=[outputDir 'maximumVelocities.xyz'];
    disp('start writing maximum velocities')
    dlmwrite([tempdir 'maxvel.xyz'],[X Y MAXVEL'],'delimiter',' ','precision','%20.7f')
    copyfile([tempdir 'maxvel.xyz'],outputFile);
    disp('finished writing maximum velocities')
end
fclose all;

EHYs(mfilename);
end