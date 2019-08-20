function EHY_plotMapData_FM_interactive
%% EHY_plotMapData_FM_interactive
% get data
Data = EHY_getMapModelData_interactive;
gridInfo.face_nodes_x = Data.face_nodes_x;
gridInfo.face_nodes_y = Data.face_nodes_y;

if isfield(Data,'times') && length(Data.times)>1
    option=listdlg('PromptString','Plot these time steps (as animation): (Use CTRL to select multiple time steps)','ListString',...
        datestr(Data.times),'ListSize',[400 400]);
    if isempty(option); disp('EHY_plotMapData_FM_interactive was stopped by user');return; end
    plotTimes=Data.times(option);
elseif isfield(Data,'times') && length(Data.times)==1
    plotTimes=Data.times(1);
else
    plotTimes=[];
end

disp([char(10) 'Note that next time you want to plot this data, you can also use:'])
if Data.OPT.mergePartitions==1
    disp(['gridInfo = EHY_getGridInfo(''' Data.OPT.outputfile ''',''face_nodes_xy'',''mergePartitions'',1);' ])
else
    disp(['gridInfo = EHY_getGridInfo(''' Data.OPT.outputfile ''',''face_nodes_xy'');' ])
end
disp(['EHY_plotMapData_FM(gridInfo,Data.val(1,:));' ])

% if velocity was selected, plot magnitude
if ~isfield(Data,'val') && isfield(Data,'vel_x')
    Data.val=sqrt(Data.vel_x.^2+Data.vel_y.^2);
end

disp('start plotting the top-view data...')
figure
no_plotTimes=length(plotTimes);
for iT=1:max([1 no_plotTimes])
    if ~isempty(plotTimes)
        title(datestr(plotTimes(iT)))
        if no_plotTimes>1
            disp(['Plotting top-views: ' num2str(iT) '/' num2str(no_plotTimes)])
        end
        EHY_plotMapData_FM(gridInfo,Data.val(iT,:))
    else
        EHY_plotMapData_FM(gridInfo,Data.val)
    end
    pause(.2)
end
disp('Finished plotting the top-view data!')

