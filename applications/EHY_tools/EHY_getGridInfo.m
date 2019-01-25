function gridInfo=EHY_getGridInfo(inputFile,varargin)
%% gridInfo=EHY_getGridInfo(inputFile,varargin)
% Get information (specified in varargin{1}) from the provided file
%
% Input Arguments:
% inputFile: 	master definition file (.mdf / .mdu), grid file, outputfile
% varargin{1): 	string or cell array of strings with wanted variables
%               available keyword       returns:
%               no_layers               E.no_layers
%               dimensions              E.MNKmax | no_NetNode & no_NetElem
%               XYcor                   E.Xcor & E.Ycor (=NetNodes)
%               XYcen                   E.Xcen & E.Ycen (=NetElem/faces)
%               depth                   E.depth_cen & depth_cor
%               layer_model             E.layer_model
%               face_nodes_xy           E.face_nodes_x & E.face_nodes_y
%               area                    E.area
%               Z                       E.Zcen & E.Zint
%               layer_perc              E.layer_perc (bed to surface)
% varargin{2:3) <keyword/value> pair
%               stations                celll array of station names
%                                       identical to specified in input for
%                                       EHY_getmodeldata
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2018

%% Initialisation
OPT.stations     = '';
OPT.varName      = 'wl';
OPT              = setproperty(OPT,varargin{2:end});

%% process input from user
if nargin==0 || isempty(inputFile)
    EHY_getGridInfo_interactive;
    return
else
    if isempty(varargin)
        error('No wanted output specified')
    end
    wantedOutput=cellstr(varargin{1});
end

%% determine type of model and type of inputFile
modelType=EHY_getModelType(inputFile);
typeOfModelFile=EHY_getTypeOfModelFile(inputFile);
[pathstr, name, ext] = fileparts(lower(inputFile));

if strcmp(modelType,'dfm') && strcmp(typeOfModelFile,'network')
    % info that is in grid, is probably also be in outputfile
    typeOfModelFile='outputfile';
end

