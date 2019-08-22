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
    plotInd = option;
elseif isfield(Data,'times') && length(Data.times)==1
    plotInd = 1;
else
    plotInd = [];
end

disp([char(10) 'Note that next time you want to plot this data, you can also use:'])
if Data.OPT.mergePartitions==1
    disp(['gridInfo = EHY_getGridInfo(''' Data.OPT.outputfile ''',''face_nodes_xy'',''mergePartitions'',1);' ])
else
    disp(['gridInfo = EHY_getGridInfo(''' Data.OPT.outputfile ''',''face_nodes_xy'');' ])
end

% if velocity was selected
if isfield(Data,'vel_mag')
    disp(['EHY_plotMapData_FM(gridInfo,Data.vel_mag(' num2str(plotInd(1)) ',:));' ])
else
    if isempty(plotInd)
        disp(['EHY_plotMapData_FM(gridInfo,Data.val);' ])
    else
        disp(['EHY_plotMapData_FM(gridInfo,Data.val(' num2str(plotInd(1)) ',:));' ])
    end
end

disp('start plotting the top-view data...')
figure
for iPI=1:max([1 length(plotInd)])
    
    if ~isempty(plotInd)
        iT = plotInd(iPI);
        title(datestr(Data.times(plotInd(iPI))))
        if length(plotInd)>1
            disp(['Plotting top-views: ' num2str(iPI) '/' num2str(length(plotInd))])
        end
        if isfield(Data,'vel_mag')
            EHY_plotMapData_FM(gridInfo,Data.vel_mag(iT,:))
        else
            EHY_plotMapData_FM(gridInfo,Data.val(iT,:))
        end
    else
        EHY_plotMapData_FM(gridInfo,Data.val)
    end
    pause(.2)
end
disp('Finished plotting the top-view data!')

