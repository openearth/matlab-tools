function EHY_plotMapData_FM_interactive
%% EHY_plotMapData_FM_interactive
% get data
Data = EHY_getMapModelData_interactive;
if isfield(Data,'face_nodes_x')
    gridInfo.face_nodes_x = Data.face_nodes_x;
    gridInfo.face_nodes_y = Data.face_nodes_y;
elseif isfield(Data,'Xcor')
    gridInfo.Xcor = Data.Xcor;
    gridInfo.Ycor = Data.Ycor;
end

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
if isfield(Data,'face_nodes_x') % dfm
    if Data.OPT.mergePartitions==1
        disp(['gridInfo = EHY_getGridInfo(''' Data.OPT.outputfile ''',''face_nodes_xy'',''mergePartitions'',1);' ])
    else
        disp(['gridInfo = EHY_getGridInfo(''' Data.OPT.outputfile ''',''face_nodes_xy'');' ])
    end
elseif isfield(Data,'Xcor') % d3d
    disp(['gridInfo = EHY_getGridInfo(''' Data.OPT.outputfile ''',''XYcor'');' ])
end

% if velocity was selected
if isfield(Data,'vel_mag')
    disp(['EHY_plotMapData_FM(gridInfo,Data.vel_mag(' num2str(plotInd(1)) repmat(',:',1,ndims(Data.vel_mag)-1) '));' ])
else
    if isempty(plotInd)
        disp(['EHY_plotMapData_FM(gridInfo,Data.val);' ])
    else
        disp(['EHY_plotMapData_FM(gridInfo,Data.val(' num2str(plotInd(1)) repmat(',:',1,ndims(Data.val)-1) '));' ])
    end
end

disp('start plotting the top-view data...')
figure
for iPI=1:max([1 length(plotInd)])
    
    if ~isempty(plotInd)
        iT = plotInd(iPI);
        if length(plotInd)>1
            disp(['Plotting top-views: ' num2str(iPI) '/' num2str(length(plotInd))])
        end
        if isfield(Data,'vel_mag')
            EHY_plotMapData_FM(gridInfo,Data.vel_mag(iT,:,:))
        else
            EHY_plotMapData_FM(gridInfo,Data.val(iT,:,:))
        end
        title(datestr(Data.times(plotInd(iPI)),'dd-mmm-yyyy HH:MM'))
    else
        EHY_plotMapData_FM(gridInfo,Data.val)
    end
    pause(2)
end
disp('Finished plotting the top-view data!')

