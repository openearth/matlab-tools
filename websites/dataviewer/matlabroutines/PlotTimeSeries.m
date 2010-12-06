function [output] = PlotTimeSeries(ncfile,parameter, varargin)
% function [output] = PlotTimeSeries(ncfile,parameter, startTime, stopTime)
%
% with startTime and stopTime optional time strings:
% (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
%

%% Add java shit
% Add java paths for snc tools
% pth=fullfile(ctfroot,'checkout','OpenEarthTools','trunk','matlab','io','netcdf','toolsUI-4.1.jar');
pth = fullfile('C:\Inetpub\wwwroot\ZMMatlab\Resources\toolsUI-4.1.jar');
if ~exist(pth,'file')
    warning('PlotTimeSeries:NoJava',['Could not find path to java library: "' pth '". Try searching for the file']);
    pth = which('toolsUI-4.1.jar');
    if isempty(pth)
        error('could not find java library');
    end
end

if ~any(ismember(javaclasspath,pth))
   javaaddpath(pth);
end

if ~any(ismember(javaclasspath,pth))
    error(['Java library was not added', char(10),...
        'At this moment we only know:', char(10),...
        javaclasspath]);
end

setpref ('SNCTOOLS','USE_JAVA'   , 1); % This requires SNCTOOLS 2.4.8 or better
setpref ('SNCTOOLS','PRESERVE_FVD',0); % 0: backwards compatibility and consistent with ncBrowse

%% Plot time series
try
    f = figure();
    if nargin == 4
        startTime = datenum(varargin{1},'yyyymmddTHHMMSS');
        stopTime = datenum(varargin{2},'yyyymmddTHHMMSS');
        [D,M] = nc_cf_stationTimeSeries(ncfile,'varname',parameter,'period',[startTime stopTime]);
    else
        [D,M] = nc_cf_stationTimeSeries(ncfile,'varname',parameter);
    end
    
catch me
    error(['Could not read opendap file: ', me.getReport]);
end

%% Print to file
outputPng = [tempname '.png'];
print(f,'-dpng','-r120',outputPng);
close(f);


%% Generate output
output.png = outputPng;
output.data = D;
output.meta = M;