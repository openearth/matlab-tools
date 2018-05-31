function gridInfo=EHY_getGridInfo(varargin)

% input parameters
% .grd or .mdf mdu siminp file

% output
% no_layers     % number of layers
% dimensions    % to be implemented
% XY            % to be implemented
% Z             % to be implemented

%% process input from user
if nargin==0
    EHY_getGridInfo_interactive
    return
end

wantedOutput={};
for iV=1:length(varargin)
    if exist(varargin{iV},'file')
        inputFile=varargin{iV};
    else
        wantedOutput{end+1,1}=varargin{iV};
    end
end
if isempty(wantedOutput); error('No wanted output specified'); end

%% determine type of model and type of inputFile
modelType=EHY_getModelType(inputFile);
typeOfModelFile=EHY_getTypeOfModelFile(inputFile);
[pathstr, name, ext] = fileparts(inputFile);

%% get grid info
switch typeOfModelFile
    case {'grid','network'}
        
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
                    E.no_layers=mdf.keywords.mnkmax(3);
                end
                if ismember('dimensions',wantedOutput)
                    E.mnkmax=mdf.keywords.mnkmax;
                end
            case 'simona'
                % to do
        end
    case 'outputfile'
        switch modelType
            case 'dfm'
                if ismember('no_layers',wantedOutput)
                    infonc = ncinfo(inputFile);
                    ncVarInd = strmatch('laydim',{infonc.Dimensions.Name},'exact');
                    if ~isempty(ncVarInd)
                        E.no_layers = infonc.Dimensions(ncVarInd).Length;
                    else
                        E.no_layers=1;
                    end
                end
            case 'd3d'
                if ismember('no_layers',wantedOutput)
                    E.no_layers=vs_get(trih,'his-const',{1},'KMAX','quiet');
                end
            case 'simona'
                if ismember('no_layers',wantedOutput)
                    sds=qpfopen(inputFile);
                    dimen=waqua('readsds',sds,[],'MESH_IDIMEN');
                    E.no_layers   =dimen(18);
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
% inputFile
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