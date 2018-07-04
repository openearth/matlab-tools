function EHY_model2GoogleEarth(mdFile,varargin)
%% EHY_model2GoogleEarth(mdFile,varargin)
%
% Based on an D-FLOW FM or Delft3D file (.mdu / .mdf) the model input files
% are converted to kml, so they can be visualised in Google Earth.
%
% Example1: EHY_model2GoogleEarth
% Example2: EHY_model2GoogleEarth('D:\model\model.mdu')
%
% created by Julien Groenenboom, September 2017
%%
OPT.saveOutputFile=1;
OPT.gridColor=[1 0 0];
OPT.ldbColor=[0 1 0];
OPT.thdColor=[0 0 1];
OPT.dryColor=[1 0 0];
OPT.crsColor=[1 1 0];
OPT.dryIconFile='http://maps.google.com/mapfiles/kml/paddle/ylw-square.png';
OPT.obsIconFile='http://maps.google.com/mapfiles/kml/paddle/blu-stars.png';
OPT.srcIconFile='http://maps.google.com/mapfiles/kml/shapes/square.png';

if nargin>1
OPT = setproperty(OPT,varargin{2:end});
end

% create OPT2 to use in EHY_convert-call
OPT2.saveOutputFile=OPT.saveOutputFile;

%%
if nargin==0
    disp('Open a .mdu or .mdf  file')
    [filename, pathname]=uigetfile({'*.mdu';'*.mdf';'*.*'},'Open a .mdu or .mdf file');
    if isnumeric(filename); disp('EHY_model2GoogleEarth stopped by user.'); return; end
    mdFile=[pathname filename];
end
mdFile=EHY_getMdFile(mdFile);
if isempty(mdFile)
    error('No .mdu, .mdf or siminp found in this folder')
end
modelType=EHY_getModelType(mdFile);
runDir=fileparts(mdFile);
outputDir=[runDir filesep 'EHY_model2GoogleEarth_OUTPUT' filesep];
if ~exist(outputDir); mkdir(outputDir); end

