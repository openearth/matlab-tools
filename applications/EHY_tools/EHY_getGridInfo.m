function gridInfo=EHY_getGridInfo(inputFile,varargin)

% input parameters
% .grd or .mdf mdu siminp file

% output
% no_layers     % number of layers
% dimensions    % to be implemented
% XY            % to be implemented
% Z             % to be implemented
% depth
% projection
%% process input from user
if isempty(inputFile) && nargin==0
    EHY_getGridInfo_interactive;
    return
elseif nargin==0 % If only an inputfile was provided
    inputFile=varargin{1};
    wantedOutput={'no_layers','dimensions'};
else
    wantedOutput=varargin;
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
switch typeOfModelFile
    case {'grid','network'}
        switch modelType
            case 'd3d'
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
        end
    case 'mdFile'
        switch modelType
            case 'dfm'
                mdu=dflowfm_io_mdu('read',inputFile);
                if ismember('no_layers',wantedOutput)
                    E.no_layers=mdu.geometry.Kmx;
                    if E.no_layers==0
                        E.no_layers=1;
                    end
                end
                if ismember('dimensions',wantedOutput)
                    infonc=ncinfo([fileparts(inputFile) filesep mdu.geometry.NetFile]);
                    id=strmatch('nNetNode',{infonc.Dimensions.Name},'exact');
                    if isempty(id)
                        id=strmatch('nmesh2d_node',{infonc.Dimensions.Name},'exact');
                    end
                    if ~isempty(id)
                        E.no_NetNodes=infonc.Dimensions(id).Length;
                    end
                end
            case 'd3d'
                mdf=delft3d_io_mdf('read',inputFile);
                if ismember('no_layers',wantedOutput)
                    E.no_layers=mdf.keywords.MNKmax(3);
                end
                if ismember('dimensions',wantedOutput)
                    E.MNKmax=mdf.keywords.MNKmax;
                end
            case 'simona'
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
        end
    case 'outputfile'
        switch modelType
            case 'dfm'
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
                if ismember('XY',wantedOutput)
                    if ~isempty(strmatch('NetNode_x',{infonc.Variables.Name},'exact')) % old fm version
                        E.node_X=ncread(inputFile,'NetNode_x');
                        E.node_Y=ncread(inputFile,'NetNode_y');
                    elseif  ~isempty(strmatch('mesh2d_node_x',{infonc.Variables.Name},'exact'))
                        E.node_X=ncread(inputFile,'mesh2d_node_x');
                        E.node_Y=ncread(inputFile,'mesh2d_node_y');
                    end
                end
                if ismember('depth',wantedOutput)
                    if ~isempty(strmatch('NetNode_z',{infonc.Variables.Name},'exact')) % old fm version
                        E.node_depthcen=ncread(inputFile,'FlowElem_bl');
                        E.node_depthcor=ncread(inputFile,'NetNode_z');
                    elseif  ~isempty(strmatch('mesh2d_node_z',{infonc.Variables.Name},'exact'))
                        E.node_Z=ncread(inputFile,'mesh2d_node_z');
                    end
                end
                if ismember('Z',wantedOutput)
                    if ~isempty(strmatch('??',{infonc.Variables.Name},'exact')) % old fm version
                        E.node_Zcen=ncread(inputFile,'LayCoord_cc');
                        E.node_Zcor=ncread(inputFile,'LayCoord_w');
                    elseif  ~isempty(strmatch('mesh2d_layer_z',{infonc.Variables.Name},'exact'))
                        E.node_Zcen=ncread(inputFile,'mesh2d_layer_z');
                        E.node_Zcor=ncread(inputFile,'mesh2d_interface_z');
                    end
                end
                if ismember('layer_model',wantedOutput)
                    if ~isempty(strmatch('mesh2d_layer_z',{infonc.Variables.Name},'exact')) % old fm version
                        E.layer_model='z-model';
                    end
                end
                if ismember('face_nodes_xy',wantedOutput)
                    if ~isempty(strmatch('NetElemNode',{infonc.Variables.Name},'exact')) % old fm version
                        NetNode_x=ncread(inputFile,'NetNode_x');
                        NetNode_y=ncread(inputFile,'NetNode_y');
                        NetElemNode=double(ncread(inputFile,'NetElemNode')');
                        E.face_nodes_x=NetNode_x(NetElemNode);
                        E.face_nodes_y=NetNode_y(NetElemNode);
                    elseif ~isempty(strmatch('mesh2d_face_x_bnd',{infonc.Variables.Name},'exact')) % old fm version
                        E.face_nodes_x=ncread(inputFile,'mesh2d_face_x_bnd');
                        E.face_nodes_y=ncread(inputFile,'mesh2d_face_y_bnd');
                    end
                end
            case 'd3d'
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
                elseif ~isempty(strfind(name,'trim-'))
                    trim=vs_use(inputFile,'quiet');
                    if ismember('no_layers',wantedOutput)
                        E.no_layers=vs_get(trih,'his-const',{1},'KMAX','quiet');
                    end
                    if ismember('dimensions',wantedOutput)
                        E.MNKmax=[vs_get(trim,'map-const',{1},'MMAX','quiet') ...
                            vs_get(trim,'map-const',{1},'NMAX','quiet') ...
                            vs_get(trim,'map-const',{1},'KMAX','quiet')];
                    end
                end
            case 'simona'
                sds=qpfopen(inputFile);
                dimen=waqua('readsds',sds,[],'MESH_IDIMEN');
                if ismember('no_layers',wantedOutput)
                    E.no_layers   =dimen(18);
                end
                if ismember('dimensions',wantedOutput)
                    E.MNKmax=[dimen(2) dimen(3) dimen(18)];
                end
        end
end
if ~exist('E','var')
    disp('Could not find this data in the provided file');
    E=struct;
end
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