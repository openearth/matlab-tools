function EHY_model2GoogleEarth(varargin)
%% EHY_model2GoogleEarth(varargin)
%
% Based on an D-FLOW FM, Delft3D or SIMONA input file (.mdu / .mdf /
% siminp) the simulation period, calculation time and corresponding
% computational time is computed.
%
% Example1: EHY_model2GoogleEarth
% Example2: EHY_model2GoogleEarth('D:\model\model.mdu')
%
% created by Julien Groenenboom, September 2017

%%
if nargin>0
    mdFile=varargin{1};
else
    [filename, pathname]=uigetfile('*.*','Open a .mdu or .mdf  file');
    mdFile=[pathname filename];
end
modelType=nesthd_det_filetype(mdFile);
if strcmp(modelType,'none') || ~strcmp(modelType,'mdu') || ~strcmp(modelType,'mdf')
    [modelType,mdFile]=EHY_getModelType(mdFile);
    if strcmp(modelType,'none')
        error('No .mdu, .mdf or siminp found in this folder')
    end
end
runDir=fileparts(mdFile);
outputDir=[runDir filesep 'EHY_model2GoogleEarth_OUTPUT' filesep];
if ~exist(outputDir); mkdir(outputDir); end
%%
OPT.saveoutputFile=1;
switch modelType
    case 'mdu'
        mdu=delft3d_io_mdu('read',mdFile);
        
    case 'mdf'
         mdf=delft3d_io_mdf('read',mdFile);
         % .grd
         if isfield(mdf.keywords,'filcco') && ~isempty(mdf.keywords.filcco)
         OPT.grdFile=[runDir filesep mdf.keywords.filcco];
         d3dfile=mdf.keywords.filcco;
         inputFile=[runDir filesep d3dfile];
         outputFile=[outputDir strrep(d3dfile,'.grd','_grd.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[1 0 0],OPT);
         end
         
         % .dry
         if isfield(mdf.keywords,'fildry') && ~isempty(mdf.keywords.fildry)
         d3dfile=mdf.keywords.fildry;
         outputFile=[outputDir strrep(d3dfile,'.dry','_dry.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
         end
         
         % .thd
         if isfield(mdf.keywords,'filtd') && ~isempty(mdf.keywords.filtd)
         d3dfile=mdf.keywords.filtd;
         outputFile=[outputDir strrep(d3dfile,'.thd','_thd.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
         end
         
         % .crs
         if isfield(mdf.keywords,'filcrs') && ~isempty(mdf.keywords.filcrs)
         d3dfile=mdf.keywords.filcrs;
         outputFile=[outputDir strrep(d3dfile,'.crs','_crs.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 0 1],OPT);
         end
         
         % .obs
         if isfield(mdf.keywords,'filsta') && ~isempty(mdf.keywords.filsta)
         d3dfile=mdf.keywords.filsta;
         outputFile=[outputDir strrep(d3dfile,'.obs','_obs.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,OPT);
         end
         
         % .src
         if isfield(mdf.keywords,'filsrc') && ~isempty(mdf.keywords.filsrc)
         d3dfile=mdf.keywords.filsrc;
         outputFile=[outputDir strrep(d3dfile,'.src','_src.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
         end
end