%%
switch modelType
    case 'dfm'
        mdu=dflowfm_io_mdu('read',mdFile);
        
        % net
        if isfield(mdu.geometry,'NetFile') && ~isempty(mdu.geometry.NetFile)
            [selection,~]=  listdlg('PromptString','Conversion of nc to kml might take a while, you can also use Hermans GUI, choose:',...
                'SelectionMode','single','ListString',{'Get a coffee and wait (few minutes)','Convert the nc to kml yourself'},'ListSize',[500 100]);
            if selection==1
                inputFile=EHY_getFullWinPath(mdu.geometry.NetFile,runDir);
                [~,name]=fileparts(inputFile);
                OPT2.outputFile=strrep([outputDir name '_net.kml'],'_net_net','_net');
                OPT2.lineColor=OPT.gridColor;
                [~,OPT2]=EHY_convert(inputFile,'kml',OPT2);
            end
        end
        
        % landboundary
        if isfield(mdu.geometry,'LandBoundaryFile') && ~isempty(mdu.geometry.LandBoundaryFile)
            inputFile=EHY_getFullWinPath(mdu.geometry.LandBoundaryFile,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=[outputDir name '_ldb.kml'];
            OPT2.lineColor=OPT.ldbColor;
            [~,OPT2]=EHY_convert(inputFile,'kml',OPT2);
        end
        
        % thin dams
        if isfield(mdu.geometry,'ThinDamFile') && ~isempty(mdu.geometry.ThinDamFile)
            inputFile=EHY_getFullWinPath(mdu.geometry.ThinDamFile,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=strrep([outputDir name '_thd.kml'],'_thd_thd','_thd');
            OPT2.lineColor=OPT.thdColor;
            [~,OPT2]=EHY_convert(inputFile,'kml','lineWidth',4,OPT2);
        end
        
        % dry points
        if isfield(mdu.geometry,'DryPointsFile') && ~isempty(mdu.geometry.DryPointsFile)
            inputFile=EHY_getFullWinPath(mdu.geometry.DryPointsFile,runDir);
            [~,name,ext]=fileparts(inputFile);
            OPT2.netFile=EHY_getFullWinPath(mdu.geometry.NetFile,runDir);
            if strcmpi(ext,'.pol')
                [~,OPT2]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 0 1],OPT2);
            elseif strcmpi(ext,'.xyz')
                try
                    OPT2.outputFile=[outputDir name '_xdry.kml'];
                    OPT2.lineColor=OPT.dryColor;
                    [~,OPT2]=EHY_convert(inputFile,'xdrykml',OPT2);
                end
                OPT2.outputFile=[outputDir name '_dry.kml'];
                OPT2.iconFile=OPT.dryIconFile;
                [~,OPT2]=EHY_convert(inputFile,'kml',OPT2);
            end
        end
        
        % Observation points
        if isfield(mdu.output,'ObsFile') && ~isempty(mdu.output.ObsFile)
            inputFile=EHY_getFullWinPath(mdu.output.ObsFile,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=[outputDir name '_obs.kml'];
            OPT2.iconFile=OPT.obsIconFile;
            [~,OPT2]=EHY_convert(inputFile,'kml',OPT2);
        end
        
        % cross sections
        if isfield(mdu.geometry,'CrsFile') && ~isempty(mdu.geometry.CrsFile)
            inputFile=EHY_getFullWinPath(mdu.geometry.CrsFile,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=[outputDir name '_crs.kml'];
            OPT2.lineColor=OPT.crsColor;
            [~,OPT2]=EHY_convert(inputFile,'kml','lineWidth',4,OPT2);
        end
        
    case 'd3d'
        mdf=delft3d_io_mdf('read',mdFile);
        
        % .grd
        if isfield(mdf.keywords,'filcco') && ~isempty(mdf.keywords.filcco)
            inputFile=EHY_getFullWinPath(mdf.keywords.filcco,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=[outputDir name '_grd.kml'];
            OPT2.grdFile=inputFile;
            OPT2.lineColor=OPT.gridColor;
            [~,OPT2]=EHY_convert(inputFile,'kml',OPT2);
        end
        
        % .dry
        if isfield(mdf.keywords,'fildry') && ~isempty(mdf.keywords.fildry)
            inputFile=EHY_getFullWinPath(mdf.keywords.fildry,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=[outputDir name '_dry.kml'];
            OPT2.lineColor=OPT.dryColor;
            [~,OPT2]=EHY_convert(inputFile,'xdrykml',OPT2);
        end
        
        % .thd
        if isfield(mdf.keywords,'filtd') && ~isempty(mdf.keywords.filtd)
            inputFile=EHY_getFullWinPath(mdf.keywords.filtd,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=[outputDir name '_thd.kml'];
            OPT2.lineColor=OPT.thdColor;
            [~,OPT2]=EHY_convert(inputFile,'kml','lineWidth',4,OPT2);
        end
        
        % .crs
        if isfield(mdf.keywords,'filcrs') && ~isempty(mdf.keywords.filcrs)
            inputFile=EHY_getFullWinPath(mdf.keywords.filcrs,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=[outputDir name '_crs.kml'];
            OPT2.lineColor=OPT.crsColor;
            [~,OPT2]=EHY_convert(inputFile,'kml','lineWidth',4,OPT2);
        end
        
        % .obs
        if isfield(mdf.keywords,'filsta') && ~isempty(mdf.keywords.filsta)
            inputFile=EHY_getFullWinPath(mdf.keywords.filsta,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=[outputDir name '_obs.kml'];
            OPT2.iconFile=OPT.obsIconFile;
            [~,OPT2]=EHY_convert(inputFile,'kml',OPT2);
        end
        
        % .src
        if isfield(mdf.keywords,'filsrc') && ~isempty(mdf.keywords.filsrc)
            inputFile=EHY_getFullWinPath(mdf.keywords.filsrc,runDir);
            [~,name]=fileparts(inputFile);
            OPT2.outputFile=[outputDir name '_src.kml'];
            OPT2.iconFile=OPT.srcIconFile;
            [~,OPT2]=EHY_convert(inputFile,'kml',OPT2);
        end
end
EHYs(mfilename);
end