%% get grid info
% order modelType:          dfm, d3d, simona
% order typeOfModelFile:    mdFile,grid/network,
switch modelType
    case 'dfm'
        
        switch typeOfModelFile
            
            case 'mdFile'
                mdu=dflowfm_io_mdu('read',inputFile);
                if ismember('no_layers',wantedOutput)
                    E.no_layers=mdu.geometry.Kmx;
                    if E.no_layers==0
                        E.no_layers=1;
                    end
                end
                if ismember('dimensions',wantedOutput)
                    netFile=EHY_path([fileparts(inputFile) filesep mdu.geometry.NetFile]);
                    F=EHY_getGridInfo(netFile,'dimensions');
                    fldnames=fieldnames(F);
                    for iF=1:length(fldnames)
                        E.(fldnames{iF})=F.(fldnames{iF});
                    end
                end
                if ismember('layer_model',wantedOutput)
                    if mdu.geometry.Layertype==1
                        E.layer_model='sigma-model';
                    elseif mdu.geometry.Layertype==2
                        E.layer_model='z-model';
                    end
                end
                if ismember('layer_perc',wantedOutput)
                    if isfield(mdu.geometry,'StretchCoef') 
                      E.layer_perc=mdu.geometry.StretchCoef;
                    else
                        % assume uniform distribution
                        lyrs=mdu.geometry.Kmx;
                        E.layer_perc=repmat(1/lyrs,lyrs,1);
                    end
                end
            case 'outputfile'
                infonc = ncinfo(inputFile);
                if ismember('no_layers',wantedOutput)
                    ncVarInd = strmatch('laydim',{infonc.Dimensions.Name},'exact'); % old fm version
                    if isempty(ncVarInd)
                        ncVarInd = strmatch('nmesh2d_layer',{infonc.Dimensions.Name},'exact');
                    end
                    if ~isempty(ncVarInd)
                        E.no_layers = infonc.Dimensions(ncVarInd).Length;
                    else
                        E.no_layers=1;
                    end
                end
                if ismember('XYcor',wantedOutput)
                    if ~isempty(strmatch('NetNode_x',{infonc.Variables.Name},'exact')) % old fm version
                        E.Xcor=ncread(inputFile,'NetNode_x');
                        E.Ycor=ncread(inputFile,'NetNode_y');
                    elseif  ~isempty(strmatch('mesh2d_node_x',{infonc.Variables.Name},'exact'))
                        E.Xcor=ncread(inputFile,'mesh2d_node_x');
                        E.Ycor=ncread(inputFile,'mesh2d_node_y');
                    end
                end
                if ismember('XYcen',wantedOutput)
                    if ~isempty(strmatch('FlowElem_xcc',{infonc.Variables.Name},'exact')) % old fm version
                        E.Xcen=ncread(inputFile,'FlowElem_xcc');
                        E.Ycen=ncread(inputFile,'FlowElem_ycc');
                    elseif  ~isempty(strmatch('mesh2d_face_x',{infonc.Variables.Name},'exact'))
                        E.Xcen=ncread(inputFile,'mesh2d_face_x');
                        E.Ycen=ncread(inputFile,'mesh2d_face_y');
                    else
                        disp('Cell center info not found in network. Import grid>export grid in RGFGRID and try again')
                    end
                end
                if ismember('depth',wantedOutput)
                    if nc_isvar(inputFile,'NetNode_z') % old fm version
                        E.depth_cor=ncread(inputFile,'NetNode_z');
                        E.depth_cen=ncread(inputFile,'FlowElem_bl');
                    elseif nc_isvar(inputFile,'mesh2d_node_z')
                        E.depth_cor=ncread(inputFile,'mesh2d_node_z');
                        try; E.depth_cen=ncread(inputFile,'mesh2d_flowelem_bl'); end % depth_cen not always available
                    end
                end
                if ismember('Z',wantedOutput)
                    % his-file
                    if ~isempty(strmatch('LayCoord_cc',{infonc.Variables.Name},'exact')) % old fm version
                        E.Zcen=ncread(inputFile,'LayCoord_cc');
                        E.Zint=ncread(inputFile,'LayCoord_w');
                    elseif ~isempty(strmatch('mesh2d_layer_z',{infonc.Variables.Name},'exact'))
                        E.Zcen=ncread(inputFile,'mesh2d_layer_z');
                        E.Zint=ncread(inputFile,'mesh2d_interface_z');
                    elseif ~isempty(strmatch('zcoordinate_c',{infonc.Variables.Name},'exact'))
                        E.Zcen=permute(ncread(inputFile,'zcoordinate_c'),[3 2 1]);
                        E.Zint=permute(ncread(inputFile,'zcoordinate_w'),[3 2 1]);
                    end
                    
                    % map
                    if ~isempty(strmatch('mesh2d_layer_sigma',{infonc.Variables.Name},'exact'))
                        perc=ncread(inputFile,'mesh2d_interface_sigma');
                        bl=ncread(inputFile,'mesh2d_flowelem_bl');
                        E.Zint=-repmat(bl,1,length(perc)).*repmat(perc',length(bl),1);
                        E.Zcen=(E.Zint(:,2:end)+E.Zint(:,1:end-1))/2;
                        E.thickness=diff(E.Zint,[],2);
                    end
                end
                if ismember('layer_model',wantedOutput)
                    dmy=EHY_getGridInfo(inputFile,'no_layers');
                    if dmy.no_layers==1
                        E.layer_model='-';
                    else
                        if ~isempty(strmatch('mesh2d_layer_z',{infonc.Variables.Name},'exact')) % _map.nc
                            E.layer_model='z-model';
                        elseif ~isempty(strmatch('mesh2d_layer_sigma',{infonc.Variables.Name},'exact')) % _map.nc
                            E.layer_model='sigma-model';
                        elseif ~isempty(strmatch('zcoordinate_c',{infonc.Variables.Name},'exact'))
                            E.layer_model='sigma-model';
                        else % not in merged_map.nc, try to get this info from mdFile
                            try
                                mdFile=EHY_getMdFile(inputFile);
                                gridInfo=EHY_getGridInfo(mdFile,'layer_model');
                                E.layer_model=gridInfo.layer_model;
                            end
                        end
                    end
                end
                if ismember('layer_perc',wantedOutput)
                    if ~isempty(strmatch('mesh2d_layer_sigma',{infonc.Variables.Name},'exact'))
                        E.layer_perc=diff(ncread(inputFile,'mesh2d_interface_sigma'));
                    else % not in merged_map.nc, try to get this info from mdFile
                        try
                            mdFile=EHY_getMdFile(inputFile);
                            gridInfo=EHY_getGridInfo(mdFile,'layer_perc');
                            E.layer_perc=gridInfo.layer_perc;
                        end
                    end
                end
                if ismember('face_nodes_xy',wantedOutput)
                    if ~isempty(strmatch('FlowElemContour_x',{infonc.Variables.Name},'exact')) % *_waqgeom.nc
                        E.face_nodes_x=ncread(inputFile,'FlowElemContour_x');
                        E.face_nodes_y=ncread(inputFile,'FlowElemContour_y');
                    elseif ~isempty(strmatch('mesh2d_face_x_bnd',{infonc.Variables.Name},'exact')) % old fm version
                        E.face_nodes_x=ncread(inputFile,'mesh2d_face_x_bnd');
                        E.face_nodes_y=ncread(inputFile,'mesh2d_face_y_bnd');
                    end
                end
                if ismember('dimensions',wantedOutput)
                    % no_NetNode
                    id=strmatch('nNetNode',{infonc.Dimensions.Name},'exact');
                    if isempty(id)
                        id=strmatch('nmesh2d_node',{infonc.Dimensions.Name},'exact');
                    end
                    if ~isempty(id)
                        E.no_NetNode=infonc.Dimensions(id).Length;
                    end
                    % no_NetElem
                    id=strmatch('nNetElem',{infonc.Dimensions.Name},'exact');
                    if isempty(id)
                        id=strmatch('nmesh2d_face',{infonc.Dimensions.Name},'exact');
                    end
                    if ~isempty(id) && infonc.Dimensions(id).Length~=0
                        E.no_NetElem=infonc.Dimensions(id).Length;
                    end
               end
               if ismember('area',wantedOutput)
                    if ~isempty(strmatch('mesh2d_flowelem_ba',{infonc.Variables.Name},'exact'))
                        E.area=ncread(inputFile,'mesh2d_flowelem_ba');
                    end
               end  

               % If partitioned run, delete ghost cells
               [~, name]=fileparts(inputFile);
               if length(name)>=13 && all(ismember(name(end-7:end-4),'0123456789')) && or(nc_isvar(inputFile,'FlowElemDomain'),nc_isvar(inputFile,'mesh2d_flowelem_domain'))
                   domainNr=str2num(name(end-7:end-4));
                   if nc_isvar(inputFile,'FlowElemDomain')
                       FlowElemDomain=ncread(inputFile,'FlowElemDomain');
                   elseif nc_isvar(inputFile,'mesh2d_flowelem_domain')
                       FlowElemDomain=ncread(inputFile,'mesh2d_flowelem_domain');
                   end
                   if ismember('face_nodes_xy',wantedOutput)
                       E.face_nodes_x(:,FlowElemDomain~=domainNr)=[];
                       E.face_nodes_y(:,FlowElemDomain~=domainNr)=[];
                   end
                   if ismember('XYcen',wantedOutput)
                       E.Xcen(FlowElemDomain~=domainNr)=[];
                       E.Ycen(FlowElemDomain~=domainNr)=[];
                   end
               end

        end % typeOfModelFile
        
    case 'd3d'
        switch typeOfModelFile
            
            case 'mdFile'
                mdf=delft3d_io_mdf('read',inputFile);
                if ismember('no_layers',wantedOutput)
                    E.no_layers=mdf.keywords.MNKmax(3);
                end
                if ismember('dimensions',wantedOutput)
                    E.MNKmax=mdf.keywords.MNKmax;
                end
                
            case {'grid','network'}
                if ismember('XY',wantedOutput)
                    if strcmp(ext,'.grd')
                        grd=delft3d_io_grd('read',inputFile);
                        E.mmax=grd.mmax;
                        E.nmax=grd.nmax;
                        E.xcor=grd.cor.x;
                        E.ycor=grd.cor.y;
                        E.xcen=grd.cen.x;
                        E.ycen=grd.cen.y;
                        E.xu=grd.u.x;
                        E.yu=grd.u.y;
                        E.xv=grd.v.x;
                        E.yv=grd.v.y;
                    end
                end
                
            case 'outputfile'
                if ~isempty(strfind(name,'trih-'))
                    trih=vs_use(inputFile,'quiet');
                    if ismember('no_layers',wantedOutput)
                        E.no_layers=vs_get(trih,'his-const',{1},'KMAX','quiet');
                    end
                    if ismember('dimensions',wantedOutput)
                        E.MNKmax=[vs_get(trih,'his-const',{1},'MMAX','quiet') ...
                            vs_get(trih,'his-const',{1},'NMAX','quiet') ...
                            vs_get(trih,'his-const',{1},'KMAX','quiet')];
                    end
                    if ismember('layer_model', wantedOutput)
                        % Get layer-model
                        % Not sure if layer-model exist on trih file if not
                        % specified in mdf file (not a very elegant solution)
                        E.layer_model='sigma';
                        try  
                            E.layer_model = strtrim(vs_get(trih,'his-const' ,'LAYER_MODEL','quiet'));
                            if strcmpi(E.layer_model,'z-model')
                                zk = vs_get(trih,'his-const' ,'ZK'  ,'quiet');
                            end
                        end
                    end
                    
                    if ismember('Z',wantedOutput)
                        error('Reading of interfaces from trih file moved to EHY_getmodeldata')
                    end
                end
        end % typeOfModelFile
        
    case 'simona'
        switch typeOfModelFile
            
            case 'mdFile'
                siminp=readsiminp(pathstr,[name ext]);
                siminp.File=lower(siminp.File);
                if ismember('no_layers',wantedOutput)
                    lineInd=find(~cellfun(@isempty,strfind(siminp.File,'kmax')));
                    line=regexp(siminp.File(lineInd),'\s+','split');
                    lineInd2=find(~cellfun(@isempty,strfind(line{1,1},'kmax')));
                    E.no_layers=str2num(line{1,1}{lineInd2+1});
                end
                if ismember('dimensions',wantedOutput)
                    keywords={'mmax','nmax','kmax'};
                    for iK=1:length(keywords)
                        lineInd=find(~cellfun(@isempty,strfind(siminp.File,keywords{iK})));
                        line=regexp(siminp.File(lineInd),'\s+','split');
                        lineInd2=find(~cellfun(@isempty,strfind(line{1,1},keywords{iK})));
                        E.MNKmax(1,iK)=str2num(line{1,1}{lineInd2+1});
                    end
                end
            case 'outputfile'
                sds=qpfopen(inputFile);
                dimen=waqua('readsds',sds,[],'MESH_IDIMEN');
                if ismember('no_layers',wantedOutput)
                    E.no_layers   =dimen(18);
                end
                if ismember('dimensions',wantedOutput)
                    E.MNKmax=[dimen(2) dimen(3) dimen(18)];
                end
        end % typeOfModelFile
    case {'sobek3' 'sobek3_new' 'implic'}
        E.no_layers = 1;
end % modelType

%% If selection of stations is specified, reduce output to specified stations only
if ~isempty(OPT.stations) && isfield(E,'Zint')
    Data_stat      = EHY_getRequestedStations(inputFile,OPT.stations,modelType,'varName',OPT.varName);
    stationNrNoNan = Data_stat.stationNrNoNan;
        E.Zcen = tmp.Zcen(:,stationNrNoNan,:);
        E.Zint = tmp.Zint(:,stationNrNoNan,:);
end

%% Output structure E
if ~exist('E','var')
    disp('Could not find any of this data in the provided file');
end
E.inputFile=inputFile;
gridInfo=E;
EHYs(mfilename);
end

function EHY_getGridInfo_interactive
% get inputFile
disp('Open a grid, model inputfile or model outputfile')
[filename, pathname]=uigetfile('*.*','Open a grid, model inputfile or model outputfile');
if isnumeric(filename); disp('EHY_getGridInfo_interactive stopped by user.'); return; end
varargin{1}=[pathname filename];

% wanted output
outputParameters={'no_layers','dimensions'};
option=listdlg('PromptString','Choose wanted output parameters (Use CTRL to select multiple options):','ListString',...
    outputParameters,'ListSize',[300 100]);
if isempty(option); disp('EHY_getGridInfo_interactive was stopped by user');return; end
varargin(2:1+length(option))=outputParameters(option);

input=sprintf('''%s'',',varargin{:});
input=input(1:end-1);

disp([char(10) 'Note that next time you want to get this data, you can also use:'])
disp(['gridInfo = EHY_getGridInfo(' input ');' ])

disp('start retrieving the grid info...')

gridInfo = EHY_getGridInfo(varargin{:});

disp('Finished retrieving the grid info!')
assignin('base','gridInfo',gridInfo);
open gridInfo
disp('Variable ''gridInfo'' created by EHY_getGridInfo_interactive')
end