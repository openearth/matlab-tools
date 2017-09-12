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
if strcmp(modelType,'none')
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
        
    case 'mdf'
         mdf=delft3d_io_mdf('read',mdFile);
         % .grd
         OPT.grdFile=[runDir filesep mdf.keywords.filcco];
         d3dfile=mdf.keywords.filcco;
         inputFile=[runDir filesep d3dfile];
         outputFile=[outputDir strrep(d3dfile,'.grd','.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[1 0 0],OPT);
        
         % .dry
         d3dfile=mdf.keywords.fildry;
         outputFile=[outputDir strrep(d3dfile,'.dry','.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
         
         % .thd
         d3dfile=mdf.keywords.filtd;
         outputFile=[outputDir strrep(d3dfile,'.thd','.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
         
         % .crs
         d3dfile=mdf.keywords.filcrs;
         outputFile=[outputDir strrep(d3dfile,'.crs','.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 0 1],OPT);
         
         % .obs
         d3dfile=mdf.keywords.filsta;
         outputFile=[outputDir strrep(d3dfile,'.obs','.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,OPT);
         
         % .src
         d3dfile=mdf.keywords.filsrc;
         outputFile=[outputDir strrep(d3dfile,'.src','.kml')];
         inputFile=[runDir filesep d3dfile];
         [~,OPT]=EHY_convert(inputFile,'kml','outputFile',outputFile,'lineColor',[0 1 0],OPT);
         
end