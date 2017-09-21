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
            file=mdu.geometry.NetFile;
            outputFile=[outputDir strrep(file,'.nc','.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % landboundary
        if isfield(mdu.geometry,'LandBoundaryFile') && ~isempty(mdu.geometry.LandBoundaryFile)
            file=mdu.geometry.LandBoundaryFile;
            outputFile=[outputDir strrep(file,'.ldb','_ldb.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % thin dams
        if isfield(mdu.geometry,'ThinDamFile') && ~isempty(mdu.geometry.ThinDamFile)
            file=mdu.geometry.ThinDamFile;
            outputFile=[outputDir strrep(file,'.pli','_thd.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % dry points
        if isfield(mdu.geometry,'DryPointsFile') && ~isempty(mdu.geometry.DryPointsFile)
            file=mdu.geometry.DryPointsFile;
            [~,~,ext]=fileparts(file)
            outputFile=[outputDir strrep(file,ext,'_dry.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % Observation points
        if isfield(mdu.output,'ObsFile') && ~isempty(mdu.output.ObsFile)
            file=mdu.output.ObsFile;
            outputFile=[outputDir strrep(file,'.xyn','_obs.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % cross sections
        if isfield(mdu.geometry,'CrsFile') && ~isempty(mdu.geometry.CrsFile)
            file=mdu.geometry.CrsFile;
            outputFile=[outputDir strrep(file,'.xyz','_crs.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
    case 'mdf'
        mdf=delft3d_io_mdf('read',mdFile);
        
        % .grd
        if isfield(mdf.keywords,'filcco') && ~isempty(mdf.keywords.filcco)
            OPT.grdFile=[runDir filesep mdf.keywords.filcco];
            file=mdf.keywords.filcco;
            inputFile=[runDir filesep file];
            outputFile=[outputDir strrep(file,'.grd','_grd.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[1 0 0],OPT);
        end
        
        % .dry
        if isfield(mdf.keywords,'fildry') && ~isempty(mdf.keywords.fildry)
            file=mdf.keywords.fildry;
            outputFile=[outputDir strrep(file,'.dry','_dry.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % .thd
        if isfield(mdf.keywords,'filtd') && ~isempty(mdf.keywords.filtd)
            file=mdf.keywords.filtd;
            outputFile=[outputDir strrep(file,'.thd','_thd.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
        
        % .crs
        if isfield(mdf.keywords,'filcrs') && ~isempty(mdf.keywords.filcrs)
            file=mdf.keywords.filcrs;
            outputFile=[outputDir strrep(file,'.crs','_crs.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 0 1],OPT);
        end
        
        % .obs
        if isfield(mdf.keywords,'filsta') && ~isempty(mdf.keywords.filsta)
            file=mdf.keywords.filsta;
            outputFile=[outputDir strrep(file,'.obs','_obs.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,OPT);
        end
        
        % .src
        if isfield(mdf.keywords,'filsrc') && ~isempty(mdf.keywords.filsrc)
            file=mdf.keywords.filsrc;
            outputFile=[outputDir strrep(file,'.src','_src.kml')];
            inputFile=[runDir filesep file];
            [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
        end
end