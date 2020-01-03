function varargout = EHY_plot_ldb(varargin)
%% varargout = EHY_plot_ldb(varargin)
%
% This functions plots a polyline (landboundary, river, border) to your current figure
% You may also be interested in EHY_plot_satellite_map.m
%
% Example1: EHY_plot_ldb
% Example2: hLdb = EHY_plot_ldb;
% Example3: hLdb = EHY_plot_ldb('color','r','type','rivers');
% Example4: hLdb = EHY_plot_ldb('color','r','type',{'shorelines','rivers'},'linewidth',1);
%
% Example5 - plot a map showing some capitals in Europe:
%    lat = [48.8708   51.5188   41.9260   40.4312   52.523   37.982];
%    lon = [2.4131    -0.1300    12.4951   -3.6788    13.415   23.715];
%    plot(lon,lat,'.r','MarkerSize',20)
%    EHY_plot_ldb
%
% This function is largely based on QuickPlot-functionality and uses the
% Self-consistent, Hierarchical, High-resolution Geography Database (GSHHS).
% For more information see one of the following two links:
%   http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
%   http://www.soest.hawaii.edu/pwessel/gshhg/index.html
%
% To delete the polylines, you may use delete(hLdb{:});
%
% Julien.Groenenboom@deltares.nl, January 2020

%% default settings
OPT.type      = {'shorelines','borders'}; % choose from: 'borders','rivers','shorelines' // string or cell array
OPT.color     = 'k';
OPT.linewidth = 0.5;
OPT           = setproperty(OPT,varargin);

%% structure to cell array
fns = fieldnames(OPT);
for iFN = 1:length(fns)
    ind = iFN*2-1;
    input{ind} = fns{iFN};
    input{ind+1} = OPT.(fns{iFN});
end

%% plot polyline in current axis
if ischar(OPT.type)
    OPT.type = cellstr(OPT.type);
end

hold on
rootfolder = [fileparts(which('EHY')) filesep 'support_functions' filesep 'GSHHG'];

for iT = 1:length(OPT.type) % loop over types
    hLdb{iT} = gshhg('plot','type',OPT.type{iT},'color',OPT.color,'rootfolder',rootfolder);
    set(hLdb{iT},'linewidth',OPT.linewidth); % linewidth
end

if nargout > 0
    varargout{1} = hLdb;
end
