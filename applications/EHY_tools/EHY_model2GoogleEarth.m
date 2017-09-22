function EHY_model2GoogleEarth(varargin)
%% EHY_model2GoogleEarth(varargin)
%
% Based on an D-FLOW FM or Delft3D file (.mdu / .mdf) the model input files
% are converted to kml, so they can be visualised in Google Earth.
%
% Example1: EHY_model2GoogleEarth
% Example2: EHY_model2GoogleEarth('D:\model\model.mdu')
%
% created by Julien Groenenboom, September 2017

%%
if nargin>0
    mdFile=varargin{1};
else
    disp('Open a .mdu or .mdf  file')
    [filename, pathname]=uigetfile('*.*','Open a .mdu or .mdf  file');
    mdFile=[pathname filename];
end
[modelType,mdFile]=EHY_getModelType(mdFile);
if strcmp(modelType,'none')
    error('No .mdu, .mdf or siminp found in this folder')
end
runDir=fileparts(mdFile);
outputDir=[runDir filesep 'EHY_model2GoogleEarth_OUTPUT' filesep];
if ~exist(outputDir); mkdir(outputDir); end
%%
OPT.saveoutputFile=1;
switch modelType
    case 'mdu'
        mdu=dflowfm_io_mdu('read',mdFile);
        
        % net
        if isfield(mdu.geometry,'NetFile') && ~isempty(mdu.geometry.NetFile)
            inputFile=EHY_model2GoogleEarth_checkPath(mdu.geometry.NetFile,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_net.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % landboundary
        if isfield(mdu.geometry,'LandBoundaryFile') && ~isempty(mdu.geometry.LandBoundaryFile)
            inputFile=EHY_model2GoogleEarth_checkPath(mdu.geometry.LandBoundaryFile,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_ldb.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % thin dams
        if isfield(mdu.geometry,'ThinDamFile') && ~isempty(mdu.geometry.ThinDamFile)
            inputFile=EHY_model2GoogleEarth_checkPath(mdu.geometry.ThinDamFile,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_pli.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % dry points
        if isfield(mdu.geometry,'DryPointsFile') && ~isempty(mdu.geometry.DryPointsFile)
            inputFile=EHY_model2GoogleEarth_checkPath(mdu.geometry.DryPointsFile,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_dry.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % Observation points
        if isfield(mdu.output,'ObsFile') && ~isempty(mdu.output.ObsFile)
            inputFile=EHY_model2GoogleEarth_checkPath(mdu.output.ObsFile,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_obs.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % cross sections
        if isfield(mdu.geometry,'CrsFile') && ~isempty(mdu.geometry.CrsFile)
            inputFile=EHY_model2GoogleEarth_checkPath(mdu.geometry.CrsFile,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_crs.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
    case 'mdf'
        mdf=delft3d_io_mdf('read',mdFile);
        
        % .grd
        if isfield(mdf.keywords,'filcco') && ~isempty(mdf.keywords.filcco)
            inputFile=EHY_model2GoogleEarth_checkPath(mdf.keywords.filcco,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_grd.kml'];
            OPT.grdFile=inputFile;
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[1 0 0],OPT);
        end
        
        % .dry
        if isfield(mdf.keywords,'fildry') && ~isempty(mdf.keywords.fildry)
            inputFile=EHY_model2GoogleEarth_checkPath(mdf.keywords.fildry,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_dry.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % .thd
        if isfield(mdf.keywords,'filtd') && ~isempty(mdf.keywords.filtd)
            inputFile=EHY_model2GoogleEarth_checkPath(mdf.keywords.filtd,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_thd.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % .crs
        if isfield(mdf.keywords,'filcrs') && ~isempty(mdf.keywords.filcrs)
            inputFile=EHY_model2GoogleEarth_checkPath(mdf.keywords.filcrs,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_crs.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 0 1],OPT);
        end
        
        % .obs
        if isfield(mdf.keywords,'filsta') && ~isempty(mdf.keywords.filsta)
            inputFile=EHY_model2GoogleEarth_checkPath(mdf.keywords.filsta,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_obs.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,OPT);
        end
        
        % .src
        if isfield(mdf.keywords,'filsrc') && ~isempty(mdf.keywords.filsrc)
            inputFile=EHY_model2GoogleEarth_checkPath(mdf.keywords.filsrc,runDir);
            [~,name]=fileparts(inputFile);
            outputFile=[outputDir name '_src.kml'];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
end
end

function file=EHY_model2GoogleEarth_checkPath(file,runDir)
if strcmp(file(1:3),'/p/')
    file=['p:/' file(4:end)];
end
if isempty(strfind(file,':'))
   file=[runDir filesep file]; 
end
end