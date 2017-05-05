function EHY_dflowfm_status(varargin)
%% EHY_dflowfm_status(varargin)
%
% Example1: EHY_dflowfm_status
% Example2: EHY_dflowfm_status('D:\run1\')
% Example3: EHY_dflowfm_status('D:\run1\model.mdu')
%
% created by Julien Groenenboom, May 2017

%%
if nargin==0
    [filename, pathname]=uigetfile('*.mdu','Open a .mdu file');
    mdFile=[pathname filename];
elseif nargin==1
    [pathstr, name, ext] = fileparts(varargin{1});
    if strcmp(ext,'.mdu')
        mdFile=varargin{1};
    else
        D=dir([pathstr '\*.mdu']);
        mdFile=[D(1).folder filesep D(1).name];
    end   
else
    error('Too many input arguments')
end

[pathstr, name, ext] = fileparts(mdFile);
D=dir([pathstr '\*\*_timings.txt']);
timingsFile=[D.folder filesep D.name];

runTimeInfo=EHY_runTimeInfo(mdFile);
simPeriod_S=runTimeInfo.simPeriod_S;
simPeriod_D=simPeriod_S/3600/24;

fid=fopen(timingsFile,'r');
while feof(fid)~=1
    line=fgetl(fid);
end
fclose(fid);
line=strsplit(line);
runPeriod_S=str2num(line{2});
runPeriod_D=runPeriod_S/3600/24;

disp(['Status of ' name ext ': ' num2str(runPeriod_D) '/' num2str(simPeriod_D) ' days - ',...
    sprintf('%0.1f',runPeriod_S/simPeriod_S*100) '%']);

