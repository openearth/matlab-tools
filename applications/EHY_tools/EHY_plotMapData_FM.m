function EHY_plotMapData(mapFile,varName,timestep)
%% EHY_plotMapData(mapFile,varName)
% Create top views using QuickPlot / d3d_qp functionalities
% However, this function only plots the pcolor / patch part,
% so you can more easily add your own colorbar, xlims, etc.

% created by Julien Groenenboom, August 2018
%%
if nargin==3
    % filename of the map data (trim-<runid>.dat / *_map.nc)
    OPT.FI.Name=mapFile;
    %parameter to plot (i.e. 'waterlevel','Salinity','Temperature')
    OPT.Props.Name='waterlevel';
else
    [filename, pathname] = uigetfile('*.*','Open a map-data output file');
    OPT.FI.Name=[pathname filename];
    
    availableoutput={'waterlevel','Salinity','Temperature'};
    [availableoutputId,~]=  listdlg('PromptString',['Parameter to plot:'],...
        'SelectionMode','single',...
        'ListString',availableoutput,...
        'ListSize',[500 100]);
    OPT.Props.Name=availableoutput{availableoutputId};
     timestep=inputdlg('Which timestep to plot?','Input',1,{'1'});
end

%%
% Create tempdir and adjust qp_plot.m
tempDir=[tempdir 'EHY_plotMapData' filesep];
if ~exist(tempDir); mkdir(tempDir); end; addpath(tempDir);
copyfile([fileparts(which('d3d_qp')) filesep 'private'],tempDir)
copyfile(which('qp_getdata.m'),tempDir)
copyfile(which('qp_plot'),strrep(which('qp_plot'),'.m','2.m'))
fidr=fopen(which('qp_plot2'),'r');
fidw=fopen(which('qp_plot'),'w');
stop=0;
while stop==0 % change qp_plot to stop after plotting
    line=fgetl(fidr);
    fprintf(fidw,'%s\n',line);
    if strcmp(line,'% End of actual plotting')
        stop=1;
    end
end

% settings for QuickPlot
load(which('PlotState_template.mat'));
PlotState.FI    = setproperty(PlotState.FI   ,OPT.FI);
PlotState.Props = setproperty(PlotState.Props,OPT.Props);
PlotState.Selected(1) = timestep;
PlotState.Parent=gca;

% plot
qp_plot(PlotState);
title('');xlabel('');ylabel('');
end
