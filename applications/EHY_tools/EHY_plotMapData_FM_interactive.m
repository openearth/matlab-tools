function EHY_plotMapData_FM_interactive
%% EHY_plotMapData_FM_interactive
% get data
Data=EHY_getMapModelData_interactive;
gridInfo=EHY_getGridInfo(Data.OPT.outputfile,'face_nodes_xy');

if length(Data.times)>1
    option=listdlg('PromptString','Plot these time steps (as animation): (Use CTRL to select multiple time steps)','ListString',...
        datestr(Data.times),'ListSize',[300 400]);
    if isempty(option); disp('EHY_plotMapData_FM_interactive was stopped by user');return; end
    plotTimes=Data.times(option);
else
    plotTimes=1;
end

disp([char(10) 'Note that next time you want to plot this data, you can also use:'])
disp(['EHY_plotMapData_FM(''' Data.OPT.outputfile ''',Data.value(1,:));' ])

disp('start plotting the top-view data...')
figure
for iO=1:length(option)
    title(datestr(Data.times(option(iO))))
    if length(option)>1
        disp(['Plotting top-views: ' num2str(iO) '/' num2str(length(option))])
    end
    EHY_plotMapData_FM(gridInfo,Data.value(iO,:))
    pause(.2)
end
disp('Finished plotting the top-view data!')
EHYs(mfilename);
